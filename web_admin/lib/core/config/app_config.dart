import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late String apiBaseUrl;
  static late String wsBaseUrl;
  static late String appName;
  static late String appVersion;
  
  static Future<void> initialize() async {
    apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
    wsBaseUrl = dotenv.env['WS_BASE_URL'] ?? 'ws://localhost:8000';
    appName = dotenv.env['APP_NAME'] ?? 'PatrolShield Admin';
    appVersion = dotenv.env['APP_VERSION'] ?? '1.0.0';
  }
}