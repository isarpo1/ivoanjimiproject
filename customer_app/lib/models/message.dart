class MessageSender {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePhotoUrl;

  const MessageSender({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhotoUrl,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'User' : name;
  }

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      profilePhotoUrl: json['profilePhotoUrl']?.toString(),
    );
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String message;
  final DateTime createdAt;
  final DateTime? readAt;
  final MessageSender? sender;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.readAt,
    this.sender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final senderJson = json['sender'] as Map<String, dynamic>?;

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      readAt: json['readAt'] == null
          ? null
          : DateTime.tryParse(json['readAt'].toString()),
      sender: senderJson == null ? null : MessageSender.fromJson(senderJson),
    );
  }
}
