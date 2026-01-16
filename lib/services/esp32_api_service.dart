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
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:wifi_iot/wifi_iot.dart';
//
// class Esp32ApConnectPage extends StatefulWidget {
//   const Esp32ApConnectPage({super.key});
//
//   @override
//   State<Esp32ApConnectPage> createState() => _Esp32ApConnectPageState();
// }
//
// class _Esp32ApConnectPageState extends State<Esp32ApConnectPage> {
//   String status = "Not connected";
//
//   final String espSsid = "SchoolBell_S3";
//   final String espPassword = "12345678";
//   final String espIp = "192.168.4.1";
//   final int espPort = 23;
//
//   Future<void> connectToEsp32() async {
//     setState(() => status = "Connecting to ESP32...");
//
//     bool? connected = await WiFiForIoTPlugin.connect(
//       espSsid,
//       password: espPassword,
//       security: NetworkSecurity.WPA,
//       joinOnce: true,
//       withInternet: false,
//     );
//
//     if (connected == true) {
//       setState(() => status = "Connected to ESP32 AP");
//     } else {
//       setState(() => status = "Connection failed");
//     }
//   }
//
//   Future<void> sendTestCommand() async {
//     try {
//       setState(() => status = "Sending command...");
//
//       Socket socket = await Socket.connect(espIp, espPort,
//           timeout: const Duration(seconds: 5));
//
//       socket.write("\$MENU#");
//       await socket.flush();
//       socket.destroy();
//
//       setState(() => status = "Command sent: \$MENU#");
//     } catch (e) {
//       setState(() => status = "Error sending command");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("ESP32 AP Connection"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text(
//               status,
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 30),
//
//             ElevatedButton(
//               onPressed: connectToEsp32,
//               child: const Text("Connect to ESP32"),
//             ),
//
//             const SizedBox(height: 20),
//
//             ElevatedButton(
//               onPressed: sendTestCommand,
//               child: const Text("Send \$MENU#"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
