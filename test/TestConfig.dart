library stomp_dart;
class TestConfig {
  static String destination = "/topic/example";
  static String login = "guest";
  static String password = "guest";
  static String url = "ws://localhost:61623/stomp";
  static String badUrl= "ws://localhost:9001/stomp";
  static int timeout= 2000;
}
