class Property {
  final String id;
  final String title;
  final String city;
  final String state;
  final String pricePerNight;
  final double averageRating;
  final int reviewCount;
  final String? coverImageUrl;

  const Property({
    required this.id,
    required this.title,
    required this.city,
    required this.state,
    required this.pricePerNight,
    required this.averageRating,
    required this.reviewCount,
    required this.coverImageUrl,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List<dynamic>? ?? []);

    String? coverImageUrl;

    if (images.isNotEmpty) {
      final cover = images.firstWhere(
        (image) => image['isCover'] == true,
        orElse: () => images.first,
      );

      coverImageUrl = cover['imageUrl'] as String?;
    }

    final rating = json['averageRating'];

    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pricePerNight: json['pricePerNight'].toString(),
      averageRating: rating == null ? 0 : (rating as num).toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      coverImageUrl: coverImageUrl,
    );
  }
}
