class Booking {
  final String id;
  final String status;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestCount;

  final String subtotal;
  final String serviceFee;
  final String total;
  final String currency;

  final BookingProperty property;

  const Booking({
    required this.id,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.guestCount,
    required this.subtotal,
    required this.serviceFee,
    required this.total,
    required this.currency,
    required this.property,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      status: json['status'].toString(),
      checkIn: DateTime.parse(json['checkIn'].toString()),
      checkOut: DateTime.parse(json['checkOut'].toString()),
      guestCount: (json['guestCount'] as num?)?.toInt() ?? 1,
      subtotal: json['subtotal'].toString(),
      serviceFee: json['serviceFee'].toString(),
      total: json['total'].toString(),
      currency: json['currency']?.toString() ?? 'NGN',
      property: BookingProperty.fromJson(
        json['property'] as Map<String, dynamic>,
      ),
    );
  }

  int get nights => checkOut.difference(checkIn).inDays;
}

class BookingProperty {
  final String id;
  final String title;
  final String city;
  final String state;
  final List<String> imageUrls;

  const BookingProperty({
    required this.id,
    required this.title,
    required this.city,
    required this.state,
    required this.imageUrls,
  });

  factory BookingProperty.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>? ?? [];

    return BookingProperty(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      imageUrls: images.map((image) => image['imageUrl'].toString()).toList(),
    );
  }
}
