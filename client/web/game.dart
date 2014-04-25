import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:polymer/polymer.dart';
import 'package:risk/client.dart';
import 'package:risk/snapshot.dart';

const AUTO_SETUP = false;

@CustomTag('risk-game')
class RiskGame extends PolymerElement {
  // Whether styles from the document apply to the contents of the component
  bool get applyAuthorStyles => true;

  @observable
  RiskGameState game = new RiskGameStateImpl();

  @observable
  int playerId;

  @observable
  Move pendingMove; // {'from':from, 'to': to}

  final WebSocket ws;

  RiskGame.created(): this.fromWebSocket(new WebSocket(_currentWebSocketUri().toString())); // , snapshot: SNAPSHOT_GAME_ATTACK);

  RiskGame.fromWebSocket(this.ws, {Iterable<EngineEvent> snapshot: const []}): super.created() {
    new Stream.fromIterable(snapshot).listen(handleEvents);
    var eventStream = ws.onMessage.map((e) => e.data).map(JSON.decode).map(_printEvent("IN")).map(EVENT.decode).listen(handleEvents);
    // Keep connection alive
    new Timer.periodic(const Duration(seconds: 30), (_) => ws.sendString(JSON.encode('ping')));
  }

  handleEvents(EngineEvent event) {
    game.update(event);

    if (event is Welcome) {
      playerId = event.playerId;
    } else if (event is BattleEnded) {
      if (event.attacker.playerId == playerId) {
        if (event.defender.remainingArmies == 0) {
          if (event.attacker.remainingArmies == 2) {
            sendEvent(new MoveArmy()
                ..playerId = playerId
                ..from = event.attacker.country
                ..to = event.defender.country
                ..armies = 1);
          } else {
            var maxArmies = event.attacker.remainingArmies - 1;
            pendingMove = new Move()
                ..from = event.attacker.country
                ..to = event.defender.country
                ..maxArmies = maxArmies
                ..armiesToMove = maxArmies;
          }
        }
      }
    } else if (event is ArmyMoved) {
      pendingMove = null;
    } else if (event is NextPlayer) {
      if (AUTO_SETUP && game.setupPhase && event.playerId == playerId) {
        sendEvent(new PlaceArmy()
            ..playerId = playerId
            ..country = (game.countries.values.where((cs) => cs.playerId == playerId).map((cs) => cs.countryId).toList()..shuffle()).first);
      }
    }
  }

  joinGame(CustomEvent e, var detail, Element target) => sendEvent(new JoinGame()
      ..playerId = playerId
      ..color = detail['color']
      ..avatar = detail['avatar']
      ..name = detail['name']);

  attack(CustomEvent e, var detail, Element target) => sendEvent(new Attack()
      ..playerId = playerId
      ..from = e.detail['from']
      ..to = e.detail['to']
      ..armies = min(3, game.countries[e.detail['from']].armies - 1));

  move(CustomEvent e, var detail, Element target) {
    var maxArmies = game.countries[e.detail['from']].armies - 1;
    pendingMove = new Move()
        ..from = e.detail['from']
        ..to = e.detail['to']
        ..maxArmies = maxArmies
        ..armiesToMove = maxArmies;
  }

  startGame() => sendEvent(new StartGame()..playerId = playerId);

  selection(CustomEvent e, var detail, Element target) => sendEvent(new PlaceArmy()
      ..playerId = playerId
      ..country = e.detail);

  moveArmies() => sendEvent(new MoveArmy()
      ..playerId = playerId
      ..from = pendingMove.from
      ..to = pendingMove.to
      ..armies = pendingMove.armiesToMove);

  endAttack() => sendEvent(new EndAttack()..playerId = playerId);

  endTurn() => sendEvent(new EndTurn()..playerId = playerId);

  sendEvent(PlayerEvent event) => ws.send(_printEvent('OUT')(JSON.encode(EVENT.encode(event))));
}

Uri _currentWebSocketUri() {
  var uri = Uri.parse(window.location.toString());
  return new Uri(scheme: "ws", host: uri.host, port: uri.port, path: "/ws");
  //  return new Uri(scheme: "ws", host: "localhost", port: 8080, path: "/ws");
}

_printEvent(direction) => (event) {
  print("$direction - $event");
  return event;
};
