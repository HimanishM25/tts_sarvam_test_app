import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tts_sarvam_test_app/domain/entities/transcript_entity.dart';
import 'package:tts_sarvam_test_app/domain/repository/transcription_repository.dart';

class TranscriptionHistoryUseCase {
  final TranscriptionRepository repository;

  const TranscriptionHistoryUseCase(this.repository);

  List<TranscriptEntity> getHistory() {
    return repository.getHistory();
  }

  Future<void> deleteTranscript(String id) {
    return repository.deleteTranscription(id);
  }

  Future<void> clearHistory() {
    return repository.clearHistory();
  }

  ValueListenable<Box> get listenable => repository.getListenable();
}
