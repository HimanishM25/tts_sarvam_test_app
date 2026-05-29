import 'package:tts_sarvam_test_app/domain/repository/transcription_repository.dart';

class SaveTranscriptionUseCase {
  final TranscriptionRepository repository;

  const SaveTranscriptionUseCase(this.repository);

  Future<void> call(List<String> transcripts) {
    return repository.saveTranscription(transcripts);
  }
}
