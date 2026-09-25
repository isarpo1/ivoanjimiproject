import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/booking_api.dart';
import '../../models/booking.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState
    extends State<BookingDetailScreen> {
  static const purple = Color(0xFF896AFB);
  static const background = Color(0xFFF9F9FB);
  static const darkText = Color(0xFF181820);

  Booking? booking;

  bool loading = true;
  bool cancelling = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    try {
      final result =
          await BookingApi.getBooking(widget.bookingId);

      if (!mounted) {
        return;
      }

      setState(() {
        booking = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        error = e
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _cancelBooking() async {
    final currentBooking = booking;

    if (currentBooking == null || cancelling) {
      return;
    }

    final confirmed =
        await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            22,
            22,
            22,
            22 +
                MediaQuery.of(context)
                    .padding
                    .bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 5,
                margin:
                    const EdgeInsets.only(
                  bottom: 22,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2E7),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),
              Text(
                'Cancel this booking?',
                style: GoogleFonts.urbanist(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to cancel your stay at ${currentBooking.property.title}?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: const Color(0xFF6F6F79),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFDC3C3C),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Yes, cancel booking',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: darkText,
                    side: const BorderSide(
                      color: Color(0xFFE3E3E8),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Keep booking',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      cancelling = true;
    });

    try {
      final result =
          await BookingApi.cancelBooking(
        currentBooking.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        booking = result;
        cancelling = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Your booking has been cancelled.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        cancelling = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: background,
        title: Text(
          'Trip details',
          style: GoogleFonts.urbanist(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: purple,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: purple,
              ),
              const SizedBox(height: 14),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  setState(() {
                    loading = true;
                    error = null;
                  });

                  _loadBooking();
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final currentBooking = booking!;

    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        40,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildPropertyImage(),
          const SizedBox(height: 18),

          Text(
            currentBooking.property.title,
            style: GoogleFonts.urbanist(
              fontSize: 24,
              height: 1.05,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),

          const SizedBox(height: 7),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: Color(0xFF85858F),
              ),
              const SizedBox(width: 4),
              Text(
                '${currentBooking.property.city}, ${currentBooking.property.state}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color:
                      const Color(0xFF85858F),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _StatusBadge(
            status: currentBooking.status,
          ),

          const SizedBox(height: 28),

          Text(
            'Your trip',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),

          const SizedBox(height: 12),

          _InfoCard(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon:
                          Icons.login_rounded,
                      label: 'Check-in',
                      value: _formatDate(
                        currentBooking.checkIn,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 55,
                    color:
                        const Color(0xFFEAEAF0),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon:
                          Icons.logout_rounded,
                      label: 'Check-out',
                      value: _formatDate(
                        currentBooking.checkOut,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon:
                          Icons.people_outline,
                      label: 'Guests',
                      value:
                          '${currentBooking.guestCount} guest${currentBooking.guestCount == 1 ? '' : 's'}',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 55,
                    color:
                        const Color(0xFFEAEAF0),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons
                          .bedtime_outlined,
                      label: 'Stay',
                      value:
                          '${currentBooking.nights} night${currentBooking.nights == 1 ? '' : 's'}',
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          Text(
            'Price details',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding:
                const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color:
                    const Color(0xFFEAEAF0),
              ),
            ),
            child: Column(
              children: [
                _PriceRow(
                  label: 'Accommodation',
                  value:
                      currentBooking.subtotal,
                ),
                const SizedBox(height: 14),
                _PriceRow(
                  label: 'Service fee',
                  value:
                      currentBooking.serviceFee,
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  child: Divider(height: 1),
                ),
                _PriceRow(
                  label: 'Total',
                  value:
                      currentBooking.total,
                  bold: true,
                ),
              ],
            ),
          ),

          if (_canCancel(
            currentBooking.status,
          )) ...[
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: cancelling
                    ? null
                    : _cancelBooking,
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(0xFFCC3535),
                  side: const BorderSide(
                    color:
                        Color(0xFFE6B6B6),
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),
                  ),
                ),
                child: cancelling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Cancel booking',
                        style:
                            GoogleFonts.inter(
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPropertyImage() {
    const demoImageUrl =
        'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea'
        '?auto=format&fit=crop&w=1400&q=90';

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(22),
      child: SizedBox(
        width: double.infinity,
        height: 220,
        child: Image.network(
          demoImageUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return Container(
              color:
                  const Color(0xFFF3F0FF),
              child: const Center(
                child: Icon(
                  Icons.home_work_outlined,
                  size: 60,
                  color: purple,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static bool _canCancel(
    String status,
  ) {
    return status == 'PENDING' ||
        status == 'AWAITING_HOST' ||
        status == 'CONFIRMED';
  }

  static String _formatDate(
    DateTime date,
  ) {
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
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFEAEAF0),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const purple =
        Color(0xFF896AFB);

    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: purple,
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color:
                const Color(0xFF898993),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PriceRow
    extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: bold
                ? FontWeight.w700
                : FontWeight.w400,
            color:
                const Color(0xFF4B4B55),
          ),
        ),
        const Spacer(),
        Text(
          '₦${_formatPrice(value)}',
          style: GoogleFonts.urbanist(
            fontSize:
                bold ? 18 : 14,
            fontWeight: bold
                ? FontWeight.w800
                : FontWeight.w600,
            color: bold
                ? const Color(
                    0xFF181820,
                  )
                : const Color(
                    0xFF4B4B55,
                  ),
          ),
        ),
      ],
    );
  }

  static String _formatPrice(
    String value,
  ) {
    final amount =
        double.tryParse(value)?.round() ??
            0;

    return amount
        .toString()
        .replaceAllMapped(
          RegExp(
            r'\B(?=(\d{3})+(?!\d))',
          ),
          (_) => ',',
        );
  }
}

class _StatusBadge
    extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    const purple =
        Color(0xFF896AFB);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF3F0FF),
        borderRadius:
            BorderRadius.circular(20),
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

  static String _label(
    String status,
  ) {
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
