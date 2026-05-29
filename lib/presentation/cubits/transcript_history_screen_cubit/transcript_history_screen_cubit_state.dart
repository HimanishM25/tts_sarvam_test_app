part of 'transcript_history_screen_cubit_cubit.dart';

sealed class TranscriptHistoryScreenState {}

final class TranscriptHistoryScreenInitial extends TranscriptHistoryScreenState {}

final class TranscriptHistoryScreenLoading extends TranscriptHistoryScreenState {}

final class TranscriptHistoryScreenLoaded extends TranscriptHistoryScreenState {
  final List<Map<String, dynamic>> history;
  TranscriptHistoryScreenLoaded({required this.history});
}

final class TranscriptHistoryScreenError extends TranscriptHistoryScreenState {
  final String message;
  TranscriptHistoryScreenError({required this.message});
}
