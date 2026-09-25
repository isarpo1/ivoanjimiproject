import '../../models/property.dart';
import '../../models/property_details.dart';
import 'api_client.dart';

class PropertyApi {
  static Future<List<Property>> getLagosProperties() async {
    final response = await ApiClient.get('/properties?city=Lagos&limit=10');

    final items = response['data'] as List<dynamic>;

    return items
        .map((item) => Property.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Property>> searchProperties({
    String? city,
    DateTime? checkIn,
    DateTime? checkOut,
    int guests = 1,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    List<String> amenityIds = const [],
    String sort = 'newest',
  }) async {
    final query = <String, String>{
      'limit': '20',
      'guests': guests.toString(),
      'sort': sort,
    };

    if (city != null && city.trim().isNotEmpty) {
      query['city'] = city.trim();
    }

    if (checkIn != null) {
      query['checkIn'] = _formatDate(checkIn);
    }

    if (checkOut != null) {
      query['checkOut'] = _formatDate(checkOut);
    }

    if (minPrice != null) {
      query['minPrice'] = minPrice.round().toString();
    }

    if (maxPrice != null) {
      query['maxPrice'] = maxPrice.round().toString();
    }

    if (bedrooms != null) {
      query['bedrooms'] = bedrooms.toString();
    }

    if (amenityIds.isNotEmpty) {
      query['amenityIds'] = amenityIds.join(',');
    }

    final queryString = Uri(queryParameters: query).query;

    final response = await ApiClient.get('/properties?$queryString');

    final items = response['data'] as List<dynamic>;

    return items
        .map((item) => Property.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<PropertyDetails> getPropertyDetails(String id) async {
    final response = await ApiClient.get('/properties/$id');

    return PropertyDetails.fromJson(response as Map<String, dynamic>);
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}
