import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tts_sarvam_test_app/domain/entities/transcript_entity.dart';
import 'package:tts_sarvam_test_app/domain/usecase/transcription_history_usecase.dart';

part 'transcript_history_screen_state.dart';

class TranscriptHistoryScreenCubit extends Cubit<TranscriptHistoryScreenState> {
  final TranscriptionHistoryUseCase transcriptionHistoryUseCase;

  TranscriptHistoryScreenCubit({
    required this.transcriptionHistoryUseCase,
  }) : super(TranscriptHistoryScreenInitial()) {
    _init();
  }

  void _init() {
    loadHistory();
    transcriptionHistoryUseCase.listenable.addListener(_onBoxChanged);
  }

  void _onBoxChanged() {
    loadHistory();
  }

  void loadHistory() {
    try {
      emit(TranscriptHistoryScreenLoading());
      final List<TranscriptEntity> history = transcriptionHistoryUseCase.getHistory();
      emit(TranscriptHistoryScreenLoaded(history: history));
    } catch (e) {
      emit(TranscriptHistoryScreenError(message: e.toString()));
    }
  }

  Future<void> deleteTranscript(String id) async {
    try {
      await transcriptionHistoryUseCase.deleteTranscript(id);
    } catch (e) {
      emit(TranscriptHistoryScreenError(message: e.toString()));
    }
  }

  Future<void> clearAllHistory() async {
    try {
      await transcriptionHistoryUseCase.clearHistory();
    } catch (e) {
      emit(TranscriptHistoryScreenError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    transcriptionHistoryUseCase.listenable.removeListener(_onBoxChanged);
    return super.close();
  }
}
