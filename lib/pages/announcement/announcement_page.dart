import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  File? _selectedFile;
  bool _uploading = false;

  static const int maxSizeBytes = 2 * 1024 * 1024; // 2MB
  static const String espIp = "192.168.4.1";

  Future<void> _pickMp3() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final size = await file.length();

    if (size > maxSizeBytes) {
      _showError("Announcement MP3 must be under 2 MB");
      return;
    }

    setState(() => _selectedFile = file);
  }

  Future<void> _sendToEsp32() async {
    if (_selectedFile == null) return;

    setState(() => _uploading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("http://$espIp/announcement"),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedFile!.path,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        _showSuccess("Announcement played successfully");
      } else {
        _showError("ESP32 error while playing announcement");
      }
    } catch (e) {
      _showError("Failed to connect to ESP32");
    } finally {
      setState(() => _uploading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcement"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.campaign, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      "Upload Announcement MP3",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "File size must be under 2 MB.\nAudio will play immediately.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.audiotrack),
                      label: const Text("Select MP3"),
                      onPressed: _pickMp3,
                    ),
                    if (_selectedFile != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _selectedFile!.path.split('/').last,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: _uploading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.play_arrow),
              label: const Text("PLAY ANNOUNCEMENT"),
              onPressed: _uploading ? null : _sendToEsp32,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
