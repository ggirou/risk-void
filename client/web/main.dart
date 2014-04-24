import 'dart:html';
import 'dart:convert';
import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

class Message {
  String user, message;
  
  Message(this.user, this.message);
  Message.fromJson(Map data) {
    user    = data["user"];
    message = data["message"];
  }
  
  Map toJson() => {"user": user, "message": message};
}

@Controller(
  selector: '[chat-app]',
  publishAs: 'chat')
class ChatController {
  WebSocket ws;
  String user = "";
  String message = "";
  List<Message> messages = [];
  DivElement chatBox = querySelector("#chat-box");
  
  ChatController() {
    // Initialize Websocket connection
    ws = new WebSocket("ws://${window.location.hostname}/ws");

    // Listen for Websocket events
    ws.onOpen.listen((e)    => print("Connected"));
    ws.onClose.listen((e)   => print("Disconnected"));
    ws.onError.listen((e)   => print("Error"));

    // Collect messages from the stream
    ws.onMessage.listen((e) { 
      messages.add(new Message.fromJson(JSON.decode(e.data)));
      chatBox.children.forEach((child) => chatBox.scrollByLines(chatBox.scrollHeight));
    });
  }
  
  // Send message on the channel
  void send() {
    if(user != "" && message != "") {
      ws.send(JSON.encode(new Message(user, message)));

      // Clear message input
      message = "";  
    }
  }
}

class ChatModule extends Module {
  ChatModule() {
    type(ChatController);
  }
}

void main() {
  applicationFactory()
    .addModule(new ChatModule())
    .run();
}

