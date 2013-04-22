library stomp_dart;
import 'dart:math';
import 'package:unittest/unittest.dart';
import '../lib/stomp_dart.dart';
import 'TestConfig.dart';
import 'dart:html';

class TestSubscription {
  static void runTests() {
  group('Stomp Subscription:', () {
    Client client = null;
    setUp(() {
      client = Stomp.client(TestConfig.url);
    });
    tearDown(() {
      client.disconnect();
    });

    test("Should receive messages sent to destination after subscribing", () {
      var msg = 'Is anybody out there?';
      var messageCallback = expectAsync1((Frame message) {
        expect(message.body, equals(msg));
      });
      var connectCallback = () {
        client.subscribe(TestConfig.destination, messageCallback);
        client.send(TestConfig.destination, {}, msg);
      };
      client.connect(TestConfig.login, TestConfig.password, connectCallback);
    });


    test("Should no longer receive messages after unsubscribing to destination", () {
      var msg1 = 'Calling all cars!';
      var subId = null;
      var messageCallbackDropped = expectAsync1((Frame message) {
        expect(false, 'Should not be reached');
      }, count: 0);
      var messageCallbackOk = expectAsync1((Frame message) {
        expect(message.body, equals(msg1));
      });
      var connectCallback = () {
        subId = client.subscribe(TestConfig.destination, messageCallbackDropped);
        client.subscribe(TestConfig.destination, messageCallbackOk);
        client.unsubscribe(subId);
        client.send(TestConfig.destination, {}, msg1);
      };
       client.connect(TestConfig.login, TestConfig.password, connectCallback);
    });

  });
  }
}
