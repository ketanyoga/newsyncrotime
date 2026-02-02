// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:audioplayers/audioplayers.dart'; // Add audioplayers to your pubspec.yaml
//
// class RingtoneSelectionPage extends StatefulWidget {
//   const RingtoneSelectionPage({super.key});
//
//   @override
//   _RingtoneSelectionPageState createState() => _RingtoneSelectionPageState();
// }
//
// class _RingtoneSelectionPageState extends State<RingtoneSelectionPage> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//
//   // --- State Variables ---
//
//   // Method 1: Pre-stored audios (replace with your actual asset paths)
//   final List<String> _preStoredRingtones = [
//     'assets/ringtones/default_bell.mp3',
//     'assets/ringtones/school_bell.mp3',
//     'assets/ringtones/modern_bell.mp3',
//   ];
//   String? _selectedPreStoredRingtone;
//
//   // Method 2 & 3: User's custom list of ringtones
//   final List<String> _customRingtones = [];
//   int _nextPeriodNumber = 1;
//
//   // Helper to play audio
//   void _playRingtone(String path) async {
//     // Check if it's an asset or a local file path
//     Source source = path.startsWith('assets/') ? AssetSource(path.replaceFirst('assets/', '')) : DeviceFileSource(path);
//     await _audioPlayer.play(source);
//   }
//
//   // Helper to pick a file from the device
//   void _importFromPhone() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.audio);
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         _customRingtones.add(result.files.single.path!);
//       });
//     }
//   }
//
//   // Helper to get a display-friendly name from a path
//   String _getFileName(String path) {
//     return path.split('/').last;
//   }
//
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Period Ringtones'),
//         actions: [
//           // This save button would pass the selected ringtone(s) back
//           TextButton(
//             onPressed: () {
//               // TODO: Implement the logic to return the selected ringtone path(s).
//               // For now, it just pops the page.
//               // Example: Navigator.of(context).pop(_selectedPreStoredRingtone);
//               Navigator.of(context).pop();
//             },
//             child: const Text('SAVE'),
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- Method 1: Pre-stored Ringtones ---
//             _buildSectionHeader('1. Use a Default Ringtone'),
//             const Text('Select one ringtone for all periods.'),
//             const SizedBox(height: 10),
//             ..._preStoredRingtones.map((path) {
//               return Card(
//                 child: RadioListTile<String>(
//                   title: Text(_getFileName(path)),
//                   value: path,
//                   groupValue: _selectedPreStoredRingtone,
//                   secondary: IconButton(
//                     icon: const Icon(Icons.play_arrow),
//                     onPressed: () => _playRingtone(path),
//                   ),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedPreStoredRingtone = value;
//                     });
//                   },
//                 ),
//               );
//             }),
//
//             const Divider(height: 40),
//
//             // --- Method 2 & 3: Custom Ringtones per Period ---
//             _buildSectionHeader('2. Assign Ringtones Period-wise'),
//             const Text('Import audio files and assign them to each period number.'),
//             const SizedBox(height: 10),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.add_circle_outline),
//               label: const Text('Import Audio from Phone'),
//               onPressed: _importFromPhone,
//             ),
//             const SizedBox(height: 10),
//
//             if (_customRingtones.isEmpty)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 20.0),
//                 child: Center(child: Text('No custom audios imported yet.')),
//               )
//             else
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: _customRingtones.length,
//                 itemBuilder: (context, index) {
//                   final path = _customRingtones[index];
//                   return Card(
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         child: Text('$index'),
//                       ),
//                       title: Text(_getFileName(path)),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.play_arrow),
//                         onPressed: () => _playRingtone(path),
//                       ),
//                       onTap: () {
//                         // TODO: Implement logic to assign this ringtone to a period
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('${_getFileName(path)} assigned to Period ${_nextPeriodNumber++}')),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Text(
//         title,
//         style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }






// lib/pages/audio/audio_selection_page.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class RingtoneSelectionPage extends StatefulWidget {
  const RingtoneSelectionPage({super.key});

  @override
  _RingtoneSelectionPageState createState() => _RingtoneSelectionPageState();
}

class _RingtoneSelectionPageState extends State<RingtoneSelectionPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<String> _ringtones = [];
  String? _selectedRingtone;
  bool _showAllRingtones = false;
  bool _isLoading = true;

  final List<String> _customRingtonesForPeriods = [];
  int _nextPeriodNumber = 1;

  @override
  void initState() {
    super.initState();
    _loadAssetRingtones();
  }

  /// Dynamically loads all audio file paths from the 'assets/audio/' directory.
  Future<void> _loadAssetRingtones() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final audioAssetPaths = manifestMap.keys
          .where((String key) => key.startsWith('assets/audio/'))
          .toList();

      setState(() {
        _ringtones = audioAssetPaths;
        if (_ringtones.isNotEmpty) {
          _selectedRingtone = _ringtones.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load asset ringtones: $e')),
      );
    }
  }

  /// Plays an audio file from either assets or device storage.
  void _playRingtone(String path) async {
    try {
      await _audioPlayer.stop();

      if (path.startsWith('assets/audio/')) {
        await _audioPlayer.play(
          AssetSource(path.replaceFirst('assets/', '')),
          volume: 1.0,
        );
      } else {
        await _audioPlayer.play(
          DeviceFileSource(path),
          volume: 1.0,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }


  void _importToDefaultList() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        final path = result.files.single.path!;
        if (!_ringtones.contains(path)) {
          _ringtones.add(path);
        }
      });
    }
  }

  void _importForPeriods() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        final path = result.files.single.path!;
        if (!_customRingtonesForPeriods.contains(path)) {
          _customRingtonesForPeriods.add(path);
        }
      });
    }
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Period Ringtones'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedRingtone);
            },
            child: const Text('SAVE'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('1. Use a Default Ringtone'),
            const Text('Select one ringtone for all periods. You can add, remove, and reorder the list.'),
            const SizedBox(height: 10),
            _buildReorderableRingtoneList(),
            if (!_isLoading && _ringtones.length > 1)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllRingtones = !_showAllRingtones;
                    });
                  },
                  child: Text(_showAllRingtones
                      ? 'View Less'
                      : 'View More (${_ringtones.length - 1} more)'),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Audio to List'),
              onPressed: _importToDefaultList,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
            const Divider(height: 40),
            _buildSectionHeader('2. Assign Ringtones Period-wise'),
            const Text('Import audio files and assign them to each period number.'),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Import Audio from Phone'),
              onPressed: _importForPeriods,
            ),
            const SizedBox(height: 10),
            _buildPeriodWiseList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableRingtoneList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final itemCount =
    _showAllRingtones ? _ringtones.length : (_ringtones.isNotEmpty ? 1 : 0);

    if (itemCount == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('No ringtones available. Add one below.')),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final path = _ringtones[index];
        return Card(
          key: ValueKey(path),
          child: RadioListTile<String>(
            controlAffinity: ListTileControlAffinity.leading,
            value: path,
            groupValue: _selectedRingtone,
            onChanged: (value) {
              setState(() {
                _selectedRingtone = value;
              });
            },
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  child: Text('${index + 1}'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(_getFileName(path)),
                ),
              ],
            ),
            secondary: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => _playRingtone(path),
                ),
                // FIX: Use the correct prefix for the check.
                if (!path.startsWith('assets/audio/'))
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        if (_selectedRingtone == path) _selectedRingtone = null;
                        _ringtones.removeAt(index);
                      });
                    },
                  ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
              ],
            ),
          ),
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _ringtones.removeAt(oldIndex);
          _ringtones.insert(newIndex, item);
        });
      },
    );
  }

  Widget _buildPeriodWiseList() {
    if (_customRingtonesForPeriods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('No custom audios imported yet.')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _customRingtonesForPeriods.length,
      itemBuilder: (context, index) {
        final path = _customRingtonesForPeriods[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(_getFileName(path)),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => _playRingtone(path),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        '${_getFileName(path)} assigned to Period ${_nextPeriodNumber++}')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}






















