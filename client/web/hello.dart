import 'package:polymer/polymer.dart';

@CustomTag('hello-world')
class HelloWorld extends PolymerElement {
  @published
  String name;

  HelloWorld.created(): super.created();
}