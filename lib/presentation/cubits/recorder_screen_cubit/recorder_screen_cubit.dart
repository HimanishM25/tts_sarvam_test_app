import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tts_sarvam_test_app/core/network/socket_client.dart';

part 'recorder_screen_state.dart';

class RecorderScreenCubit extends Cubit<RecorderScreenState> {
  final SocketClient? socketClient;
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<SpeechToTextResponse>? _socketSubscription;
  StreamSubscription<List<int>>? _audioSubscription;
  Timer? _visualizerTimer;
  final Random _random = Random();

  RecorderScreenCubit({this.socketClient}) : super(RecorderScreenInitial());

  void toggleRecording({String languageCode = 'en-IN'}) {
    if (state.isRecording) {
      stopRecording(hasHistory: true);
    } else {
      startRecording(languageCode: languageCode);
    }
  }

  Future<void> startRecording({String languageCode = 'en-IN'}) async {
    // 1. Check microphone permission using permission_handler
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      debugPrint('[RecorderScreenCubit] Microphone permission denied.');
      emit(RecorderScreenStopped(
        transcripts: state.transcripts,
      ));
      return;
    }

    _visualizerTimer?.cancel();
    _audioSubscription?.cancel();
    _socketSubscription?.cancel();

    // 2. Connect to the socket client if available
    final client = socketClient;
    if (client != null) {
      try {
        await client.connect(languageCode: languageCode);
        
        _socketSubscription = client.responseStream?.listen(
          (response) {
            if (response.transcript.isNotEmpty) {
              final updatedTranscripts = List<String>.from(state.transcripts)
                ..add(response.transcript);
              emit(RecorderScreenRecording(
                barHeights: state.barHeights,
                transcripts: updatedTranscripts,
              ));
            }
          },
          onError: (error) {
            debugPrint('[RecorderScreenCubit] Socket stream error: $error');
            stopRecording();
          },
          onDone: () {
            debugPrint('[RecorderScreenCubit] Socket stream closed.');
            stopRecording();
          },
        );
      } catch (e) {
        debugPrint('[RecorderScreenCubit] Socket connection failed: $e');
        // Halt recording flow since the socket could not be established
        emit(RecorderScreenStopped(
          transcripts: state.transcripts,
        ));
        return;
      }
    }

    // 3. Start recording audio and streaming it to the socket
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (hasPermission) {
        final stream = await _audioRecorder.startStream(const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ));

        _audioSubscription = stream.listen((chunk) {
          if (client != null && client.isConnected) {
            client.sendAudioChunk(chunk, sampleRate: 16000, encoding: 'audio/wav');
          }
        });
        debugPrint('[RecorderScreenCubit] Real microphone recording started.');
      } else {
        debugPrint('[RecorderScreenCubit] Record package reported no permission.');
      }
    } catch (e) {
      debugPrint('[RecorderScreenCubit] Error starting audio stream: $e');
    }

    // 4. Start visualizer timer for UI heights
    _visualizerTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final newBarHeights = List.generate(
        30,
        (_) => _random.nextDouble() * 40 + 8,
      );

      emit(RecorderScreenRecording(
        barHeights: newBarHeights,
        transcripts: state.transcripts,
      ));
    });
  }

  Future<void> stopRecording({bool hasHistory = false}) async {
    _visualizerTimer?.cancel();
    _audioSubscription?.cancel();
    _socketSubscription?.cancel();
    
    try {
      await _audioRecorder.stop();
      debugPrint('[RecorderScreenCubit] Real microphone recording stopped.');
    } catch (e) {
      debugPrint('[RecorderScreenCubit] Error stopping recorder: $e');
    }

    await socketClient?.disconnect();

    emit(RecorderScreenStopped(
      transcripts: state.transcripts,
      hasHistory: hasHistory,
    ));
  }

  @override
  Future<void> close() async {
    _visualizerTimer?.cancel();
    _audioSubscription?.cancel();
    _socketSubscription?.cancel();
    await _audioRecorder.dispose();
    await socketClient?.disconnect();
    return super.close();
  }
}
