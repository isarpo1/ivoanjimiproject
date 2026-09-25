import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/payment_api.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final String propertyTitle;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.propertyTitle,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const purple = Color(0xFF896AFB);

  Map<String, dynamic>? payment;

  bool loading = true;
  bool paying = false;
  bool paymentSuccessful = false;

  String? error;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      final result = await PaymentApi.initializeMockPayment(
        bookingId: widget.bookingId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        payment = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        error = _cleanError(e);
      });
    }
  }

  Future<void> _pay() async {
    final paymentId = payment?['id']?.toString();

    if (paymentId == null || paymentId.isEmpty) {
      return;
    }

    setState(() {
      paying = true;
      error = null;
    });

    try {
      await PaymentApi.simulateSuccess(paymentId: paymentId);

      if (!mounted) {
        return;
      }

      setState(() {
        paying = false;
        paymentSuccessful = true;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        paying = false;
        error = _cleanError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (paymentSuccessful) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Payment',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.w700),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: purple))
          : error != null && payment == null
          ? _buildInitializationError()
          : _buildPaymentContent(),
    );
  }

  Widget _buildPaymentContent() {
    final amount = payment?['amount']?.toString() ?? '0';
    final currency = payment?['currency']?.toString() ?? 'NGN';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.propertyTitle,
            style: GoogleFonts.urbanist(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Complete payment for your stay',
            style: GoogleFonts.inter(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 32),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount due',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${currency == 'NGN' ? '₦' : '$currency '}${_formatPrice(amount)}',
                  style: GoogleFonts.urbanist(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 18, color: purple),
                    const SizedBox(width: 8),
                    Text(
                      'Mock payment for development',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                error!,
                style: GoogleFonts.inter(color: Colors.red.shade700),
              ),
            ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: paying ? null : _pay,
              style: FilledButton.styleFrom(
                backgroundColor: purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: paying
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Pay now',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitializationError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 54, color: Colors.redAccent),

            const SizedBox(height: 16),

            Text(
              error ?? 'Unable to initialize payment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(),
            ),

            const SizedBox(height: 18),

            FilledButton(
              onPressed: () {
                setState(() {
                  loading = true;
                  error = null;
                });

                _initializePayment();
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F0FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 50, color: purple),
              ),

              const SizedBox(height: 28),

              Text(
                'Payment successful',
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Your payment was received. Your booking is now waiting for host approval.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_outlined, color: purple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Status: Waiting for host approval',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Back to home',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatPrice(String value) {
    final parsed = double.tryParse(value)?.round() ?? 0;

    return parsed.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }

  static String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
