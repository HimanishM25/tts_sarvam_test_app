part of 'recorder_screen_cubit.dart';

@immutable
sealed class RecorderScreenState {
  final bool isRecording;
  final List<double> barHeights;
  final List<String> transcripts;

  const RecorderScreenState({
    required this.isRecording,
    required this.barHeights,
    required this.transcripts,
  });
}

final class RecorderScreenInitial extends RecorderScreenState {
  RecorderScreenInitial()
      : super(
          isRecording: false,
          barHeights: List.filled(30, 8.0),
          transcripts: const [],
        );
}

final class RecorderScreenRecording extends RecorderScreenState {
  const RecorderScreenRecording({
    required super.barHeights,
    required super.transcripts,
  }) : super(
          isRecording: true,
        );
}

final class RecorderScreenStopped extends RecorderScreenState {
  final bool hasHistory;

  RecorderScreenStopped({
    required super.transcripts,
    this.hasHistory = false,
  }) : super(
          isRecording: false,
          barHeights: List.filled(30, 8.0),
        );
}
