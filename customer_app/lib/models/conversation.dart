import 'message.dart';

class ConversationPerson {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePhotoUrl;

  const ConversationPerson({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhotoUrl,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'User' : name;
  }

  factory ConversationPerson.fromJson(Map<String, dynamic> json) {
    return ConversationPerson(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      profilePhotoUrl: json['profilePhotoUrl']?.toString(),
    );
  }
}

class ConversationProperty {
  final String id;
  final String title;
  final String city;
  final String state;
  final String? coverImageUrl;

  const ConversationProperty({
    required this.id,
    required this.title,
    required this.city,
    required this.state,
    this.coverImageUrl,
  });

  factory ConversationProperty.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>? ?? [];

    String? coverImageUrl;

    if (images.isNotEmpty) {
      final image = images.first as Map<String, dynamic>;

      coverImageUrl = image['imageUrl']?.toString();
    }

    return ConversationProperty(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      coverImageUrl: coverImageUrl,
    );
  }
}

class ConversationBooking {
  final String id;
  final String status;
  final DateTime? checkIn;
  final DateTime? checkOut;

  const ConversationBooking({
    required this.id,
    required this.status,
    this.checkIn,
    this.checkOut,
  });

  factory ConversationBooking.fromJson(Map<String, dynamic> json) {
    return ConversationBooking(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      checkIn: DateTime.tryParse(json['checkIn']?.toString() ?? ''),
      checkOut: DateTime.tryParse(json['checkOut']?.toString() ?? ''),
    );
  }
}

class Conversation {
  final String id;
  final ConversationProperty property;
  final ConversationBooking? booking;
  final ConversationPerson guest;
  final ConversationPerson host;
  final ChatMessage? lastMessage;
  final DateTime? updatedAt;

  const Conversation({
    required this.id,
    required this.property,
    required this.guest,
    required this.host,
    this.booking,
    this.lastMessage,
    this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final propertyJson = json['property'] as Map<String, dynamic>;

    final guestJson = json['guest'] as Map<String, dynamic>;

    final hostJson = json['host'] as Map<String, dynamic>;

    final bookingJson = json['booking'] as Map<String, dynamic>?;

    final messages = json['messages'] as List<dynamic>? ?? [];

    ChatMessage? lastMessage;

    if (messages.isNotEmpty) {
      lastMessage = ChatMessage.fromJson(
        messages.first as Map<String, dynamic>,
      );
    }

    return Conversation(
      id: json['id']?.toString() ?? '',
      property: ConversationProperty.fromJson(propertyJson),
      guest: ConversationPerson.fromJson(guestJson),
      host: ConversationPerson.fromJson(hostJson),
      booking: bookingJson == null
          ? null
          : ConversationBooking.fromJson(bookingJson),
      lastMessage: lastMessage,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}
