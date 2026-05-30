import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tts_sarvam_test_app/core/network/socket_client.dart';
import 'package:tts_sarvam_test_app/data/datasources/transcription_local_datasource.dart';
import 'package:tts_sarvam_test_app/data/models/transcript_model.dart';
import 'package:tts_sarvam_test_app/data/repo_impl/transcription_repository_impl.dart';
import 'package:tts_sarvam_test_app/domain/repository/transcription_repository.dart';
import 'package:tts_sarvam_test_app/domain/usecase/save_transcription_usecase.dart';
import 'package:tts_sarvam_test_app/domain/usecase/transcription_history_usecase.dart';
import 'package:tts_sarvam_test_app/presentation/cubits/recorder_screen_cubit/recorder_screen_cubit.dart';
import 'package:tts_sarvam_test_app/presentation/cubits/transcript_history_screen_cubit/transcript_history_screen_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TranscriptModelAdapter());

  final Box<TranscriptModel> transcriptionBox =
      await Hive.openBox<TranscriptModel>('transcription_history_v2');
  sl.registerSingleton<Box<TranscriptModel>>(transcriptionBox);

  sl.registerSingleton<TranscriptionLocalDataSource>(
    TranscriptionLocalDataSourceImpl(box: sl<Box<TranscriptModel>>()),
  );

  sl.registerSingleton<TranscriptionRepository>(
    TranscriptionRepositoryImpl(
      localDataSource: sl<TranscriptionLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<SaveTranscriptionUseCase>(
    () => SaveTranscriptionUseCase(sl<TranscriptionRepository>()),
  );
  sl.registerLazySingleton<TranscriptionHistoryUseCase>(
    () => TranscriptionHistoryUseCase(sl<TranscriptionRepository>()),
  );

  final apiKeyJson = await rootBundle.loadString(
    'lib/config/secrets/sarvam_api_key.json',
  );
  final String apiKey = jsonDecode(apiKeyJson) as String;

  sl.registerLazySingleton<SocketClient>(() => SocketClient(apiKey));

  sl.registerFactory<RecorderScreenCubit>(
    () => RecorderScreenCubit(
      socketClient: sl<SocketClient>(),
      saveTranscriptionUseCase: sl<SaveTranscriptionUseCase>(),
    ),
  );

  sl.registerFactory<TranscriptHistoryScreenCubit>(
    () => TranscriptHistoryScreenCubit(
      transcriptionHistoryUseCase: sl<TranscriptionHistoryUseCase>(),
    ),
  );
}
