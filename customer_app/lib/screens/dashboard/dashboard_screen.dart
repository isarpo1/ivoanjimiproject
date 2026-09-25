import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/api_client.dart';
import '../trips/trips_screen.dart';
import '../explore/explore_screen.dart';
import '../property/property_detail_screen.dart';
import '../../core/api/property_api.dart';
import '../../models/property.dart';
import '../messages/messages_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  List<Property> properties = [];

  bool loadingProperties = true;

  String? propertyError;

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
        loadingProperties = false;
        propertyError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        loadingProperties = false;
        propertyError = error.toString();
      });
    }
  }

  static const purple = Color(0xFF896AFB);
  static const darkText = Color(0xFF181820);
  static const background = Color(0xFFF9F9FB);
  static const lightPurple = Color(0xFFF3F0FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where are you going?',
                style: GoogleFonts.urbanist(
                  fontSize: 26,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),

              const SizedBox(height: 14),

              _buildSearchBar(),

              const SizedBox(height: 22),

              _buildQuickServices(),

              const SizedBox(height: 24),

              _buildPremiumBanner(),

              const SizedBox(height: 30),

              _buildSectionHeader(
                title: 'Popular Near You',
                action: 'See All',
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExploreScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildPopularNearYou(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  void _openSearchSheet() {
    final destinationController = TextEditingController();

    DateTimeRange? selectedDates;
    int guests = 1;

    final dashboardContext = context;

    String searchDate(DateTime date) {
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> chooseDates() async {
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
                setSheetState(() {
                  selectedDates = result;
                });
              }
            }

            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                },
                                icon: const Icon(Icons.close_rounded, size: 26),
                              ),
                              const Spacer(),
                              Text(
                                'Search stays',
                                style: GoogleFonts.urbanist(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(width: 48),
                            ],
                          ),

                          const SizedBox(height: 24),

                          Text(
                            'Where do you want to go?',
                            style: GoogleFonts.urbanist(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 20),

                          TextField(
                            controller: destinationController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Where',
                              hintText: 'Lagos',
                              prefixIcon: const Icon(Icons.search_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: purple,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          InkWell(
                            onTap: chooseDates,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE2E2E5),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: purple,
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'When',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          selectedDates == null
                                              ? 'Add dates'
                                              : '${searchDate(selectedDates!.start)} – ${searchDate(selectedDates!.end)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
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

                          const SizedBox(height: 16),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE2E2E5),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.people_outline, color: purple),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Who',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        '$guests guest${guests == 1 ? '' : 's'}',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  onPressed: guests > 1
                                      ? () {
                                          setSheetState(() {
                                            guests--;
                                          });
                                        }
                                      : null,
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),

                                Text(
                                  '$guests',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                IconButton(
                                  onPressed: guests < 16
                                      ? () {
                                          setSheetState(() {
                                            guests++;
                                          });
                                        }
                                      : null,
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: purple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                final destination = destinationController.text
                                    .trim();

                                Navigator.of(sheetContext).pop();

                                Navigator.of(dashboardContext).push(
                                  MaterialPageRoute(
                                    builder: (_) => ExploreScreen(
                                      initialDestination: destination,
                                      initialDates: selectedDates,
                                      initialGuests: guests,
                                      autoSearch: true,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Search stays',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(destinationController.dispose);
  }

  Widget _buildSearchBar() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _openSearchSheet,
        child: Container(
          height: 54,
          padding: const EdgeInsets.fromLTRB(16, 0, 7, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEDEDF1)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                size: 21,
                color: Color(0xFF6C6C76),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  'Search stays, cities, or places',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8A8A94),
                  ),
                ),
              ),

              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7FC),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE8E6EF)),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: darkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String action,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
        ),
        if (action.isNotEmpty)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: purple,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickServices() {
    const categories = [
      ('Stays', Icons.home_outlined),
      ('Apartments', Icons.apartment_outlined),
      ('Houses', Icons.house_outlined),
      ('Villas', Icons.villa_outlined),
      ('Beachfront', Icons.beach_access_outlined),
      ('Luxury', Icons.diamond_outlined),
    ];

    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = index == 0;

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (index == 0) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExploreScreen()),
                );
              }
            },
            child: Container(
              width: 76,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? purple : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? purple : const Color(0xFFF0EFF3),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: purple.withValues(alpha: 0.16),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category.$2,
                    size: 22,
                    color: selected ? Colors.white : darkText,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    category.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : darkText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: double.infinity,
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d'
              '?auto=format&fit=crop&w=1400&q=90',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _bannerFallback();
              },
            ),

            // Dark overlay so the text stays readable
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xCC000000),
                    Color(0x66000000),
                    Color(0x11000000),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'IVOANJIMI EXCLUSIVE',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Premium Lagos Stays',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Book verified stays across Lagos',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6050D8), Color(0xFF896AFB), Color(0xFFB5A3FF)],
        ),
      ),
    );
  }

  Widget _buildPopularNearYou() {
    if (loadingProperties) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator(color: purple)),
      );
    }

    if (propertyError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: purple),
            const SizedBox(height: 8),
            Text(
              'Unable to load properties',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  loadingProperties = true;
                });

                _loadProperties();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (properties.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No Lagos properties available yet.')),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 265,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: properties.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return SizedBox(
                width: constraints.maxWidth,
                child: _PropertyCard(property: properties[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      children: [
        _ActivityCard(
          icon: Icons.apartment_outlined,
          title: 'Luxury Apartment Booking',
          subtitle: 'Victoria Island, Lagos',
          status: 'Completed',
        ),

        const SizedBox(height: 10),

        _ActivityCard(
          icon: Icons.chat_bubble_outline,
          title: 'Message from Host',
          subtitle: 'Reliable Wi-Fi and backup power available',
          status: 'New',
        ),

        const SizedBox(height: 10),

        _ActivityCard(
          icon: Icons.payment_outlined,
          title: 'Payment Successful',
          subtitle: '₦374,000 booking payment',
          status: 'Paid',
        ),
      ],
    );
  }

  Widget _buildSavedPlaces() {
    return Row(
      children: [
        Expanded(
          child: _SavedPlaceCard(
            icon: Icons.home_outlined,
            title: 'Home',
            subtitle: 'Lagos, Nigeria',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _SavedPlaceCard(
            icon: Icons.business_outlined,
            title: 'Work',
            subtitle: 'Victoria Island',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _selectedIndex,

      backgroundColor: Colors.white,

      indicatorColor: lightPurple,

      height: 72,

      onDestinationSelected: (index) {
        if (index == 1) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const ExploreScreen()));

          return;
        }

        if (index == 2) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const TripsScreen()));

          return;
        }

        if (index == 3) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const MessagesScreen()));
          return;
        }

        if (index == 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },

      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),

        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Explore',
        ),

        NavigationDestination(
          icon: Icon(Icons.luggage_outlined),
          selectedIcon: Icon(Icons.luggage),
          label: 'Trips',
        ),

        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),

        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Property property;

  const _PropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF896AFB);

    final imageUrl =
        'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea'
        '?auto=format&fit=crop&w=1200&q=90';

    final formattedPrice = _formatNaira(property.pricePerNight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PropertyDetailScreen(property: property),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 6),
                color: Color(0x0D000000),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 155,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
  imageUrl,
  fit: BoxFit.cover,
  errorBuilder: (
    context,
    error,
    stackTrace,
  ) {
    return _imageFallback();
  },
),

                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(blurRadius: 8, color: Color(0x16000000)),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 20,
                          color: Color(0xFF292930),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.urbanist(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF181820),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFFFB326),
                        ),

                        const SizedBox(width: 3),

                        Text(
                          property.reviewCount == 0
                              ? 'New'
                              : property.averageRating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF8A8A94),
                        ),

                        const SizedBox(width: 3),

                        Expanded(
                          child: Text(
                            '${property.city}, ${property.state}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF8A8A94),
                            ),
                          ),
                        ),

                        if (property.reviewCount > 0)
                          Text(
                            '${property.reviewCount} '
                            '${property.reviewCount == 1 ? 'review' : 'reviews'}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: const Color(0xFF9999A3),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: formattedPrice,
                            style: GoogleFonts.urbanist(
                              color: purple,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' / night',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF8A8A94),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _imageFallback() {
    return Container(
      color: const Color(0xFFF3F0FF),
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 50,
          color: Color(0xFF896AFB),
        ),
      ),
    );
  }

  static String _formatNaira(String price) {
    final amount = double.tryParse(price)?.round() ?? 0;

    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );

    return '₦$formatted';
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFF0F0F4)),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: const Color(0xFF896AFB), size: 21),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF7C7C89),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            status,
            style: GoogleFonts.inter(
              color: const Color(0xFF896AFB),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedPlaceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SavedPlaceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFF0F0F4)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(icon, color: const Color(0xFF896AFB), size: 18),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: const Color(0xFF7C7C89),
            ),
          ),
        ],
      ),
    );
  }
}
