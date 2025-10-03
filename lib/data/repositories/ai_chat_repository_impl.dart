import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:monumento/domain/repositories/ai_chat_repository.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  static final String deepSeekApiBaseUrl = dotenv.env['DeepSeek_Api_BaseUrl']!;
  static final String deepSeekApiKey = dotenv.env['DeepSeek_Api_Key']!;

  // HTTP client with timeout
  static final http.Client _httpClient = http.Client();

  @override
  Future<String> sendMessage({
    required String message,
    required String monumentName,
    required String monumentDescription,
    required String monumentLocation,
  }) async {
    try {
      // Build context-aware system prompt
      final systemPrompt = _buildSystemPrompt(
        monumentName: monumentName,
        monumentDescription: monumentDescription,
        monumentLocation: monumentLocation,
      );

      // Prepare request body
      final requestBody = {
        'model': "deepseek/deepseek-chat", // or whatever the model ID is
        'messages': [
          {
            'role': 'system',
            'content': systemPrompt,
          },
          {
            'role': 'user',
            'content': message,
          }
        ],
        'max_tokens': 1000,
        'temperature': 0.3, // Lower temperature for more consistent results
      };

      // Make HTTP request with timeout
      final response = await _httpClient
          .post(
        Uri.parse(deepSeekApiBaseUrl),
        headers: _buildHeaders(),
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw const SocketException('Request timeout');
        },
      );

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw _handleNetworkError(e);
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $deepSeekApiKey',
    };
  }

  String _buildSystemPrompt({
    required String monumentName,
    required String monumentDescription,
    required String monumentLocation,
  }) {
    return '''
You are a knowledgeable cultural heritage expert and travel guide specializing in historical monuments and tourist attractions.

MONUMENT CONTEXT:
- Name: $monumentName
- Location: $monumentLocation
- Description: ${monumentDescription.length > 500 ? monumentDescription.substring(0, 500) + '...' : monumentDescription}

INSTRUCTIONS:
- Provide helpful, accurate, and concise answers (1-3 sentences maximum)
- Focus on practical information for visitors
- Cover topics like: visiting hours, best times to visit, historical significance, architectural features, nearby attractions, travel tips, cultural importance
- Be friendly and engaging
- If you don't have specific information about this monument, provide general helpful advice for similar historical sites
- Avoid speculation - stick to factual information or clearly indicate when giving general advice

RESPONSE STYLE:
- Keep responses brief and conversational
- Use simple, clear language
- Prioritize actionable information
- Be enthusiastic but professional
''';
  }

  // Handle HTTP response
  String _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return _parseSuccessResponse(response.body);
      case 400:
        throw Exception(
            'Invalid request. Please check your message and try again.');
      case 401:
        throw Exception('API authentication failed. Please contact support.');
      case 429:
        throw Exception(
            'Too many requests. Please wait a moment and try again.');
      case 500:
      case 502:
      case 503:
        throw Exception(
            'AI service temporarily unavailable. Please try again later.');
      default:
        throw Exception(
            'Service error (${response.statusCode}). Please try again.');
    }
  }

  // Parse successful response
  String _parseSuccessResponse(String responseBody) {
    try {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;

      // Validate response structure
      if (!data.containsKey('choices') ||
          data['choices'] == null ||
          (data['choices'] as List).isEmpty) {
        throw const FormatException('Invalid response structure');
      }

      final choices = data['choices'] as List;
      final firstChoice = choices[0] as Map<String, dynamic>;

      if (!firstChoice.containsKey('message') ||
          firstChoice['message'] == null) {
        throw const FormatException('Missing message in response');
      }

      final message = firstChoice['message'] as Map<String, dynamic>;
      final content = message['content'] as String?;

      if (content == null || content.trim().isEmpty) {
        throw const FormatException('Empty response content');
      }

      return content.trim();
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Failed to parse response: $e');
    }
  }

  // Handle network errors
  Exception _handleNetworkError(SocketException e) {
    if (e.message.contains('timeout')) {
      return Exception(
          'Request timeout. Please check your internet connection and try again.');
    } else if (e.message.contains('Network is unreachable')) {
      return Exception(
          'No internet connection. Please check your network and try again.');
    } else {
      return Exception(
          'Connection failed. Please check your internet connection.');
    }
  }

  // Dispose method to clean up resources
  static void dispose() {
    _httpClient.close();
  }
}
