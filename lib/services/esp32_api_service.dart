import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class Esp32ApiService {
  static const String espIp = "192.168.4.1";
  static const int tcpPort = 23; 

  static Socket? _socket;
  static bool _isConnected = false;
  static Completer<void>? _connectionCompleter;

  static final StreamController<String> _socketResponseController =
      StreamController<String>.broadcast();

  static final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();

  static Stream<bool> get connectionStateStream =>
      _connectionStateController.stream;

  // --- PRIVATE METHODS ---

  static Future<void> _ensureConnection() async {
    if (_isConnected && _socket != null) {
      return;
    }

    if (_connectionCompleter != null) {
      debugPrint("Connection attempt already in progress. Awaiting existing completer...");
      await _connectionCompleter!.future;
      return;
    }

    _connectionCompleter = Completer<void>();

    try {
      debugPrint("Connecting to SyncroBell device at $espIp:$tcpPort...");
      await _closeConnectionSilently();

      _socket = await Socket.connect(
        espIp,
        tcpPort,
        timeout: const Duration(seconds: 3),
      );

      _isConnected = true;
      _connectionStateController.add(true);
      debugPrint("Connected to SyncroBell device.");

      _socket!.listen(
        (data) {
          try {
            final response = utf8.decode(data).trim();
            if (response.isNotEmpty) {
              debugPrint("SyncroBell Response: $response");
              _socketResponseController.add(response);
            }
          } catch (e) {
            // Handle cases where data might not be valid UTF8 (e.g. binary echoes)
            debugPrint("Received non-UTF8 data from SyncroBell");
          }
        },
        onError: (error) {
          debugPrint("Socket Error: $error");
          _socketResponseController.addError(error);
          _closeConnection();
        },
        onDone: () {
          debugPrint("Socket Done (Disconnected)");
          _closeConnection();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint("Connection failed: $e");
      await _closeConnection();
      throw Exception("Unable to connect to SyncroBell device. Please check your Wi-Fi settings.");
    } finally {
      _connectionCompleter?.complete();
      _connectionCompleter = null;
    }
  }

  static Future<void> _closeConnectionSilently() async {
    try {
      await _socket?.close();
      _socket?.destroy();
    } catch (_) {}
    _socket = null;
  }

  static Future<void> _closeConnection() async {
    final bool wasConnected = _isConnected;
    _isConnected = false;
    await _closeConnectionSilently();
    if (wasConnected) {
      _connectionStateController.add(false);
    }
  }

  // --- PUBLIC API ---

  static Future<bool> checkConnection() async {
    if (_isConnected && _socket != null) {
      return true;
    }
    try {
      await _ensureConnection();
      return _isConnected;
    } catch (_) {
      return false;
    }
  }

  static bool get isConnected => _isConnected && _socket != null;

  static Stream<String> listen() {
    return _socketResponseController.stream;
  }

  /// Sends a raw command string. 
  /// The command should include the '#' terminator if required by the firmware.
  static Future<void> sendRaw(String command) async {
    try {
      await _ensureConnection();
      debugPrint("Sending Command: $command");
      _socket!.writeln(command);
      await _socket!.flush();
    } catch (e) {
      debugPrint("Error sending raw command ($command): $e");
      await _closeConnection();
      rethrow;
    }
  }

  /// Sends binary data (bytes) to the ESP32.
  static Future<void> sendBytes(List<int> bytes) async {
    try {
      await _ensureConnection();
      debugPrint("Sending ${bytes.length} bytes...");
      _socket!.add(bytes);
      await _socket!.flush();
    } catch (e) {
      debugPrint("Error sending bytes: $e");
      await _closeConnection();
      rethrow;
    }
  }

  /// Waits for any of the specified triggers to appear in the response stream.
  static Future<String> waitForAnyResponse(
    List<String> triggers, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final completer = Completer<String>();

    StreamSubscription<String>? sub;
    Timer? timer;

    timer = Timer(timeout, () {
      sub?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException("Timed out waiting for any of $triggers"),
        );
      }
    });

    sub = listen().listen((msg) {
      for (final trigger in triggers) {
        if (msg.contains(trigger)) {
          timer?.cancel();
          sub?.cancel();
          if (!completer.isCompleted) {
            completer.complete(msg);
          }
          break;
        }
      }
    });

    return completer.future;
  }

  /// Waits for a specific string to appear in the response stream.
  static Future<String> waitForResponse(
    String trigger, {
    Duration timeout = const Duration(seconds: 10),
  }) {
    return waitForAnyResponse([trigger], timeout: timeout);
  }

  /// Triggers the playback of a specific file on the device ($T command).
  static Future<void> playFile(String filename) async {
    await sendRaw("\$T,$filename#");
  }

  static Future<void> getStatus() async {
    await sendRaw("\$STATUS#");
  }

  static Future<void> disconnect() => _closeConnection();
}
