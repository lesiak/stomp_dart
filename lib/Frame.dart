part of stomp_dart;

class Frame {
  String command;
  Map<String, String> headers;
  String body;  
  
  Frame(this.command, this.headers,this.body);
  
  String toString() {
    List<String> lines = [command];
    headers.forEach((name, value) => lines.add('${name}:${value}'));
    lines.add('\n${body}');     
    return lines.join('\n');
  }
}




