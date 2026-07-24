import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String?> generateBookDescription({
  required String bookTitle,
  required String authorName,
  required String language,
}) async {
  // ⚠️ لا تنسَ وضع مفتاح الـ API الخاص بك
  String groqApiKey = dotenv.env['groqApiKey'] ?? '';
  const String endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  // تجهيز الـ Prompt بشكل ديناميكي
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
            "llama-3.3-70b-versatile", // استخدام موديل أقوى من لاما 3 للحصول على صياغة ممتازة
        "messages": [
          {
            "role": "system",
            "content":
                "You are a professional book reviewer and copywriter. You write captivating descriptions that make people want to read the book.",
          },
          {"role": "user", "content": prompt},
        ],
        "temperature": 0.7, // نسبة جيدة للتوازن بين الإبداع والدقة
        "max_tokens": 400, // حد أقصى للكلمات مناسب لوصف كتاب
      }),
    );

    if (response.statusCode == 200) {
      // معالجة الـ JSON (استخدمنا utf8.decode لحل مشاكل اللغة العربية إن وجدت)
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
