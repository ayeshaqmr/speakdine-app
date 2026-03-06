import 'dart:convert';
import 'package:http/http.dart' as http;

class LLMIntentService {
  // TODO: Replace with your actual Groq or Gemini API Key
  static const String _apiKey = "YOUR_API_KEY_HERE";
  static const String _apiUrl = "https://api.groq.com/openai/v1/chat/completions";

  /// Parses the user's spoken text and returns a JSON map containing the intent.
  static Future<Map<String, dynamic>> parseIntent(String text) async {
    if (_apiKey == "YOUR_API_KEY_HERE" || _apiKey.isEmpty) {
      // Fallback to basic keyword matching if no API key is set
      return _basicFallback(text);
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama3-8b-8192", // Fast Groq Model
          "messages": [
            {
              "role": "system",
              "content": '''You are an intent parser for a food delivery app called SpeakDine.
Extract the user's intent from their text and return ONLY a valid JSON object. No markdown, no conversational text.

Valid Intents:
- "PLACE_ORDER": User wants to order food. (Include "items" list, optionally "quantities")
- "NAV_HOME": Go to home screen.
- "NAV_CART": Go to cart or view cart.
- "NAV_ORDERS": View order history.
- "NAV_PROFILE": View profile or settings.
- "SEARCH": User is searching for a specific restaurant or dish. (Include "query" string)
- "UNKNOWN": Unrelated to the app.

Output format:
{
  "intent": "<INTENT_NAME>",
  "message": "<A brief, friendly TTS response confirming the action>",
  "items": [], // Only if PLACE_ORDER
  "query": "" // Only if SEARCH
}'''
            },
            {
              "role": "user",
              "content": text
            }
          ],
          "temperature": 0.0,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        // Remove markdown block if model accidentally included it
        final cleanContent = content.replaceAll(RegExp(r'```json|```'), '').trim();
        return jsonDecode(cleanContent);
      } else {
        print("LLM Error: \${response.body}");
        return _basicFallback(text);
      }
    } catch (e) {
      print("LLM Exception: \$e");
      return _basicFallback(text);
    }
  }

  // Basic fallback parsing if API is failing
  static Map<String, dynamic> _basicFallback(String text) {
    final lower = text.toLowerCase();
    String intent = "UNKNOWN";
    String msg = "I didn't quite catch that.";

    if (lower.contains("home")) {
      intent = "NAV_HOME";
      msg = "Going home.";
    } else if (lower.contains("cart") || lower.contains("basket")) {
      intent = "NAV_CART";
      msg = "Opening your cart.";
    } else if (lower.contains("order")) {
      intent = "NAV_ORDERS";
      msg = "Here are your orders.";
    } else if (lower.contains("profile") || lower.contains("account")) {
      intent = "NAV_PROFILE";
      msg = "Opening profile.";
    } else if (lower.contains("search") || lower.contains("find")) {
      intent = "SEARCH";
      msg = "Searching for that now.";
      return {
        "intent": intent,
        "message": msg,
        "query": text.replaceAll(RegExp(r'(search for|find)', caseSensitive: false), '').trim()
      };
    } else if (lower.contains("pizza") || lower.contains("burger") || lower.contains("biryani") || lower.contains("want to eat")) {
      intent = "PLACE_ORDER";
      msg = "I can help you order that.";
      return {
        "intent": intent,
        "message": msg,
        "items": [text]
      };
    }

    return {"intent": intent, "message": msg};
  }
}
