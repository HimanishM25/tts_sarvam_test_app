import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SpeechToTextResponse {
  final String type;
  final String requestId;
  final String transcript;
  final double audioDuration;
  final double processingLatency;

  SpeechToTextResponse({
    required this.type,
    required this.requestId,
    required this.transcript,
    required this.audioDuration,
    required this.processingLatency,
  });

  factory SpeechToTextResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final metrics = data['metrics'] as Map<String, dynamic>? ?? {};
    return SpeechToTextResponse(
      type: json['type'] as String? ?? '',
      requestId: data['request_id'] as String? ?? '',
      transcript: data['transcript'] as String? ?? '',
      audioDuration: (metrics['audio_duration'] as num?)?.toDouble() ?? 0.0,
      processingLatency: (metrics['processing_latency'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SocketClient {
  final String _apiKey;
  WebSocketChannel? _channel;
  bool _isConnected = false;

  SocketClient(this._apiKey);

  bool get isConnected => _isConnected;

  /// Exposes a stream of parsed responses from the WebSocket server.
  Stream<SpeechToTextResponse>? get responseStream {
    return _channel?.stream.map((event) {
      debugPrint('[SocketClient] Received event: $event');
      final Map<String, dynamic> decoded = jsonDecode(event as String);
      return SpeechToTextResponse.fromJson(decoded);
    }).handleError((error) {
      debugPrint('[SocketClient] Stream error occurred: $error');
    });
  }

  /// Connects to the Sarvam AI Speech-to-Text WebSocket endpoint.
  Future<void> connect({required String languageCode}) async {
    if (_isConnected) {
      debugPrint('[SocketClient] Connection requested, but already connected.');
      return;
    }

    final url = Uri.parse('wss://api.sarvam.ai/speech-to-text/ws?language-code=$languageCode');
    debugPrint('[SocketClient] Connecting to: $url');

    try {
      _channel = IOWebSocketChannel.connect(
        url,
        headers: {
          'api-subscription-key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      // Await the connection handshake to complete (throws on Failed host lookup)
      await _channel!.ready;

      _isConnected = true;
      debugPrint('[SocketClient] Connection established successfully.');
    } catch (e) {
      _isConnected = false;
      _channel = null;
      debugPrint('[SocketClient] Failed to establish connection: $e');
      rethrow;
    }
  }

  /// Sends a chunk of audio bytes to the WebSocket server.
  void sendAudioChunk(List<int> bytes, {int sampleRate = 16000, String encoding = 'audio/wav'}) {
    if (!_isConnected || _channel == null) {
      debugPrint('[SocketClient] Send error: Socket is not connected.');
      throw StateError('Cannot send audio. Socket is not connected.');
    }

    final base64Audio = base64Encode(bytes);
    final request = {
      'audio': {
        'data': base64Audio,
        'sample_rate': sampleRate.toString(),
        'encoding': encoding,
      }
    };

    debugPrint('[SocketClient] Sending audio chunk (${bytes.length} bytes).');
    _channel!.sink.add(jsonEncode(request));
  }

  /// Closes the connection and cleans up resources.
  Future<void> disconnect() async {
    if (!_isConnected) {
      debugPrint('[SocketClient] Disconnect requested, but already disconnected.');
      return;
    }
    debugPrint('[SocketClient] Disconnecting and closing sink.');
    await _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    debugPrint('[SocketClient] Disconnected successfully.');
  }
}
