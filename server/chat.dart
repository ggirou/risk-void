import 'dart:async';
import 'package:vane/vane.dart';

StreamController channel = new StreamController.broadcast();

class Chat extends Vane {
  Future main() {
    var conn = ws.listen(null);
    
    // Add all incomming message to the chatStream
    conn.onData((msg) {
      log.info(msg);
      channel.sink.add(msg);
    });
    
    // On error, log warning
    conn.onError((e) => log.warning(e));
    
    // Close connection if websocket closes
    conn.onDone(() => close());
    
    // Add message to chat stream
    channel.stream.listen((msg) {
      log.info(msg);
      ws.add(msg);
    });
    
    return end;
  }
}

