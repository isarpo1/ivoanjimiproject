import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/api_client.dart';
import '../../core/api/property_api.dart';
import '../../models/property.dart';

class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  static const purple = Color(0xFF896AFB);

  List<Property> properties = [];

  bool loading = true;

  String? error;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      final results = await PropertyApi.getLagosProperties();

      if (!mounted) {
        return;
      }

      setState(() {
        properties = results;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FB),
        elevation: 0,
        title: Text(
          'Stays',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.w700),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator(color: purple))
          : error != null
          ? Center(
              child: Text(
                'Unable to load properties',
                style: GoogleFonts.inter(),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Where do you want to stay?',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),

                    itemCount: properties.length,

                    separatorBuilder: (_, _) => const SizedBox(height: 16),

                    itemBuilder: (context, index) {
                      return _HotelCard(property: properties[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final Property property;

  const _HotelCard({required this.property});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF896AFB);

    final imageUrl = property.coverImageUrl == null
        ? null
        : '${ApiClient.baseUrl}${property.coverImageUrl}';

    return InkWell(
      borderRadius: BorderRadius.circular(22),

      onTap: () {
        // Property detail screen next.
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),

        clipBehavior: Clip.antiAlias,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            SizedBox(
              height: 210,
              width: double.infinity,
              child: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFFE8E4FC),
                      child: const Icon(
                        Icons.apartment,
                        size: 60,
                        color: purple,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: GoogleFonts.urbanist(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const Icon(Icons.star, color: Colors.amber, size: 17),

                      const SizedBox(width: 4),

                      Text(
                        property.reviewCount == 0
                            ? 'New'
                            : property.averageRating.toStringAsFixed(1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Text(
                    '${property.city}, ${property.state}',
                    style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '₦${_formatPrice(property.pricePerNight)} / night',
                    style: GoogleFonts.urbanist(
                      color: purple,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
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

  static String _formatPrice(String price) {
    final value = double.tryParse(price)?.toInt() ?? 0;

    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }
}
