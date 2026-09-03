import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String?> generateBookDescription({
  required String bookTitle,
  required String authorName,
  required String language,
}) async {
  // ⚠️ Remember to add your API key.
  String groqApiKey = dotenv.env['groqApiKey'] ?? '';
  const String endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  // Build the prompt dynamically.
  String prompt =
      "Write an engaging and concise book description for the book '$bookTitle' by '$authorName'. "
      "The output MUST be exactly in this language: $language. "
      "Do not include any conversational filler, just the book description.";

  try {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $groqApiKey',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({
        "model":
            "openai/gpt-oss-120b", 
        "messages": [
          {
            "role": "system",
            "content":
                "You are a professional book reviewer and copywriter. You write captivating descriptions that make people want to read the book.",
          },
          {"role": "user", "content": prompt},
        ],
        "temperature": 0.7, // A good balance between creativity and accuracy.
        "max_tokens": 400, // A suitable maximum length for a book description.
      }),
    );

    if (response.statusCode == 200) {
      // Parse the JSON. utf8.decode handles potential Arabic encoding issues.
      final responseBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseBody);
      final aiResponse = data['choices'][0]['message']['content'];

      return aiResponse.toString().trim();
    } else {
      print("Error from Groq API: ${response.statusCode} - ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error connecting to Groq: $e");
    return null;
  }
}
