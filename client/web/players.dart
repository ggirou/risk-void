import 'package:polymer/polymer.dart';
import 'package:risk/risk.dart';

@CustomTag('risk-players')
class RiskPlayers extends PolymerElement {
  @published
  Iterable<PlayerState> players;

  @published
  int activePlayerId;

  @published
  List<int> playersOrder = [];

  RiskPlayers.created(): super.created();
  
  String uppercase(String name) => name.toUpperCase();

  sort(List<int> playersOrder) => (Iterable<PlayerState> players) => new List.from(players) //
      ..sort((PlayerState a, PlayerState b) => playersOrder.indexOf(a.playerId).compareTo(playersOrder.indexOf(b.playerId)));
}