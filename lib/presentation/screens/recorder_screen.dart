import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tts_sarvam_test_app/core/constants/app_colors.dart';
import 'package:tts_sarvam_test_app/core/di/injection_container.dart';
import 'package:tts_sarvam_test_app/presentation/cubits/recorder_screen_cubit/recorder_screen_cubit.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RecorderScreenCubit>(),
      child: BlocBuilder<RecorderScreenCubit, RecorderScreenState>(
        builder: (context, state) {
          final isRecording = state.isRecording;
          final barHeights = state.barHeights;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // 1. Audio Wave (Visualizer)
                    AudioWaveWidget(
                      barHeights: barHeights,
                      isRecording: isRecording,
                    ),

                    const SizedBox(height: 24),

                    // 2. Transcription Widget
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.lightGrey,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withAlpha(5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TranscriptionWidget(
                          transcripts: state.transcripts,
                          isRecording: isRecording,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. Audio Control Widget
                    AudioControlWidget(
                      isRecording: isRecording,
                      hasHistory: state is RecorderScreenStopped && state.hasHistory,
                      onToggle: () {
                        context.read<RecorderScreenCubit>().toggleRecording();
                      },
                      onStop: () {
                        context.read<RecorderScreenCubit>().stopRecording();
                      },
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 1. Audio Wave Widget (Visualizer)
class AudioWaveWidget extends StatelessWidget {
  final List<double> barHeights;
  final bool isRecording;

  const AudioWaveWidget({
    super.key,
    required this.barHeights,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isRecording ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: barHeights.map((height) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 3.5,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(9999),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// 2. Segregated Transcription Widget
class TranscriptionWidget extends StatelessWidget {
  final List<String> transcripts;
  final bool isRecording;

  const TranscriptionWidget({
    super.key,
    required this.transcripts,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    if (transcripts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_none,
              size: 48,
              color: AppColors.textInactive.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              isRecording
                  ? 'Listening... Speak now'
                  : 'Tap the mic to start transcribing',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textInactive,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: transcripts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final transcript = transcripts[index];
        final isLast = index == transcripts.length - 1;

        return Container(
          padding: isLast ? const EdgeInsets.symmetric(vertical: 8) : EdgeInsets.zero,
          decoration: isLast
              ? const BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                )
              : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLast) const SizedBox(width: 12),
              Text(
                '00:${(index * 12).toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isLast ? AppColors.primary : AppColors.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  transcript,
                  style: TextStyle(
                    color: isLast ? AppColors.textDark : AppColors.textInactive,
                    fontSize: 18,
                    height: 1.5,
                    fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 3. Audio Control Widget
class AudioControlWidget extends StatelessWidget {
  final bool isRecording;
  final bool hasHistory;
  final VoidCallback onToggle;
  final VoidCallback onStop;

  const AudioControlWidget({
    super.key,
    required this.isRecording,
    required this.hasHistory,
    required this.onToggle,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRecording || hasHistory) ...[
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textInactive),
              onPressed: onStop,
            ),
            const SizedBox(width: 20),
          ],
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isRecording ? AppColors.primary : AppColors.black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? AppColors.primary : AppColors.black).withAlpha(38),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop : Icons.mic,
                color: AppColors.white,
                size: 28,
              ),
            ),
          ),
          if (isRecording || hasHistory) ...[
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.primary),
              onPressed: onStop,
            ),
          ],
        ],
      ),
    );
  }
}
