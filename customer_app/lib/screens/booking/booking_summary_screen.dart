import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../payment/payment_screen.dart';
import '../../core/api/booking_api.dart';
import '../../models/property_details.dart';

class BookingSummaryScreen extends StatelessWidget {
  final PropertyDetails property;
  final DateTimeRange dates;
  final int guests;

  const BookingSummaryScreen({
    super.key,
    required this.property,
    required this.dates,
    required this.guests,
  });

  static const purple = Color(0xFF896AFB);

  int get nights => dates.end.difference(dates.start).inDays;

  double get nightlyRate => double.tryParse(property.pricePerNight) ?? 0;

  double get subtotal => nightlyRate * nights;

  double get serviceFee => subtotal * 0.10;

  double get total => subtotal + serviceFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Review your stay',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              property.title,
              style: GoogleFonts.urbanist(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${property.city}, ${property.state}',
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 28),

            _buildSection(
              title: 'Dates',
              value: '${_formatDate(dates.start)} – ${_formatDate(dates.end)}',
            ),

            const Divider(height: 32),

            _buildSection(
              title: 'Guests',
              value: '$guests guest${guests == 1 ? '' : 's'}',
            ),

            const Divider(height: 32),

            Text(
              'Price details',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 18),

            _priceRow(
              '₦${_formatPrice(nightlyRate)} × $nights nights',
              subtotal,
            ),

            const SizedBox(height: 14),

            _priceRow('Service fee', serviceFee),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(),
            ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '₦${_formatPrice(total)}',
                  style: GoogleFonts.urbanist(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: purple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your booking is not confirmed until payment and host approval are completed.',
                      style: GoogleFonts.inter(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String value}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        Text(value, style: GoogleFonts.inter(fontSize: 14)),
      ],
    );
  }

  Widget _priceRow(String label, double amount) {
    return Row(
      children: [
        Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14))),
        Text(
          '₦${_formatPrice(amount)}',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
        ),
        child: SizedBox(
          height: 54,
          child: FilledButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(color: purple),
                ),
              );

              try {
                final booking = await BookingApi.createBooking(
                  propertyId: property.id,
                  checkIn: dates.start,
                  checkOut: dates.end,
                  guestCount: guests,
                );

                if (!context.mounted) {
                  return;
                }

                // Close loading dialog.
                Navigator.of(context).pop();

                // Move directly to payment screen.
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      bookingId: booking['id'].toString(),
                      propertyTitle: property.title,
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) {
                  return;
                }

                // Close loading dialog.
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Confirm and continue',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String _formatPrice(double value) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }
}
