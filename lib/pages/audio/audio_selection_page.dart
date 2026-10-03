import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RingtoneSelectionPage extends StatefulWidget {
  final bool selectSingle;
  final dynamic initialSelection;
  final bool showOnlyLunch;
  const RingtoneSelectionPage({super.key, this.selectSingle = false, this.initialSelection, this.showOnlyLunch = false});

  @override
  RingtoneSelectionPageState createState() => RingtoneSelectionPageState();
}

class RingtoneSelectionPageState extends State<RingtoneSelectionPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<String> _builtInRingtones = [];
  final List<String> _deviceRingtones = [];
  
  // Stores the selected paths in order
  final List<String> _selectedPaths = [];
  
  String? _currentlyPlaying;
  bool _isLoading = true;
  String _activeTab = 'builtin'; // 'builtin' or 'device'

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection != null) {
      if (widget.selectSingle && widget.initialSelection is String) {
        _selectedPaths.add(widget.initialSelection as String);
      } else if (!widget.selectSingle && widget.initialSelection is List<String>) {
        _selectedPaths.addAll(widget.initialSelection as List<String>);
      }
    }
    _loadAssetRingtones();
    _loadUserRingtones();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadUserRingtones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> saved = prefs.getStringList('user_imported_ringtones') ?? [];
      final List<String> validPaths = [];
      for (final path in saved) {
        if (await File(path).exists()) {
          validPaths.add(path);
        }
      }
      if (!mounted) return;
      setState(() {
        _deviceRingtones.clear();
        _deviceRingtones.addAll(validPaths);
      });
    } catch (e) {
      debugPrint("Error loading user ringtones: $e");
    }
  }

  Future<void> _loadAssetRingtones() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> restrictedNames = ["assembly.mp3", "emergency.mp3", "lunch.mp3"];
      
      final audioAssetPaths = manifest.listAssets()
          .where((path) => path.startsWith('assets/audio/'))
          .where((path) {
            final name = path.split('/').last.toLowerCase();
            
            // If showOnlyLunch is true, ONLY show lunch.mp3
            if (widget.showOnlyLunch) {
              return name == "lunch.mp3";
            }
            
            // Otherwise, show everything EXCEPT restricted ones
            return !restrictedNames.contains(name);
          })
          .toList();

      if (!mounted) return;

      setState(() {
        _builtInRingtones = audioAssetPaths;
        
        // AUTO-SELECT ALL by default for sequential mode if no initial selection exists
        if (!widget.selectSingle && widget.initialSelection == null) {
          _selectedPaths.clear();
          _selectedPaths.addAll(_builtInRingtones);
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _togglePlayback(String path) async {
    if (_currentlyPlaying == path) {
      await _audioPlayer.stop();
      setState(() => _currentlyPlaying = null);
    } else {
      try {
        await _audioPlayer.stop();
        if (path.startsWith('assets/audio/')) {
          await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
        } else {
          await _audioPlayer.play(DeviceFileSource(path));
        }
        setState(() => _currentlyPlaying = path);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _importFromDevice() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        final originalPath = result.files.single.path!;
        final file = File(originalPath);
        if (!await file.exists()) return;

        final appDir = await getApplicationDocumentsDirectory();
        final fileName = originalPath.split('/').last.split(r'\').last;
        final targetPath = '${appDir.path}/$fileName';

        final savedFile = await file.copy(targetPath);

        final prefs = await SharedPreferences.getInstance();
        final List<String> saved = prefs.getStringList('user_imported_ringtones') ?? [];
        if (!saved.contains(savedFile.path)) {
          saved.add(savedFile.path);
          await prefs.setStringList('user_imported_ringtones', saved);
        }

        if (!mounted) return;
        setState(() {
          if (!_deviceRingtones.contains(savedFile.path)) {
            _deviceRingtones.add(savedFile.path);
          }
          _activeTab = 'device';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported $fileName successfully!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing audio: $e')),
      );
    }
  }

  void _handleSelection(String path) {
    setState(() {
      if (widget.selectSingle) {
        _selectedPaths.clear();
        _selectedPaths.add(path);
      } else {
        if (_selectedPaths.contains(path)) {
          _selectedPaths.remove(path);
        } else {
          _selectedPaths.add(path);
        }
      }
    });
  }

  void _toggleSelectAll() {
    final currentList = _activeTab == 'builtin' ? _builtInRingtones : _deviceRingtones;
    final allInTabSelected = currentList.every((path) => _selectedPaths.contains(path));

    setState(() {
      if (allInTabSelected) {
        // Deselect all from this tab
        _selectedPaths.removeWhere((path) => currentList.contains(path));
      } else {
        // Select all from this tab (sequentially)
        for (final path in currentList) {
          if (!_selectedPaths.contains(path)) {
            _selectedPaths.add(path);
          }
        }
      }
    });
  }

  String _getFileName(String path) => path.split('/').last;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabSelector(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildAudioList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.chevron_left, color: Color(0xFF007AFF), size: 28),
                    Text("Back", style: TextStyle(color: Color(0xFF007AFF), fontSize: 17)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.selectSingle ? "Select Sound" : "Select Sequence",
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          ),
          Text(
            widget.selectSingle 
              ? "Pick a ringtone for this slot" 
              : "Select multiple sounds in the order you want them played",
            style: const TextStyle(fontSize: 15, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _tabButton("Built-in", 'builtin'),
                _tabButton("Import", 'device'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabButton(String label, String value) {
    final bool active = _activeTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active ? [BoxShadow(color: Colors.black.withAlpha((255 * 0.1).round()), blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? Colors.black : const Color(0xFF8E8E93),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioList() {
    final list = _activeTab == 'builtin' ? _builtInRingtones : _deviceRingtones;
    
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.audiotrack_outlined, size: 64, color: Color(0xFFC7C7CC)),
            const SizedBox(height: 16),
            Text(
              _activeTab == 'builtin' ? "No built-in sounds found" : "No device sounds imported",
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 17),
            ),
            if (_activeTab == 'device')
              TextButton(onPressed: _importFromDevice, child: const Text("Import from Phone")),
          ],
        ),
      );
    }

    final bool showBulkSelect = !widget.selectSingle && _activeTab == 'builtin';
    final int itemCount = showBulkSelect ? list.length + 1 : list.length;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (showBulkSelect) {
          if (index == 0) return _buildSelectAllTile();
          index -= 1;
        }

        final path = list[index];
        final name = _getFileName(path);
        final bool isSelected = _selectedPaths.contains(path);
        final int selectIndex = _selectedPaths.indexOf(path) + 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _handleSelection(path),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    _buildSelectionIndicator(isSelected, selectIndex),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                          Text(_activeTab == 'builtin' ? "System Audio" : "User Import", style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(_currentlyPlaying == path ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded),
                      color: const Color(0xFF007AFF),
                      iconSize: 32,
                      onPressed: () => _togglePlayback(path),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectAllTile() {
    final bool allSelected = _builtInRingtones.isNotEmpty && 
        _builtInRingtones.every((p) => _selectedPaths.contains(p));
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: const Color(0xFF007AFF).withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _toggleSelectAll,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  allSelected ? Icons.check_circle_rounded : Icons.select_all_rounded,
                  color: const Color(0xFF007AFF),
                  size: 28,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Select All Defaults", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF007AFF))),
                      Text("Quickly assign all standard school bells", style: TextStyle(fontSize: 13, color: Color(0xFF007AFF))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected, int index) {
    if (widget.selectSingle) {
      return Icon(
        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        color: isSelected ? const Color(0xFF34C759) : const Color(0xFFC7C7CC),
        size: 28,
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
        border: Border.all(color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFC7C7CC), width: 2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isSelected 
          ? Text("$index", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))
          : null,
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          if (_activeTab == 'device') ...[
            IconButton(
              icon: const Icon(Icons.add_to_photos_rounded, color: Color(0xFF007AFF)),
              onPressed: _importFromDevice,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedPaths.isEmpty ? null : () {
                if (widget.selectSingle) {
                  Navigator.of(context).pop(_selectedPaths.first);
                } else {
                  Navigator.of(context).pop(_selectedPaths);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFF2F2F7),
                disabledForegroundColor: const Color(0xFFC7C7CC),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                _selectedPaths.isEmpty ? "SELECT AUDIO" : "SAVE SELECTION (${_selectedPaths.length})",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
