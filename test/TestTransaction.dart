
library stomp_dart;
import 'dart:math';
import 'package:unittest/unittest.dart';
import '../lib/stomp_dart.dart';
import 'TestConfig.dart';
import 'dart:html';

class TestTransaction {
  static void runTests() {
  group('Stomp Transaction:', () {

    test("Send a message in a transaction and abort", () {
      var txnumber = new Random().nextDouble();
      var txid = "txid_$txnumber";
      var body = new Random().nextDouble().toString();
      var body2 = new Random().nextDouble().toString();

      var client = Stomp.client(TestConfig.url);

      var messageCallback = expectAsync1((Frame message) {
        expect(message.body, equals(body2));
        client.disconnect();
      });
      var connectCallback = () {
        client.subscribe(TestConfig.destination, messageCallback);
        client.begin(txid);
        client.send(TestConfig.destination, {'transaction': txid}, body);
        client.abort(txid);
        client.send(TestConfig.destination, {}, body2);
      };
      client.connect(TestConfig.login, TestConfig.password, connectCallback);
    });

    test("Send a message in a transaction and commit", () {

      var txnumber = new Random().nextDouble();
      var txid = "txid_$txnumber";
      var body = new Random().nextDouble().toString();

      var client = Stomp.client(TestConfig.url);

      var messageCallback = expectAsync1((Frame message) {
        expect(message.body, equals(body));
        client.disconnect();
      });
      var connectCallback = () {
        client.subscribe(TestConfig.destination, messageCallback);
        client.begin(txid);
        client.send(TestConfig.destination, {'transaction': txid}, body);
        client.commit(txid);
      };

      client.connect(TestConfig.login, TestConfig.password, connectCallback);
    });

  });
  }
}
