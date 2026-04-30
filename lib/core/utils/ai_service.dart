import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Custom app-level exception
class AppException implements Exception {
  final String message;
  final String? debugMessage;

  AppException(this.message, {this.debugMessage});

  @override
  String toString() => message;
}

class AiService {
  String get _apiKey => dotenv.get('GROQ_API_KEY', fallback: '');
  String get _apiUrl =>
      dotenv.get('GROQ_API_URL', fallback: 'https://api.groq.com/openai/v1/chat/completions');

  /// Retry wrapper for network calls
  Future<http.Response> _postWithRetry(
    Uri url,
    Map<String, String> headers,
    String body,
  ) async {
    const retries = 2;

    for (int i = 0; i <= retries; i++) {
      try {
        return await http
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        if (i == retries) rethrow;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    throw AppException('Unexpected network failure');
  }

  String _buildSystemPrompt({
    required String platform,
    required String style,
    required String type,
    required bool includeEmojis,
    required bool includeHashtags,
  }) {
    final emojiInstruction = includeEmojis
        ? "Include relevant emojis to make it engaging."
        : "Do NOT use any emojis; keep it text-only.";

    final hashtagInstruction = includeHashtags
        ? "Include about 5-10 relevant hashtags at the end."
        : "Do NOT include hashtags.";

    return '''
You are an expert social media copywriter. Generate 3 distinct and creative $type options for $platform in a $style style.
$emojiInstruction
${(type == 'Caption' || type == 'Quotes') ? hashtagInstruction : ''}
If $type is "Hashtags", provide a set of about 15-20 relevant hashtags for the given context, separated by spaces.
If $type is "Quotes", generate short, impactful, and inspiring quotes related to the provided category.
The user will provide the topic or context.
Return ONLY a JSON array of strings.
Example:
["Option 1", "Option 2", "Option 3"]
''';
  }

  Future<List<String>> generateContent({
    required String prompt,
    required String platform,
    required String style,
    required String type,
    bool includeEmojis = true,
    bool includeHashtags = true,
  }) async {
    try {
      final systemPrompt = _buildSystemPrompt(
        platform: platform,
        style: style,
        type: type,
        includeEmojis: includeEmojis,
        includeHashtags: includeHashtags,
      );

      final response = await _postWithRetry(
        Uri.parse(_apiUrl),
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        try {
          final List<dynamic> parsed = jsonDecode(content);
          return parsed.map((e) => e.toString()).toList();
        } catch (_) {
          // Robust fallback parsing
          final cleaned = content
              .replaceAll(RegExp(r'^\[|\]$'), '')
              .split(RegExp(r'","|"\s*,\s*"'));

          return cleaned
              .map((e) => e.replaceAll('"', '').trim())
              .where((e) => e.isNotEmpty)
              .take(3)
              .toList();
        }
      } else {
        throw AppException(
          'Something went wrong. Please try again.',
          debugMessage: response.body,
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;

      throw AppException(
        'Unable to connect. Please check your internet.',
        debugMessage: e.toString(),
      );
    }
  }
}