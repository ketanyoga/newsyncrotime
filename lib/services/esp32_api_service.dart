// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class Esp32ApiService {
//   static const String espIp = "192.168.4.1"; // ESP32 AP IP
//   static const String baseUrl = "http://$espIp";
//
//   static Future<bool> checkConnection() async {
//     try {
//       final res = await http
//           .get(Uri.parse("$baseUrl/ping"))
//           .timeout(const Duration(seconds: 2));
//       return res.statusCode == 200;
//     } catch (_) {
//       return false;
//     }
//   }
//
//   static Future<Map<String, dynamic>?> getTime() async {
//     try {
//       final res = await http.get(Uri.parse("$baseUrl/time"));
//       if (res.statusCode == 200) {
//         return jsonDecode(res.body);
//       }
//     } catch (_) {}
//     return null;
//   }
//
//   static Future<void> sendCommand(Map<String, dynamic> data) async {
//     await http.post(
//       Uri.parse("$baseUrl/command"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(data),
//     );
//   }
// }



import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Esp32ApiService {
  static const String espIp = "192.168.4.1";
  static const int tcpPort = 23; // Use the correct port for your ESP32 firmware.

  static Socket? _socket;
  static bool _isConnected = false;

  // Use a broadcast StreamController to allow multiple listeners if needed.
  static final StreamController<String> _socketResponseController =
  StreamController<String>.broadcast();

  // --- PRIVATE METHODS ---

  /// Ensures a connection is established. Connects if not already connected.
  static Future<void> _ensureConnection() async {
    if (_isConnected && _socket != null) {
      return;
    }

    try {
      _socket = await Socket.connect(
        espIp,
        tcpPort,
        timeout: const Duration(seconds: 5),
      );

      _isConnected = true;

      // Listen to the socket and add incoming data to our stream.
      _socket!.listen(
            (data) {
          final response = utf8.decode(data).trim();
          if (response.isNotEmpty) {
            _socketResponseController.add(response);
          }
        },
        onError: (error) {
          _socketResponseController.addError(error);
          _closeConnection();
        },
        onDone: () {
          _closeConnection();
        },
        cancelOnError: true,
      );
    } catch (e) {
      _socketResponseController.addError(e); // Notify listeners of the connection error
      _closeConnection();
      // Rethrow the exception so the calling function knows the connection failed.
      throw Exception("Failed to connect to ESP32: $e");
    }
  }

  /// Closes the connection and resets the state.
  static Future<void> _closeConnection() async {
    _isConnected = false;
    try {
      await _socket?.close();
    } catch (_) {
      // Ignore errors on close
    }
    _socket = null;
  }

  // --- PUBLIC API ---

  /// Checks if a connection can be established.
  static Future<bool> checkConnection() async {
    try {
      await _ensureConnection();
      return _isConnected;
    } catch (_) {
      return false;
    }
  }

  /// Exposes the stream of responses for the UI to listen to.
  static Stream<String> listen() {
    return _socketResponseController.stream;
  }

  /// Sends a raw command string. The command should NOT include the '#' or newline.
  static Future<void> sendRaw(String command) async {
    // This now throws an exception on failure, which can be caught in the UI.
    await _ensureConnection();
    // The ESP32 firmware expects commands to be terminated by a newline.
    _socket!.writeln("$command");
    await _socket!.flush();
  }

  /// A specific helper function to send the '$STATUS#' command.
  static Future<void> getStatus() async {
    await sendRaw("\$STATUS#");
  }

  /// Closes the socket connection.
  static Future<void> disconnect() => _closeConnection();
}

