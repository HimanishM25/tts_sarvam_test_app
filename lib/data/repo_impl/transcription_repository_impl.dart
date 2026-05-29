import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tts_sarvam_test_app/data/datasources/transcription_local_datasource.dart';
import 'package:tts_sarvam_test_app/domain/entities/transcript_entity.dart';
import 'package:tts_sarvam_test_app/domain/repository/transcription_repository.dart';

class TranscriptionRepositoryImpl implements TranscriptionRepository {
  final TranscriptionLocalDataSource localDataSource;

  const TranscriptionRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveTranscription(List<String> transcripts) {
    return localDataSource.saveTranscription(transcripts);
  }

  @override
  List<TranscriptEntity> getHistory() {
    return localDataSource.getHistory();
  }

  @override
  Future<void> deleteTranscription(String id) {
    return localDataSource.deleteTranscription(id);
  }

  @override
  Future<void> clearHistory() {
    return localDataSource.clearHistory();
  }

  @override
  ValueListenable<Box> getListenable() {
    return localDataSource.getListenable();
  }
}
