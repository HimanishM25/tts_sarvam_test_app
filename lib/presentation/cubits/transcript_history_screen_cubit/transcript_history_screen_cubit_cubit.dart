import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tts_sarvam_test_app/core/storage/hive_service.dart';

part 'transcript_history_screen_cubit_state.dart';

class TranscriptHistoryScreenCubit extends Cubit<TranscriptHistoryScreenState> {
  final HiveService hiveService;

  TranscriptHistoryScreenCubit({required this.hiveService})
      : super(TranscriptHistoryScreenInitial()) {
    _init();
  }

  void _init() {
    loadHistory();
    // Register listener to update the Cubit automatically when Hive box changes
    hiveService.listenable.addListener(_onBoxChanged);
  }

  void _onBoxChanged() {
    loadHistory();
  }

  void loadHistory() {
    try {
      emit(TranscriptHistoryScreenLoading());
      final List<Map<String, dynamic>> history = hiveService.getHistory();
      emit(TranscriptHistoryScreenLoaded(history: history));
    } catch (e) {
      emit(TranscriptHistoryScreenError(message: e.toString()));
    }
  }

  Future<void> deleteTranscript(String id) async {
    try {
      await hiveService.deleteTranscription(id);
    } catch (e) {
      emit(TranscriptHistoryScreenError(message: e.toString()));
    }
  }

  Future<void> clearAllHistory() async {
    try {
      await hiveService.clearHistory();
    } catch (e) {
      emit(TranscriptHistoryScreenError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    hiveService.listenable.removeListener(_onBoxChanged);
    return super.close();
  }
}
