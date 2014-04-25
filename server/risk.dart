import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:vane/vane.dart';
import 'package:logging/logging.dart';
import 'package:risk/server.dart';

RiskWsServer riskServer = new RiskWsServer();

class Risk extends Vane {
  Future main() {
    riskServer.handleWebSocket(ws).then((_) => close());

    return end;
  }
}

class NewGame extends Vane {
  Future main() {
    riskServer = new RiskWsServer();
    log.info("New game");
    return close();
  }
}

class RiskWsServer {
  final Map<int, WebSocket> _clients = {};
  final RiskGameEngine engine;

  final StreamController outputStream;
  int currentPlayerId = 1;

  RiskWsServer(): this._(new StreamController.broadcast());
  RiskWsServer._(StreamController eventController)
      : outputStream = eventController,
        engine = new RiskGameEngine(eventController, new RiskGameStateImpl());

  Future handleWebSocket(WebSocket ws) {
    final playerId = connectPlayer(ws);

    // Decode JSON
    return ws.map(JSON.decode) //
    // Check if it's decodable
    .where(EventCodec.canDecode) //
    // Log incoming events
    .map(logEvent("IN", playerId)) //
    // Decode events
    .map(EVENT.decode) //
    // Avoid unknown events and cheaters
    .where((event) => event is PlayerEvent && event.playerId == playerId) //
    // Handle events in game engine
    .listen(engine.handle) //
    // Connection closed
    .asFuture().then((_) => print("Player $playerId left"));
  }

  int connectPlayer(WebSocket ws) {
    int playerId = currentPlayerId++;

    _clients[playerId] = ws;

    // Concate streams: Welcome event, history events, incoming events
    var stream = new StreamController();
    stream.add(new Welcome()..playerId = playerId);
    engine.history.forEach(stream.add);
    stream.addStream(outputStream.stream);

    ws.addStream(stream.stream.map(EVENT.encode).map(logEvent("OUT", playerId)).map(JSON.encode));

    ws.pingInterval = const Duration(seconds: 30);

    print("Player $playerId connected");
    return playerId;
  }

  logEvent(String direction, int playerId) => (event) {
    Logger.root.info("$direction[$playerId] - $event");
    return event;
  };
}
