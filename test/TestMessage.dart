library stomp_dart;
import 'dart:math';
import "dart:json" as JSON;
import 'package:unittest/unittest.dart';
import '../lib/stomp_dart.dart';
import 'TestConfig.dart';

class TestMessage {
  static void runTests() {
  group('Stomp Message:', () {
    test('Send and receive a message', () {
      var body = new Random().nextInt(1000).toString();
      var received = null;
      var client = Stomp.client(TestConfig.url);
      var messageCallback = expectAsync1((Frame message) {
        expect(message.body, equals(body));
        client.disconnect();
      });
      var connectCallback = () {
        client.subscribe(TestConfig.destination, messageCallback);
        client.send(TestConfig.destination, {}, body);
      };
      client.connect(TestConfig.login, TestConfig.password, connectCallback);
    });

    test("Send and receive a message with a JSON body", () {
      var client = Stomp.client(TestConfig.url);
      var payload = {'text': 'hello', 'bool': true, 'value': new Random().nextInt(1000)};
      var messageCallback = expectAsync1((Frame message) {
        var res = JSON.parse(message.body);
        expect(res['text'], equals(payload['text']));
        expect(res['bool'], equals(payload['bool']));
        expect(res['value'], equals(payload['value']));
        client.disconnect();
      });
      var connectCallback = () {
        client.subscribe(TestConfig.destination, messageCallback);
        client.send(TestConfig.destination, {}, JSON.stringify(payload));
      };
      client.connect(TestConfig.login, TestConfig.password, connectCallback);
    });
  });
  }
}
