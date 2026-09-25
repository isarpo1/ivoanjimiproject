import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/api_client.dart';
import '../../core/api/messaging_api.dart';
import '../../core/api/property_api.dart';
import '../../models/property.dart';
import '../../models/property_details.dart';
import '../booking/booking_selection_screen.dart';
import '../messages/chat_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  static const purple = Color(0xFF896AFB);

  PropertyDetails? details;

  bool loading = true;

  String? error;
  bool startingConversation = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final result = await PropertyApi.getPropertyDetails(widget.property.id);

      if (!mounted) {
        return;
      }

      setState(() {
        details = result;
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
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: purple)),
      );
    }

    if (error != null || details == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Unable to load this stay.'),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    loading = true;
                    error = null;
                  });

                  _loadDetails();
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final property = details!;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildReserveBar(property),
      body: CustomScrollView(
        slivers: [
          _buildImageHeader(property),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(property),

                  const SizedBox(height: 22),

                  const Divider(),

                  const SizedBox(height: 20),

                  _buildStaySummary(property),

                  const SizedBox(height: 22),

                  const Divider(),

                  const SizedBox(height: 20),

                  _buildHost(property),

                  const SizedBox(height: 22),

                  const Divider(),

                  const SizedBox(height: 20),

                  _buildDescription(property),

                  const SizedBox(height: 26),

                  const Divider(),

                  const SizedBox(height: 20),

                  _buildAmenities(property),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader(PropertyDetails property) {
    final imageUrl = property.imageUrls.isEmpty
        ? null
        : '${ApiClient.baseUrl}${property.imageUrls.first}';

    return SliverAppBar(
      expandedHeight: 330,
      pinned: true,
      backgroundColor: Colors.white,

      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border, color: Colors.black),
            ),
          ),
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _imageFallback(),
              )
            : _imageFallback(),
      ),
    );
  }

  Widget _buildTitle(PropertyDetails property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.title,
          style: GoogleFonts.urbanist(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),

            const SizedBox(width: 4),

            Text(
              property.averageRating.toStringAsFixed(1),
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),

            const SizedBox(width: 6),

            Text(
              '· ${property.reviewCount} review${property.reviewCount == 1 ? '' : 's'}',
              style: GoogleFonts.inter(decoration: TextDecoration.underline),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          '${property.city}, ${property.state}, ${property.country}',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildStaySummary(PropertyDetails property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entire rental unit',
          style: GoogleFonts.urbanist(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          '${property.maxGuests} guests · '
          '${property.bedrooms} bedrooms · '
          '${property.bathrooms} bathrooms',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildHost(PropertyDetails property) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFF3F0FF),
          child: Text(
            property.host.firstName.isEmpty
                ? '?'
                : property.host.firstName[0].toUpperCase(),
            style: GoogleFonts.urbanist(
              color: purple,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hosted by ${property.host.fullName}',
                style: GoogleFonts.urbanist(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                property.host.isVerified ? 'Verified host' : 'Host',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),

        if (property.host.isVerified) const Icon(Icons.verified, color: purple),
      ],
    );
  }

  Widget _buildDescription(PropertyDetails property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this stay',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          property.description,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.55,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities(PropertyDetails property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What this place offers',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 18),

        ...property.amenities.map(
          (amenity) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              children: [
                Icon(_amenityIcon(amenity.icon), size: 24),

                const SizedBox(width: 16),

                Text(amenity.name, style: GoogleFonts.inter(fontSize: 15)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _messageHost(PropertyDetails property) async {
    if (startingConversation) {
      return;
    }

    setState(() {
      startingConversation = true;
    });

    try {
      final created = await MessagingApi.createConversation(
        propertyId: property.id,
      );

      final conversationId = created['id']?.toString();

      if (conversationId == null || conversationId.isEmpty) {
        throw Exception('Unable to open conversation.');
      }

      final conversation = await MessagingApi.getConversation(
        conversationId: conversationId,
      );

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(conversation: conversation),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          startingConversation = false;
        });
      }
    }
  }

  Widget _buildReserveBar(PropertyDetails property) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '₦${_formatPrice(property.pricePerNight)}',
                    style: GoogleFonts.urbanist(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: ' / night',
                    style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: purple,
                        side: const BorderSide(color: purple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: startingConversation
                          ? null
                          : () {
                              _messageHost(property);
                            },
                      icon: startingConversation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: purple,
                              ),
                            )
                          : const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 19,
                            ),
                      label: Text(
                        startingConversation ? 'Opening...' : 'Message',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingSelectionScreen(property: property),
                          ),
                        );
                      },
                      child: Text(
                        'Reserve',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _amenityIcon(String icon) {
    switch (icon) {
      case 'ac':
        return Icons.ac_unit;
      case 'power':
        return Icons.electric_bolt_outlined;
      case 'hot-water':
        return Icons.hot_tub_outlined;
      case 'kitchen':
        return Icons.kitchen_outlined;
      case 'parking':
        return Icons.local_parking_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  static Widget _imageFallback() {
    return Container(
      color: const Color(0xFFF3F0FF),
      child: const Center(
        child: Icon(Icons.home_work_outlined, size: 70, color: purple),
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
