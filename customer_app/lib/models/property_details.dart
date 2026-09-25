class PropertyDetails {
  final String id;
  final String title;
  final String description;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pricePerNight;

  final int bedrooms;
  final int bathrooms;
  final int maxGuests;

  final double averageRating;
  final int reviewCount;

  final List<String> imageUrls;
  final List<PropertyAmenity> amenities;

  final PropertyHost host;

  const PropertyDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pricePerNight,
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
    required this.averageRating,
    required this.reviewCount,
    required this.imageUrls,
    required this.amenities,
    required this.host,
  });

  factory PropertyDetails.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>? ?? [];

    final amenities = json['amenities'] as List<dynamic>? ?? [];

    return PropertyDetails(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      pricePerNight: json['pricePerNight'].toString(),
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
      maxGuests: (json['maxGuests'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      imageUrls: images.map((image) => image['imageUrl'] as String).toList(),
      amenities: amenities
          .map(
            (item) => PropertyAmenity.fromJson(
              item['amenity'] as Map<String, dynamic>,
            ),
          )
          .toList(),
      host: PropertyHost.fromJson(json['host'] as Map<String, dynamic>),
    );
  }
}

class PropertyAmenity {
  final String id;
  final String name;
  final String icon;

  const PropertyAmenity({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory PropertyAmenity.fromJson(Map<String, dynamic> json) {
    return PropertyAmenity(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '',
    );
  }
}

class PropertyHost {
  final String id;
  final String firstName;
  final String lastName;
  final bool isVerified;
  final String? profilePhotoUrl;

  const PropertyHost({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.isVerified,
    required this.profilePhotoUrl,
  });

  factory PropertyHost.fromJson(Map<String, dynamic> json) {
    return PropertyHost(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
