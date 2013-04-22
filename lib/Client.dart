part of stomp_dart;

typedef void MessageCallback(Frame message);

typedef void ConnectCallback();

typedef void DisconnectCallback();

typedef void ErrorCallback(Object error);

class Client {
  
  WebSocket ws;
  
  //used to index subscribers
  int counter;
  
  bool connected;
  
  Map<String, MessageCallback> subscriptions = {};
  
  Client(this.ws) {
    ws.binaryType = "arraybuffer";
    counter = 0;
    connected = false;
  }
  
  void _transmit(String command, Map<String, String> headers, [String body='']) {
    var out = StompMarshaller.marshal(command, headers, body);
    print('>>> ${out}');
    ws.send(out);
  }
  
  void connect(String login, String passcode, ConnectCallback connectCallback,[ErrorCallback errorCallback,  String vhost]) {
    print('Opening Web Socket...');    
    ws.onMessage.listen((MessageEvent evt) {      
      //print(evt);
      var data = evt.data;
      print('<<< $data');
      List<Frame> frames = StompMarshaller.unmarshalMulti(data);
      frames.forEach((Frame frame) {
        if (frame.command == "CONNECTED" && connectCallback!=null) {
          connected = true;
          connectCallback();
        }
        else if (frame.command == "MESSAGE") {          
          var subscription  = frame.headers['subscription'];          
          var onMessageCallback = subscriptions[subscription];          
          if (onMessageCallback != null) {
            onMessageCallback(frame);
          }
        }
      //  #else if frame.command is "RECEIPT"
      //  #  @onreceipt?(frame)
        else if (frame.command == "ERROR") {
          if (errorCallback != null) {
            errorCallback(frame);
          }          
        }
        else {
          print("Unhandled frame: $frame");
          //@debug?("Unhandled frame: " + frame)
        }
      });
    });
    
    ws.onClose.listen((CloseEvent e) {      
      var msg = "Whoops! Lost connection to ${ws.url}";
      print(msg);
      if (errorCallback!=null) {
        errorCallback(msg);
      }
    });
    ws.onError.listen((e) {
      print('error');
      print(e);
    });
    
    ws.onOpen.listen((e) {
      print('Web Socket Opened...');
      var headers = {'login': login, 'passcode': passcode};
      if (vhost!=null) {
        headers['host'] = vhost;
      }
      //ws.send('Hello from Dart!');
      _transmit("CONNECT", headers);
    });
    
  }
  
  void disconnect([DisconnectCallback disconnectCallback]) {
    _transmit("DISCONNECT", {});
    ws.close();
    connected = false;
    if (disconnectCallback != null) {
      disconnectCallback();    
    }
  }
  
  void send(String destination, Map<String, String> headers, String body) {
    headers['destination'] = destination;
    _transmit("SEND", headers, body);
  }
  
  String subscribe(String destination, MessageCallback callback,[ Map<String, String> headers]) {
    if (headers == null) {
      headers = {};
    }
    String id;
    if (!headers.containsKey('id') || headers['id'].isEmpty) {
      id = 'sub-$counter';
      counter++;
      headers['id']=id;
    }
    else {
      id = headers['id'];
    }
    headers['destination'] = destination;
    subscriptions[id] = callback;
    _transmit("SUBSCRIBE", headers);
    return id;
  }
  
  void unsubscribe (String id,[ Map<String, String> headers]) {
    if (headers == null) {
      headers = {};
    }
    headers['id'] = id;
    subscriptions.remove(id);
    _transmit("UNSUBSCRIBE", headers);
  }
  
  void begin(String transaction, [Map<String, String> headers]) {
    if (headers == null) {
      headers = {};
    }
    headers['transaction'] = transaction;
    _transmit("BEGIN", headers);
  }
  
  void commit(String transaction, [Map<String, String> headers]) {
    if (headers == null) {
      headers = {};
    }
    headers['transaction'] = transaction;
    _transmit("COMMIT", headers);
  }
  
  void abort(String transaction, [Map<String, String> headers]) {
    if (headers == null) {
     headers = {};
    }
    headers['transaction'] = transaction;
    _transmit("ABORT", headers);
  }
 
   
 void ack(String message_id, Map<String, String> headers) {
    headers["message-id"] = message_id;
    _transmit("ACK", headers);
 }
 
}
