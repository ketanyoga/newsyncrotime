import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bell_mqtt_service.dart';

class Esp32ApiService {
  static String espIp = "192.168.4.1";
  static const int tcpPort = 23; 

  static Future<void> loadSavedIp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('saved_device_ip');
      if (saved != null && saved.isNotEmpty) {
        espIp = saved;
      }
    } catch (_) {}
  }

  static Future<void> setDeviceIp(String ip) async {
    espIp = ip;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_device_ip', ip);
    } catch (_) {}
    _apModeAvailable = true; // Reset so new IP is tried
    await _closeConnection();
  }

  static Socket? _socket;
  static bool _isConnected = false;
  static Completer<void>? _connectionCompleter;

  static final StreamController<String> _socketResponseController =
      StreamController<String>.broadcast();

  static final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();

  static Stream<bool> get connectionStateStream =>
      _connectionStateController.stream;

  static StreamSubscription<String>? _mqttRespSub;
  static StreamSubscription<bool>? _mqttOnlineSub;

  static void init() {
    _mqttRespSub ??= BellMqttService.responses.listen((msg) {
      _socketResponseController.add(msg);
    });
    _mqttOnlineSub ??= BellMqttService.online.listen((online) {
      _connectionStateController.add(online || (_isConnected && _socket != null));
    });
    BellMqttService.connect().catchError((_) {});
  }

  static bool _apModeAvailable = true;
  static DateTime? _lastApFailTime;

  // --- PRIVATE METHODS ---

  static Future<void> _ensureConnection() async {
    if (_isConnected && _socket != null) {
      return;
    }

    if (!_apModeAvailable && _lastApFailTime != null && DateTime.now().difference(_lastApFailTime!).inSeconds < 10) {
      throw SocketException("AP/IP mode recently failed, skipping local connect.");
    }

    if (_connectionCompleter != null) {
      debugPrint("Connection attempt already in progress. Awaiting existing completer...");
      await _connectionCompleter!.future;
      if (!_isConnected) throw SocketException("Connection in progress failed.");
      return;
    }

    _connectionCompleter = Completer<void>();

    try {
      debugPrint("Connecting to SyncroBell device at $espIp:$tcpPort...");
      await _closeConnectionSilently();

      _socket = await Socket.connect(
        espIp,
        tcpPort,
        timeout: const Duration(seconds: 1),
      );

      _isConnected = true;
      _apModeAvailable = true;
      _lastApFailTime = null;
      _connectionStateController.add(true);
      debugPrint("Connected to SyncroBell device via Local AP/IP ($espIp).");

      _socket!.listen(
        (data) {
          try {
            final response = utf8.decode(data).trim();
            if (response.isNotEmpty) {
              debugPrint("SyncroBell Response: $response");
              _socketResponseController.add(response);
            }
          } catch (e) {
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
      debugPrint("Local connection failed: $e");
      _apModeAvailable = false;
      _lastApFailTime = DateTime.now();
      await _closeConnection();
      rethrow;
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
    // 1. Try local AP/IP socket first if available
    if (_isConnected && _socket != null) return true;
    try {
      await _ensureConnection();
      if (_isConnected && _socket != null) return true;
    } catch (_) {}

    // 2. Fallback to MQTT
    try {
      await BellMqttService.connect();
      if (BellMqttService.isConnected) return true;
    } catch (_) {}

    return false;
  }

  static bool get isConnected => (_isConnected && _socket != null) || BellMqttService.isConnected;

  static Stream<String> listen() {
    return _socketResponseController.stream;
  }

  /// Sends a raw command string. 
  /// Prioritizes local TCP socket (AP/IP mode) if nearby, otherwise falls back to MQTT (Cloud mode).
  static Future<void> sendRaw(String command) async {
    // 1. Try local AP/IP socket first
    if (_isConnected && _socket != null) {
      try {
        debugPrint("Sending Command via Local Socket: $command");
        _socket!.writeln(command);
        await _socket!.flush();
        return;
      } catch (_) {
        await _closeConnection();
      }
    }

    try {
      await _ensureConnection();
      if (_isConnected && _socket != null) {
        debugPrint("Sending Command via Local Socket: $command");
        _socket!.writeln(command);
        await _socket!.flush();
        return;
      }
    } catch (e) {
      debugPrint("Local socket unavailable, falling back to MQTT: $e");
    }

    // 2. Fallback to MQTT (Cloud mode)
    try {
      await BellMqttService.connect();
      if (BellMqttService.isConnected) {
        debugPrint("Sending Command via MQTT: $command");
        await BellMqttService.sendCommand(command);
        return;
      }
    } catch (e) {
      debugPrint("MQTT send failed: $e");
      rethrow;
    }

    throw Exception("Device not connected via Local AP or MQTT.");
  }

  /// Sends binary data (bytes) to the ESP32.
  /// Prioritizes local TCP socket (AP/IP mode) if nearby, otherwise falls back to MQTT in chunks.
  static Future<void> sendBytes(List<int> bytes) async {
    // 1. If local socket is connected, use it exclusively
    if (_isConnected && _socket != null) {
      try {
        debugPrint("Sending ${bytes.length} bytes via Local Socket...");
        _socket!.add(bytes);
        await _socket!.flush();
        return;
      } catch (e) {
        debugPrint("Local socket error during file transfer: $e");
        await _closeConnection();
        rethrow;
      }
    }

    try {
      await _ensureConnection();
      if (_isConnected && _socket != null) {
        debugPrint("Sending ${bytes.length} bytes via Local Socket...");
        _socket!.add(bytes);
        await _socket!.flush();
        return;
      }
    } catch (e) {
      debugPrint("Local socket unavailable for bytes: $e");
    }

    // 2. Fallback to MQTT (split into MQTT-safe chunks of 2000 bytes)
    try {
      await BellMqttService.connect();
      if (BellMqttService.isConnected) {
        debugPrint("Sending ${bytes.length} bytes via MQTT in chunks...");
        const mqttChunkSize = 2000;
        int offset = 0;
        while (offset < bytes.length) {
          final end = (offset + mqttChunkSize).clamp(0, bytes.length);
          final subChunk = bytes.sublist(offset, end);
          await BellMqttService.sendFileBytes(subChunk);
          offset = end;
          await Future.delayed(const Duration(milliseconds: 5));
        }
        return;
      }
    } catch (e) {
      debugPrint("MQTT sendBytes failed: $e");
      rethrow;
    }

    throw Exception("Device not connected via Local AP or MQTT for file transfer.");
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

  /// Triggers a manual ring with a specified duration and optional filename.
  static Future<void> manualRing(int duration, {String filename = "SchoolBell.mp3"}) async {
    await sendRaw("\$D,$duration#");
    await Future.delayed(const Duration(milliseconds: 50));
    await sendRaw("\$T,$filename#");
  }

  static Future<void> getStatus() async {
    await sendRaw("\$STATUS#");
  }

  static Future<void> disconnect() => _closeConnection();
}
