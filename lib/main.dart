import 'package:flutter/material.dart';
import 'database/dashboard_page.dart';

void main() {
  // Ensures that Flutter's widget binding is ready before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synncrotime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Using ColorScheme for more modern theming
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // Set the SplashScreen as the entry point of the app.
      // The SplashScreen will then handle navigating to the DashboardPage.
      home: const DashboardPage(),
    );
  }
}




/*
  Future<void> _uploadAudioFiles(CategoryModel category) async {
    if (!mounted) return;

    setState(() {
      _activeUploadCategoryId = category.id;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      // ---------------- LOAD PERIOD DATA ----------------
      final db = await AppDB.instance.database;
      final periodMaps = await db.query(
        'periods',
        where: 'categoryId = ?',
        whereArgs: [category.id],
      );
      final periods = periodMaps.map((p) => PeriodModel.fromMap(p)).toList();

      final Set<String> audioPaths = {};
      for (final p in periods) {
        if (p.ringtone == null || p.ringtone!.trim().isEmpty) {
          audioPaths.add('assets/default.mp3');
        } else {
          audioPaths.add(p.ringtone!);
        }
      }

      if (audioPaths.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No audio files to upload')),
        );
        return;
      }

      // ---------------- UI ----------------
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          title: Text('Uploading Audio Files'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait...'),
            ],
          ),
        ),
      );

      // ---------------- UPLOAD FILES ----------------
      for (final path in audioPaths) {
        final String fileName = _getRingtoneName(path);

        // ---- LOAD BYTES ----
        List<int> fileBytes;
        try {
          final data = await rootBundle.load(path);
          fileBytes = data.buffer.asUint8List();
        } catch (_) {
          final file = File(path);
          if (!await file.exists()) {
            throw Exception('File not found: $path');
          }
          fileBytes = await file.readAsBytes();
        }

        final int fileSize = fileBytes.length;

        // ---- CONNECT SOCKET ----
        final socket = await Socket.connect(
          espIp,
          espPort,
          timeout: const Duration(seconds: 10),
        );

        socket.setOption(SocketOption.tcpNoDelay, true);

        final completerReady = Completer<void>();
        final completerSuccess = Completer<void>();
        final buffer = StringBuffer();

        late StreamSubscription<List<int>> sub;

        sub = socket.listen(
              (data) {
            final text = String.fromCharCodes(
              data.where((b) => b >= 9 && b <= 126),
            );
            buffer.write(text);

            final full = buffer.toString();

            if (!completerReady.isCompleted &&
                full.contains('READY, SEND')) {
              completerReady.complete();
              buffer.clear();
            }

            if (!completerSuccess.isCompleted &&
                full.contains('SUCCESS:')) {
              completerSuccess.complete();
            }
          },
          onError: (e) {
            if (!completerReady.isCompleted) {
              completerReady.completeError(e);
            }
            if (!completerSuccess.isCompleted) {
              completerSuccess.completeError(e);
            }
          },
          onDone: () {
            if (!completerReady.isCompleted) {
              completerReady.completeError(
                Exception('Socket closed early'),
              );
            }
          },
        );

        // ---- SEND FILE HEADER ----
        final header = '\$FILE,$fileName,$fileSize#';
        socket.add(header.codeUnits);
        await socket.flush();

        // ---- WAIT FOR READY ----
        await completerReady.future
            .timeout(const Duration(seconds: 10));

        // ---- SEND BINARY DATA (NO DELAYS) ----
        const int chunkSize = 1024;
        int offset = 0;

        while (offset < fileBytes.length) {
          final end = (offset + chunkSize < fileBytes.length)
              ? offset + chunkSize
              : fileBytes.length;
          socket.add(fileBytes.sublist(offset, end));
          offset = end;
        }

        await socket.flush();

        // ---- WAIT FOR SUCCESS ----
        await completerSuccess.future
            .timeout(const Duration(seconds: 20));

        await sub.cancel();
        socket.destroy();

        // small pause between files
        await Future.delayed(const Duration(seconds: 1));
      }

      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _audioUploadedCategories.add(category.id!);
        });

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Audio uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _activeUploadCategoryId = null;
        });
      }
    }
  }
 */