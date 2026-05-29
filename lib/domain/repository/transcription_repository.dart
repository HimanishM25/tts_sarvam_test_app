import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tts_sarvam_test_app/domain/entities/transcript_entity.dart';

abstract class TranscriptionRepository {
  Future<void> saveTranscription(List<String> transcripts);
  List<TranscriptEntity> getHistory();
  Future<void> deleteTranscription(String id);
  Future<void> clearHistory();
  ValueListenable<Box> getListenable();
}
