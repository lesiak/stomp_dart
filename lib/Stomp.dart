part of stomp_dart;

class Stomp {
    
  static Client client(String url) {  
    var ws = new WebSocket(url);
    return new Client(ws);
  }

  static Client over(WebSocket ws) {
    return new Client(ws);
  }
}
