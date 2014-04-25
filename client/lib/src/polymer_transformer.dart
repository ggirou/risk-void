part of risk.client;

class StringToInt extends Transformer<String, int> {
  String forward(int i) => '$i';
  int reverse(String s) => int.parse(s);
}