import 'package:polymer/polymer.dart';
import 'package:risk/client.dart';

@CustomTag('risk-panel')
class RiskPanel extends PolymerElement {
  @published
  RiskGameState game;

  @published
  int playerId;

  @published
  Move pendingMove;

  final asInteger = new StringToInt();

  RiskPanel.created(): super.created();

  startGame() =>  fire('startgame');
  moveArmies() => fire('movearmies');
  endAttack() => fire('endattack');
  endTurn() => fire('endturn');
}
