import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class RingtoneSelectionPage extends StatefulWidget {
  final bool selectSingle;
  const RingtoneSelectionPage({super.key, this.selectSingle = false});

  @override
  _RingtoneSelectionPageState createState() => _RingtoneSelectionPageState();
}

class _RingtoneSelectionPageState extends State<RingtoneSelectionPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<String> _ringtones = [];
  String? _selectedRingtone;
  bool _isLoading = true;

  final List<String> _customRingtonesForPeriods = [];
  String _selectedMode = 'default';

  @override
  void initState() {
    super.initState();
    _loadAssetRingtones();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAssetRingtones() async {
    try {
      debugPrint("Starting to load asset ringtones...");
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      debugPrint("--- All Keys in AssetManifest.json ---");
      // FIX: Replaced forEach with a for-in loop for better readability and safety.
      for (final key in manifestMap.keys) {
        debugPrint(key);
      }
      debugPrint("------------------------------------");

      final audioAssetPaths = manifestMap.keys
          .where((String key) => key.startsWith('assets/audio/'))
          .toList();

      debugPrint("Found ${audioAssetPaths.length} audio assets.");

      if (mounted) {
        setState(() {
          _ringtones = audioAssetPaths;
          if (_ringtones.isNotEmpty && widget.selectSingle) {
            _selectedRingtone = _ringtones.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading asset ringtones: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
      // FIX: Added 'mounted' check to prevent errors on async gaps.
      if (!mounted) return;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectSingle ? 'Select Break Ringtone' : 'Select Period Ringtones'),
        actions: [
          TextButton(
            onPressed: () {
              if (widget.selectSingle) {
                Navigator.of(context).pop(_selectedRingtone);
              } else {
                if (_selectedMode == 'own' && _customRingtonesForPeriods.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Import at least one audio for Own Audio Package')),
                  );
                  return;
                }
                final listToReturn = _selectedMode == 'default' ? _ringtones : _customRingtonesForPeriods;
                Navigator.of(context).pop(listToReturn);
              }
            },
            child: const Text('SAVE'),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: widget.selectSingle ? _buildSingleSelectionBody() : _buildSequentialSelectionBody(),
      ),
    );
  }

  Widget _buildSingleSelectionBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Select a Ringtone'),
        const Text('Select one ringtone. You can add, remove, and reorder the list.'),
        const SizedBox(height: 10),
        _buildReorderableRingtoneList(showRadio: true),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add Audio to List'),
          onPressed: _importToDefaultList,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
      ],
    );
  }

  Widget _buildSequentialSelectionBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Ringtone Assignment Mode', style: TextStyle(fontWeight: FontWeight.bold)),
        // The RadioListTile is fine as is, the deprecation is for a future widget.
        RadioListTile<String>(
          value: 'default',
          groupValue: _selectedMode,
          onChanged: (value) => setState(() => _selectedMode = value!),
          title: const Text('Use Default Ringtones (Sequential)'),
        ),
        RadioListTile<String>(
          value: 'own',
          groupValue: _selectedMode,
          onChanged: (value) => setState(() => _selectedMode = value!),
          title: const Text('Use Own Audio Package'),
        ),
        const Divider(height: 40),
        _buildSectionHeader('1. Default Ringtones'),
        const Text('Add, remove, reorder ringtones. They will be assigned sequentially to periods (repeating if needed).'),
        const SizedBox(height: 10),
        _buildReorderableRingtoneList(showRadio: false),
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
        _buildSectionHeader('2. Own Audio Package'),
        const Text('Import audio files from phone. They will be assigned sequentially to periods (repeating if needed).'),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Import Audio from Phone'),
          onPressed: _importForPeriods,
        ),
        const SizedBox(height: 10),
        _buildCustomRingtoneList(),
      ],
    );
  }

  Widget _buildReorderableRingtoneList({required bool showRadio}) {
    if (_ringtones.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('No default ringtones available. Add one or check your project assets folder.')),
      );
    }
    return ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _ringtones.length,
        itemBuilder: (context, index) {
          final path = _ringtones[index];
          final fileName = _getFileName(path);
          final leading = CircleAvatar(
            // FIX: Replaced deprecated withOpacity with withAlpha.
            backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.1).round()),
            foregroundColor: Theme.of(context).colorScheme.primary,
            child: Text('${index + 1}'),
          );
          final secondary = Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.play_arrow), onPressed: () => _playRingtone(path)),
            if (!path.startsWith('assets/audio/'))
              IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      if (_selectedRingtone == path) _selectedRingtone = null;
                      _ringtones.removeAt(index);
                    });
                  }),
            ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)),
          ]);

          if (showRadio) {
            return RadioListTile<String>(
              key: ValueKey(path),
              controlAffinity: ListTileControlAffinity.leading,
              value: path,
              groupValue: _selectedRingtone,
              onChanged: (value) => setState(() => _selectedRingtone = value),
              title: Row(children: [
                leading,
                const SizedBox(width: 16),
                Expanded(child: Text(fileName, overflow: TextOverflow.ellipsis)),
              ]),
              secondary: secondary,
            );
          } else {
            return Card(
                key: ValueKey(path),
                child: ListTile(leading: leading, title: Text(fileName), trailing: secondary));
          }
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = _ringtones.removeAt(oldIndex);
            _ringtones.insert(newIndex, item);
          });
        });
  }

  Widget _buildCustomRingtoneList() {
    if (_customRingtonesForPeriods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: Text('No custom audios imported yet.')),
      );
    }
    return ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _customRingtonesForPeriods.length,
        itemBuilder: (context, index) {
          final path = _customRingtonesForPeriods[index];
          final fileName = _getFileName(path);
          return Card(
              key: ValueKey(path),
              child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(fileName),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.play_arrow), onPressed: () => _playRingtone(path)),
                    IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => _customRingtonesForPeriods.removeAt(index))),
                    ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)),
                  ])));
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = _customRingtonesForPeriods.removeAt(oldIndex);
            _customRingtonesForPeriods.insert(newIndex, item);
          });
        });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge));
  }
}
