import 'dart:convert';
import 'package:http/http.dart' as http;

class Esp32ApiService {
  static const String espIp = "192.168.4.1"; // ESP32 AP IP
  static const String baseUrl = "http://$espIp";

  static Future<bool> checkConnection() async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/ping"))
          .timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getTime() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/time"));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return null;
  }

  static Future<void> sendCommand(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse("$baseUrl/command"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }
}
