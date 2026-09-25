import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/conversation.dart';
import '../../models/message.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';

class MessagingApi {
  static Future<String> _requireToken() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in.');
    }

    return token;
  }

  static Future<Conversation> getConversation({
    required String conversationId,
  }) async {
    final token = await _requireToken();

    final response = await ApiClient.get(
      '/conversations/$conversationId',
      token: token,
    );

    return Conversation.fromJson(response as Map<String, dynamic>);
  }

  static Future<List<Conversation>> getMyConversations() async {
    final token = await _requireToken();

    final response = await ApiClient.get('/conversations/me', token: token);

    final items = response as List<dynamic>;

    return items
        .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<ChatMessage>> getMessages({
    required String conversationId,
  }) async {
    final token = await _requireToken();

    final response = await ApiClient.get(
      '/conversations/$conversationId/messages',
      token: token,
    );

    final items = response as List<dynamic>;

    return items
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<ChatMessage> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final token = await _requireToken();

    final response = await ApiClient.post(
      '/conversations/$conversationId/messages',
      {'message': message},
      token: token,
    );

    return ChatMessage.fromJson(response);
  }

  static Future<Map<String, dynamic>> createConversation({
    required String propertyId,
    String? bookingId,
  }) async {
    final token = await _requireToken();

    final body = <String, dynamic>{'propertyId': propertyId};

    if (bookingId != null && bookingId.isNotEmpty) {
      body['bookingId'] = bookingId;
    }

    return ApiClient.post('/conversations', body, token: token);
  }

  static Future<void> markRead({required String conversationId}) async {
    final token = await _requireToken();

    final response = await http.patch(
      Uri.parse('${ApiClient.baseUrl}/conversations/$conversationId/read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Unable to mark messages as read.';

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          final apiMessage = decoded['message'];

          if (apiMessage is String) {
            message = apiMessage;
          }
        }
      } catch (_) {}

      throw Exception(message);
    }
  }
}
