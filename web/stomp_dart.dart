
import 'dart:html';
import 'package:unittest/html_config.dart';

import '../test/TestConfig.dart';
import '../test/TestFrame.dart';
import '../test/TestConnection.dart';
import '../test/TestMessage.dart';
import '../test/TestTransaction.dart';
import '../test/TestSubscription.dart';

void main() {
  query('#test_url').text = TestConfig.url;
  query('#test_destination').text = TestConfig.destination;
  query('#test_login').text = TestConfig.login;
  query('#test_password').text = TestConfig.password;
  useHtmlConfiguration();
  TestFrame.runTests();
  TestConnection.runTests();
  TestMessage.runTests();
  TestTransaction.runTests();
  TestSubscription.runTests();
}


