library risk.client;

@MirrorsUsed(targets: const ['risk', 'risk.client'])
import 'dart:mirrors';

import 'package:observe/observe.dart';
import 'package:polymer_expressions/filter.dart' show Transformer;

// Import common sources to be visible in this library scope
import 'risk.dart';
// Export common sources to be visible to this library's users
export 'risk.dart';

part 'src/polymer_transformer.dart';


class Move extends Object with Observable {
  String from, to;
  int maxArmies;
  @observable int armiesToMove = 1;
}
