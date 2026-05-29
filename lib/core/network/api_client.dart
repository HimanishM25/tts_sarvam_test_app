import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;
  final String _apiKey;

  ApiClient(this._dio, this._apiKey);

  Future<String> textToSpeech({
    required String text,
    required String languageCode,
    required String speaker,
  }) async {
    final response = await _dio.post(
      'https://api.sarvam.ai/text-to-speech',
      options: Options(
        headers: {
          'api-subscription-key': _apiKey,
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'saaras:v3',
        'mode': 'transcribe',
        'text': text,
        'target_language_code': languageCode,
        'speaker': speaker,
      },
    );

    final audios = response.data['audios'] as List;
    return audios.first as String;
  }
}
