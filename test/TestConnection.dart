library stomp_dart;
import 'dart:html';
import 'dart:math';
import 'package:unittest/unittest.dart';
import '../lib/stomp_dart.dart';
import 'TestConfig.dart';


class TestConnection {
  static void runTests() {
  group('Stomp Connection:', () {
    test('Connect to an invalid Stomp server', () {
      var client = Stomp.client(TestConfig.badUrl);
      var errorCallback = expectAsync1((e) => print(e));
      client.connect(TestConfig.login, TestConfig.password, () {}, errorCallback);
    });

    test("Connect to a valid Stomp server", () {
      var client = Stomp.client(TestConfig.url);
      var successCallback = expectAsync0(() {});
      client.connect(TestConfig.login, TestConfig.password, successCallback);
    });

    test("Disconnect", () {
      var client = Stomp.client(TestConfig.url);
      var disconnectCallback = expectAsync0(() {});
      client.connect(TestConfig.login, TestConfig.password,
       () {
        // once connected, we disconnect
        client.disconnect(disconnectCallback);
        });
    });
  });
  }
}
