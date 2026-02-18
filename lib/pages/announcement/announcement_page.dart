// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
//
// class AnnouncementPage extends StatefulWidget {
//   const AnnouncementPage({super.key});
//
//   @override
//   State<AnnouncementPage> createState() => _AnnouncementPageState();
// }
//
// class _AnnouncementPageState extends State<AnnouncementPage> {
//   File? _selectedFile;
//   bool _uploading = false;
//
//   static const int maxSizeBytes = 2 * 1024 * 1024; // 2MB
//   static const String espIp = "192.168.4.1";
//   static const int espPort = 23;
//
//   Future<void> _pickMp3() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['mp3'],
//     );
//
//     if (result == null || result.files.single.path == null) return;
//
//     final file = File(result.files.single.path!);
//     final size = await file.length();
//
//     if (size > maxSizeBytes) {
//       _showError("Announcement MP3 must be under 2 MB");
//       return;
//     }
//
//     setState(() => _selectedFile = file);
//   }
//
//   Future<void> _sendToEsp32() async {
//     if (_selectedFile == null) return;
//
//     setState(() => _uploading = true);
//
//     try {
//       final bytes = await _selectedFile!.readAsBytes();
//       final fileName = "announcement.mp3";
//
//       final socket = await Socket.connect(
//         espIp,
//         espPort,
//         timeout: const Duration(seconds: 10),
//       );
//
//       // 1️⃣ Send FILE header
//       socket.add(utf8.encode('\$FILE,$fileName,${bytes.length}#'));
//       await socket.flush();
//
//       // 2️⃣ Wait for READY
//       final ready = await utf8.decoder
//           .bind(socket)
//           .firstWhere((msg) => msg.contains('READY, SEND'));
//
//       if (!ready.contains('READY')) {
//         socket.destroy();
//         throw Exception("ESP32 not ready");
//       }
//
//       // 3️⃣ Send binary MP3 (NO delays)
//       socket.add(bytes);
//       await socket.flush();
//
//       // 4️⃣ Wait for SUCCESS
//       final success = await utf8.decoder
//           .bind(socket)
//           .firstWhere((msg) => msg.contains('SUCCESS'));
//
//       if (!success.contains('SUCCESS')) {
//         socket.destroy();
//         throw Exception("Upload failed");
//       }
//
//       // 5️⃣ Play immediately
//       socket.add(utf8.encode('\$T,$fileName#'));
//       await socket.flush();
//
//       socket.destroy();
//
//       _showSuccess("Announcement played successfully");
//     } catch (e) {
//       _showError("Failed to send announcement: $e");
//     } finally {
//       setState(() => _uploading = false);
//     }
//   }
//
//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: Colors.red),
//     );
//   }
//
//   void _showSuccess(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: Colors.green),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Announcement"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Card(
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     const Icon(Icons.campaign, size: 48),
//                     const SizedBox(height: 12),
//                     const Text(
//                       "Upload Announcement MP3",
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       "File size must be under 2 MB.\nAudio will play immediately.",
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.audiotrack),
//                       label: const Text("Select MP3"),
//                       onPressed: _pickMp3,
//                     ),
//                     if (_selectedFile != null) ...[
//                       const SizedBox(height: 12),
//                       Text(
//                         _selectedFile!.path.split('/').last,
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                     ]
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton.icon(
//               icon: _uploading
//                   ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               )
//                   : const Icon(Icons.play_arrow),
//               label: const Text("PLAY ANNOUNCEMENT"),
//               onPressed: _uploading ? null : _sendToEsp32,
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 56),
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 textStyle: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }











import 'package:flutter/material.dart';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  bool _isSending = false;
  File? _recordedFile;

  // =========================
  // RECORDING
  // =========================

  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/announce.wav';

    if (await _recorder.hasPermission()) {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 256000,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordedFile = File(path);
      });
    }
  }

  Future<void> stopRecording() async {
    final path = await _recorder.stop();

    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      _recordedFile = File(path);
    }
  }

  // =========================
  // SEND TO ESP32
  // =========================

  Future<void> sendRecordedAnnouncement({
    required String espIp,
    required int espPort,
    required File wavFile,
  }) async {
    setState(() => _isSending = true);

    try {
      final bytes = await wavFile.readAsBytes();
      final fileSize = bytes.length;

      final socket = await Socket.connect(espIp, espPort);

      final cmd = "\$A,announce.wav,$fileSize#";
      socket.add(cmd.codeUnits);
      await socket.flush();

      // Wait for READY (with timeout protection)
      await socket.timeout(
        const Duration(seconds: 10),
      ).firstWhere((data) =>
          String.fromCharCodes(data).contains("ANNOUNCE READY"));

      const chunkSize = 1024;
      int offset = 0;

      while (offset < bytes.length) {
        final end = (offset + chunkSize).clamp(0, bytes.length);
        socket.add(bytes.sublist(offset, end));
        offset = end;
        await socket.flush();
      }

      socket.destroy();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Announcement Sent Successfully ✅")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }

    setState(() => _isSending = false);
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ESP32 Announcement"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Recording Status Indicator
              Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                size: 80,
                color: _isRecording ? Colors.red : Colors.grey,
              ),

              const SizedBox(height: 20),

              Text(
                _isRecording
                    ? "Recording..."
                    : _recordedFile != null
                    ? "Recording Ready"
                    : "Press Start to Record",
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 40),

              // START / STOP BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    _isRecording ? Colors.red : Colors.blue,
                  ),
                  onPressed: _isSending
                      ? null
                      : _isRecording
                      ? stopRecording
                      : startRecording,
                  child: Text(
                    _isRecording ? "Stop Recording" : "Start Recording",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // SEND BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: (_recordedFile == null ||
                      _isRecording ||
                      _isSending)
                      ? null
                      : () async {
                    await sendRecordedAnnouncement(
                      espIp: "192.168.4.1",
                      espPort: 23,
                      wavFile: _recordedFile!,
                    );
                  },
                  child: _isSending
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Send to Syncrotime",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
