import '../storage/token_storage.dart';
import 'api_client.dart';
import '../../models/booking.dart';

class BookingApi {
  static Future<Map<String, dynamic>> createBooking({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestCount,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in.');
    }

    return ApiClient.post('/bookings', {
      'propertyId': propertyId,
      'checkIn': _formatDate(checkIn),
      'checkOut': _formatDate(checkOut),
      'guestCount': guestCount,
    }, token: token);
  }

  static Future<List<Booking>> getMyBookings() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in.');
    }

    final response = await ApiClient.get('/bookings/me', token: token);

    final items = response as List<dynamic>;

    return items
        .map((item) => Booking.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Booking> getBooking(String bookingId) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in.');
    }

    final response = await ApiClient.get('/bookings/$bookingId', token: token);

    return Booking.fromJson(response as Map<String, dynamic>);
  }

  static Future<Booking> cancelBooking(String bookingId) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in.');
    }

    final response = await ApiClient.patch(
      '/bookings/$bookingId/cancel',
      token: token,
    );

    return Booking.fromJson(response as Map<String, dynamic>);
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}
