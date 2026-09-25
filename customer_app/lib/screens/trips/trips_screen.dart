import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/api_client.dart';
import '../../core/api/booking_api.dart';
import '../../models/booking.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  static const purple = Color(0xFF896AFB);

  List<Booking> bookings = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final result = await BookingApi.getMyBookings();

      if (!mounted) {
        return;
      }

      setState(() {
        bookings = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      loading = true;
      error = null;
    });

    await _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Trips',
          style: GoogleFonts.urbanist(
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: purple));
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _refresh, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }

    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F0FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.luggage_outlined,
                  size: 42,
                  color: purple,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No trips yet',
                style: GoogleFonts.urbanist(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your bookings will appear here.',
                style: GoogleFonts.inter(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: purple,
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        itemCount: bookings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          return _TripCard(booking: bookings[index]);
        },
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Booking booking;

  const _TripCard({required this.booking});

  static const purple = Color(0xFF896AFB);

  @override
  Widget build(BuildContext context) {
    final imageUrl = booking.property.imageUrls.isEmpty
        ? null
        : '${ApiClient.baseUrl}${booking.property.imageUrls.first}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 170,
            child: imageUrl == null
                ? _imageFallback()
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _imageFallback();
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBadge(status: booking.status),

                const SizedBox(height: 12),

                Text(
                  booking.property.title,
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${booking.property.city}, ${booking.property.state}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: purple,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_formatDate(booking.checkIn)} – ${_formatDate(booking.checkOut)}',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 18, color: purple),
                    const SizedBox(width: 8),
                    Text(
                      '${booking.guestCount} guest${booking.guestCount == 1 ? '' : 's'} · '
                      '${booking.nights} night${booking.nights == 1 ? '' : 's'}',
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Divider(),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '₦${_formatPrice(booking.total)}',
                      style: GoogleFonts.urbanist(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _imageFallback() {
    return Container(
      color: const Color(0xFFF3F0FF),
      child: const Center(
        child: Icon(Icons.home_work_outlined, size: 52, color: purple),
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

    return '${months[date.month - 1]} ${date.day}';
  }

  static String _formatPrice(String value) {
    final amount = double.tryParse(value)?.round() ?? 0;

    return amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF896AFB);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(status),
        style: GoogleFonts.inter(
          color: purple,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static String _label(String status) {
    switch (status) {
      case 'AWAITING_HOST':
        return 'Waiting for host approval';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'PENDING':
        return 'Payment pending';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'DECLINED':
        return 'Declined';
      case 'REFUNDED':
        return 'Refunded';
      case 'EXPIRED':
        return 'Expired';
      default:
        return status;
    }
  }
}
