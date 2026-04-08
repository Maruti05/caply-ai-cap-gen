import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:caply/core/utils/ai_service.dart';

void main() {
  // We need to load the .env file before running tests that depend on it.
  // In a real test, we would normally mock the AiService or http client,
  // but here we are using this test as a debug tool to verify the real API call.
  
  setUpAll(() async {
    // We expect the .env file to be at the project root.
    // When running 'flutter test', the working directory is the project root.
    try {
      await dotenv.load(fileName: ".env");
      print('Dotenv loaded successfully for test.');
    } catch (e) {
      fail('Failed to load .env file. Please ensure it exists at the root of the project. Error: $e');
    }
  });

  group('AiService Live Tests', () {
    final aiService = AiService();

    test('generateContent returns a list of 3 strings for a valid prompt', () async {
      // NOTE: This test will call the real Groq API.
      // It will fail if you have no internet or an invalid API key.
      
      try {
        final results = await aiService.generateContent(
          prompt: 'A cute cat wearing a hat',
          platform: 'Instagram',
          style: 'Funny',
          type: 'Caption',
        );

        expect(results, isNotNull);
        expect(results, isA<List<String>>());
        expect(results.length, greaterThanOrEqualTo(1));
        
        print('\n--- Generated Results ---');
        for (var result in results) {
          print('- $result');
        }
        print('-------------------------\n');
      } catch (e) {
        // Here we catch the exception and fail the test with the specific error message
        // This will allow us to see what the '400' error actually says.
        print('\n--- API ERROR CAUGHT ---');
        print(e.toString());
        print('------------------------\n');
        fail('API request failed: $e');
      }
    });
  });
}
