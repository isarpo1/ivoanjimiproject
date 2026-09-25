import '../storage/token_storage.dart';
import 'api_client.dart';

class PaymentApi {
  static Future<Map<String, dynamic>> initializeMockPayment({
    required String bookingId,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in.');
    }

    return ApiClient.post('/payments/mock/initialize', {
      'bookingId': bookingId,
    }, token: token);
  }

  static Future<Map<String, dynamic>> simulateSuccess({
    required String paymentId,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in.');
    }

    return ApiClient.post(
      '/payments/$paymentId/mock-success',
      {},
      token: token,
    );
  }
}
