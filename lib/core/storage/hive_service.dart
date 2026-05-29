import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String boxName = 'transcription_history';
  late Box<Map> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(boxName);
    debugPrint('[HiveService] Hive initialized and box "$boxName" opened.');
  }

  /// Returns a listenable to reactively listen to changes in the history box
  ValueListenable<Box<Map>> get listenable => _box.listenable();

  /// Save a list of transcripts to Hive
  Future<void> saveTranscription(List<String> transcripts) async {
    if (transcripts.isEmpty) return;

    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    final DateTime now = DateTime.now();

    final Map<String, dynamic> item = {
      'id': id,
      'timestamp': now.toIso8601String(),
      'transcripts': transcripts,
    };

    await _box.put(id, item);
    debugPrint('[HiveService] Saved transcription with id: $id');
  }

  /// Retrieve all transcriptions sorted by timestamp descending
  List<Map<String, dynamic>> getHistory() {
    final List<Map<String, dynamic>> list = _box.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    
    list.sort((a, b) {
      final aTime = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.now();
      final bTime = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.now();
      return bTime.compareTo(aTime); // descending order
    });

    return list;
  }

  /// Delete a single transcription item
  Future<void> deleteTranscription(String id) async {
    await _box.delete(id);
    debugPrint('[HiveService] Deleted transcription with id: $id');
  }

  /// Clear the entire history box
  Future<void> clearHistory() async {
    await _box.clear();
    debugPrint('[HiveService] Cleared all transcription history.');
  }
}
