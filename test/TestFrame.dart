library stomp_dart;
import 'package:unittest/unittest.dart';
import '../lib/stomp_dart.dart';


class TestFrame {
  static void runTests() {
  group('Stomp Frame:', () {
    test('marshal a CONNECT Frame', () {
      String out = StompMarshaller.marshal("CONNECT", {'login': 'jmesnil', 'passcode': 'wombats'});
      
      expect(out.codeUnitAt(out.length-3), equals(10));
      expect(out.codeUnitAt(out.length-2), equals(10));
      expect(out.codeUnitAt(out.length-1), equals(0));
      expect(out.codeUnits.length, equals(41));
      expect(out.length, equals(41));
      expect(out, equals("CONNECT\nlogin:jmesnil\npasscode:wombats\n\n\x00"));
    });

    test('marshal a SEND frame', () {
      var out = StompMarshaller.marshal("SEND", {'destination': '/queue/test'}, "hello, world!");
      expect(out, equals("SEND\ndestination:/queue/test\n\nhello, world!\x00"));
    });

    test('unmarshal a CONNECTED frame', () {
      var data = "CONNECTED\nsession-id: 1234\n\n\x00";
      var frame = StompMarshaller.unmarshal(data);
      expect(frame.command, equals("CONNECTED"));
      expect(frame.headers, equals({'session-id': "1234"}));
      expect(frame.body, equals(''));
    });

    test("unmarshal a RECEIVE frame", () {
      var data = "RECEIVE\nfoo: abc\nbar: 1234\n\nhello, world!\x00";
      var frame = StompMarshaller.unmarshal(data);
      expect(frame.command, equals("RECEIVE"));
      expect(frame.headers, equals({'foo': 'abc', 'bar': "1234"}));
      expect(frame.body, equals("hello, world!"));
    });

    test("unmarshal should not include the null byte in the body", () {
      var body1 = 'Just the text please.';
      var body2 = 'And the newline\n';
      var msg = "MESSAGE\ndestination: /queue/test\nmessage-id: 123\n\n";
      expect(StompMarshaller.unmarshal('${msg}${body1}\x00').body, body1);
      expect(StompMarshaller.unmarshal('${msg}${body2}\x00').body, body2);
    });

    test("unmarshal should support colons (:) in header values", () {
      var dest = 'foo:bar:baz';
      var msg = "MESSAGE\ndestination: ${dest}\nmessage-id: 456\n\n\x00";
      expect(StompMarshaller.unmarshal(msg).headers['destination'], dest);
    });
  });
  }
}


