part of stomp_dart;

class StompMarshaller {
  static String marshal(String command, Map<String,String> headers,[String body='']) {
    var aFrame = new Frame(command, headers, body);    
    return "${aFrame}\x00";   
  }
  
  //Web socket servers can send multiple frames in a single websocket message.
  //Split the data before unmarshalling every single STOMP frame
  static List<Frame> unmarshalMulti(String multi_datas) {
    List<Frame> ret = multi_datas.split('\x00\n*').map((String data) => StompMarshaller.unmarshal(data)).toList();
    return ret;    
  }
  
  static Frame unmarshal(String data) {
    var divider = data.indexOf('\n\n');
    List<String> headerLines = data.substring(0, divider).split('\n');
    var command = headerLines.removeAt(0);
    var headers = new Map<String, String>();
    var body = new StringBuffer();
    
    //Parse Headers
    for (var i=0; i < headerLines.length; ++i) {
      var line = headerLines[i];
      var idx = line.indexOf(':');
      var key = line.substring(0, idx).trim();
      var value = line.substring(idx + 1).trim();
      headers[key] = value;
    }
    
    //Parse body, stopping at the first \0 found.
    //TODO: Add support for content-length header.
    
    for (int i =divider + 2; i <data.length; ++i) {
      var chr = data[i];      
      if (chr == '\x00') {
         break;
      }
      body.write(chr);
    }
    return new Frame(command, headers, body.toString());
  }

}
