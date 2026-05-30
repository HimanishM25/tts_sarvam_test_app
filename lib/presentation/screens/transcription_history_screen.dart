import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tts_sarvam_test_app/core/constants/app_colors.dart';
import 'package:tts_sarvam_test_app/core/constants/app_strings.dart';
import 'package:tts_sarvam_test_app/core/di/injection_container.dart';
import 'package:tts_sarvam_test_app/presentation/cubits/transcript_history_screen_cubit/transcript_history_screen_cubit.dart';

class TranscriptionHistoryScreen extends StatelessWidget {
  const TranscriptionHistoryScreen({super.key});

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year;

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TranscriptHistoryScreenCubit>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              title: const Text(
                AppStrings.historyAppBarTitle,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              actions: [
                BlocBuilder<
                  TranscriptHistoryScreenCubit,
                  TranscriptHistoryScreenState
                >(
                  builder: (context, state) {
                    if (state is TranscriptHistoryScreenLoaded &&
                        state.history.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(
                          Icons.delete_sweep,
                          color: AppColors.red,
                        ),
                        tooltip: AppStrings.historyClearAllTooltip,
                        onPressed: () => _confirmClearAll(context),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(color: AppColors.lightGrey, height: 1.0),
              ),
            ),
            body:
                BlocBuilder<
                  TranscriptHistoryScreenCubit,
                  TranscriptHistoryScreenState
                >(
                  builder: (context, state) {
                    if (state is TranscriptHistoryScreenLoading ||
                        state is TranscriptHistoryScreenInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      );
                    }

                    if (state is TranscriptHistoryScreenError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textInactive,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is TranscriptHistoryScreenLoaded) {
                      final history = state.history;

                      if (history.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.history,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                AppStrings.historyNoTranscriptions,
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                AppStrings.historyEmptySub,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];
                          final String id = item.id;
                          final DateTime timestamp = item.timestamp;
                          final List<String> transcripts = item.transcripts;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.lightGrey),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withAlpha(8),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatDateTime(timestamp),
                                            style: const TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: AppColors.textGrey,
                                        ),
                                        onPressed: () => context
                                            .read<
                                              TranscriptHistoryScreenCubit
                                            >()
                                            .deleteTranscript(id),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(
                                    color: AppColors.lightGrey,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 12),

                                  ...transcripts.map((text) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            width: 5,
                                            height: 5,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              text,
                                              style: const TextStyle(
                                                color: AppColors.textInactive,
                                                fontSize: 16,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
          );
        },
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.clearDialogTitle),
          content: const Text(AppStrings.clearDialogContent),
          actions: <Widget>[
            TextButton(
              child: const Text(
                AppStrings.clearDialogCancel,
                style: TextStyle(color: AppColors.textGrey),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text(
                AppStrings.clearDialogConfirm,
                style: TextStyle(color: AppColors.red),
              ),
              onPressed: () {
                context.read<TranscriptHistoryScreenCubit>().clearAllHistory();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
