import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tts_sarvam_test_app/data/models/transcript_model.dart';

abstract class TranscriptionLocalDataSource {
  Future<void> saveTranscription(List<String> transcripts);
  List<TranscriptModel> getHistory();
  Future<void> deleteTranscription(String id);
  Future<void> clearHistory();
  ValueListenable<Box<TranscriptModel>> getListenable();
}

class TranscriptionLocalDataSourceImpl implements TranscriptionLocalDataSource {
  final Box<TranscriptModel> box;

  TranscriptionLocalDataSourceImpl({required this.box});

  @override
  Future<void> saveTranscription(List<String> transcripts) async {
    if (transcripts.isEmpty) return;

    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    final DateTime now = DateTime.now();

    final model = TranscriptModel(
      id: id,
      timestamp: now,
      transcripts: transcripts,
    );

    await box.put(id, model);
    debugPrint('[TranscriptionLocalDataSourceImpl] Saved transcription ID: $id');
  }

  @override
  List<TranscriptModel> getHistory() {
    final list = box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  @override
  Future<void> deleteTranscription(String id) async {
    await box.delete(id);
    debugPrint('[TranscriptionLocalDataSourceImpl] Deleted transcription ID: $id');
  }

  @override
  Future<void> clearHistory() async {
    await box.clear();
    debugPrint('[TranscriptionLocalDataSourceImpl] Cleared all history.');
  }

  @override
  ValueListenable<Box<TranscriptModel>> getListenable() => box.listenable();
}
