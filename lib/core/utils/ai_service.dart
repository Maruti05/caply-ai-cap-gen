import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  String get _apiKey => dotenv.get('GROQ_API_KEY', fallback: '');
  String get _apiUrl => dotenv.get('GROQ_API_URL', fallback: 'https://api.groq.com/openai/v1/chat/completions');

  Future<List<String>> generateContent({
    required String prompt,
    required String platform,
    required String style,
    required String type,
    bool includeEmojis = true,
    bool includeHashtags = true,
  }) async {
    final emojiInstruction = includeEmojis 
        ? "Include relevant emojis to make it engaging." 
        : "Do NOT use any emojis; keep it text-only.";

    final hashtagInstruction = includeHashtags
        ? "Include about 5-10 relevant hashtags at the end."
        : "Do NOT include hashtags.";

    final systemPrompt = '''
You are an expert social media copywriter. Generate 3 distinct and creative $type options for $platform in a $style style.
$emojiInstruction
${(type == 'Caption' || type == 'Quotes') ? hashtagInstruction : ''}
If $type is "Hashtags", provide a set of about 15-20 relevant hashtags for the given context, separated by spaces.
If $type is "Quotes", generate short, impactful, and inspiring quotes related to the provided category.
The user will provide the topic or context.
Return ONLY a JSON array of strings, where each string is an option (a caption, a bio, a quote, or a set of hashtags). 
Example format:
["Option 1", "Option 2", "Option 3"]
No other text, just the JSON array.
''';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
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
        } catch (e) {
          // Fallback if not pure JSON array
          final options = content.split(RegExp(r'\n\n|\n[0-9]\. '));
          return options.where((e) => e.trim().isNotEmpty).take(3).toList();
        }
      } else {
        String errorMessage = 'Failed to generate content: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null && errorData['error']['message'] != null) {
            errorMessage = errorData['error']['message'];
          }
        } catch (_) {
          // If body is not JSON, just include it as text
          errorMessage += ' - ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Network or formatting error: $e');
    }
  }
}
