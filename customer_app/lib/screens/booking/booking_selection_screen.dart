import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'booking_summary_screen.dart';
import '../../models/property_details.dart';

class BookingSelectionScreen extends StatefulWidget {
  final PropertyDetails property;

  const BookingSelectionScreen({super.key, required this.property});

  @override
  State<BookingSelectionScreen> createState() => _BookingSelectionScreenState();
}

class _BookingSelectionScreenState extends State<BookingSelectionScreen> {
  static const purple = Color(0xFF896AFB);

  DateTimeRange? selectedDates;

  int guests = 1;

  int get nights {
    if (selectedDates == null) {
      return 0;
    }

    return selectedDates!.end.difference(selectedDates!.start).inDays;
  }

  Future<void> _selectDates() async {
    final now = DateTime.now();

    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Choose your stay',
      saveText: 'Select',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme
                .copyWith(primary: purple),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedDates = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Your stay',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.w700),
        ),
      ),

      bottomNavigationBar: _buildContinueBar(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.property.title,
              style: GoogleFonts.urbanist(
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              '${widget.property.city}, ${widget.property.state}',
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 30),

            Text(
              'When are you going?',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 14),

            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _selectDates,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE4E4E7)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, color: purple),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedDates == null
                                ? 'Add dates'
                                : '${_formatDate(selectedDates!.start)} → ${_formatDate(selectedDates!.end)}',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          if (selectedDates != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '$nights night${nights == 1 ? '' : 's'}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'Who’s coming?',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE4E4E7)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guests',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Maximum ${widget.property.maxGuests}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: guests > 1
                        ? () {
                            setState(() {
                              guests--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),

                  SizedBox(
                    width: 32,
                    child: Text(
                      '$guests',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: guests < widget.property.maxGuests
                        ? () {
                            setState(() {
                              guests++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            if (selectedDates != null) _buildPricePreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildPricePreview() {
    final nightlyRate = double.tryParse(widget.property.pricePerNight) ?? 0;

    final subtotal = nightlyRate * nights;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price preview',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Text(
                '₦${_formatPrice(nightlyRate)} × $nights nights',
                style: GoogleFonts.inter(),
              ),
            ),
            Text(
              '₦${_formatPrice(subtotal)}',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          'Taxes and service fees will be shown before payment.',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildContinueBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
        ),
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: FilledButton(
            onPressed: selectedDates == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookingSummaryScreen(
                          property: widget.property,
                          dates: selectedDates!,
                          guests: guests,
                        ),
                      ),
                    );
                  },
            style: FilledButton.styleFrom(
              backgroundColor: purple,
              disabledBackgroundColor: const Color(0xFFD8D4E8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
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

    return '${months[date.month - 1]} ${date.day}';
  }

  static String _formatPrice(double value) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }
}
