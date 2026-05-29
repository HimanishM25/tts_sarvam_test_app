import 'package:get_it/get_it.dart';
import 'package:tts_sarvam_test_app/core/network/socket_client.dart';
import 'package:tts_sarvam_test_app/presentation/cubits/recorder_screen_cubit/recorder_screen_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Network Client Registration
  sl.registerLazySingleton<SocketClient>(
    () => SocketClient("sk_y7ow09yd_lQsMm0ZrGD4lqpUdN5bRcV5o"),
  );

  // Cubit / State Management Registration
  // Factory registration ensures fresh state is instantiated when requested or rebuilt
  sl.registerFactory<RecorderScreenCubit>(
    () => RecorderScreenCubit(socketClient: sl<SocketClient>()),
  );
}
