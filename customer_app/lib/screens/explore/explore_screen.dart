import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/api_client.dart';
import '../../core/api/property_api.dart';
import '../../models/property.dart';
import '../property/property_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final String initialDestination;
  final DateTimeRange? initialDates;
  final int initialGuests;
  final bool autoSearch;

  const ExploreScreen({
    super.key,
    this.initialDestination = '',
    this.initialDates,
    this.initialGuests = 1,
    this.autoSearch = false,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const purple = Color(0xFF896AFB);

  late final TextEditingController _destinationController;

  DateTimeRange? selectedDates;
  late int guests;

  bool loading = false;
  bool searched = false;

  String? error;

  List<Property> properties = [];

  double? minPrice;
  double? maxPrice;
  int? bedrooms;

  String sort = 'newest';

  List<String> selectedAmenityIds = [];
  List<Map<String, dynamic>> amenities = [];

  @override
  void initState() {
    super.initState();

    _destinationController = TextEditingController(
      text: widget.initialDestination,
    );

    selectedDates = widget.initialDates;
    guests = widget.initialGuests;

    _loadAmenities();

    if (widget.autoSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _search();
      });
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadAmenities() async {
    try {
      final response = await ApiClient.get('/amenities');

      final items = response as List<dynamic>;

      if (!mounted) {
        return;
      }

      setState(() {
        amenities = items.map((item) => item as Map<String, dynamic>).toList();
      });
    } catch (_) {
      // Keep the filters usable even if amenities fail to load.
    }
  }

  Future<void> _selectDates() async {
    final now = DateTime.now();

    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Choose your dates',
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

  Future<void> _search() async {
    setState(() {
      loading = true;
      searched = true;
      error = null;
    });

    try {
      final result = await PropertyApi.searchProperties(
        city: _destinationController.text,
        checkIn: selectedDates?.start,
        checkOut: selectedDates?.end,
        guests: guests,
        minPrice: minPrice,
        maxPrice: maxPrice,
        bedrooms: bedrooms,
        amenityIds: selectedAmenityIds,
        sort: sort,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        properties = result;
        loading = false;
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

  void _openFilters() {
    final minController = TextEditingController(
      text: minPrice?.round().toString() ?? '',
    );

    final maxController = TextEditingController(
      text: maxPrice?.round().toString() ?? '',
    );

    int? tempBedrooms = bedrooms;
    String tempSort = sort;

    final tempAmenities = Set<String>.from(selectedAmenityIds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
                title: Text(
                  'Filters',
                  style: GoogleFonts.urbanist(fontWeight: FontWeight.w800),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setSheetState(() {
                        minController.clear();
                        maxController.clear();

                        tempBedrooms = null;
                        tempAmenities.clear();
                        tempSort = 'newest';
                      });
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price per night',
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Minimum',
                              prefixText: '₦ ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: TextField(
                            controller: maxController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Maximum',
                              prefixText: '₦ ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Bedrooms',
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _BedroomChip(
                          label: 'Any',
                          selected: tempBedrooms == null,
                          onTap: () {
                            setSheetState(() {
                              tempBedrooms = null;
                            });
                          },
                        ),
                        ...[1, 2, 3, 4].map(
                          (count) => _BedroomChip(
                            label: count == 4 ? '4+' : '$count',
                            selected: tempBedrooms == count,
                            onTap: () {
                              setSheetState(() {
                                tempBedrooms = count;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Amenities',
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (amenities.isEmpty)
                      Text(
                        'Amenities are loading...',
                        style: GoogleFonts.inter(color: Colors.grey),
                      )
                    else
                      ...amenities.map((amenity) {
                        final id = amenity['id'].toString();

                        final name = amenity['name'].toString();

                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: purple,
                          value: tempAmenities.contains(id),
                          title: Text(name, style: GoogleFonts.inter()),
                          onChanged: (selected) {
                            setSheetState(() {
                              if (selected == true) {
                                tempAmenities.add(id);
                              } else {
                                tempAmenities.remove(id);
                              }
                            });
                          },
                        );
                      }),

                    const SizedBox(height: 28),

                    Text(
                      'Sort by',
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: tempSort,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('Newest'),
                        ),
                        DropdownMenuItem(
                          value: 'price_asc',
                          child: Text('Price: Low to high'),
                        ),
                        DropdownMenuItem(
                          value: 'price_desc',
                          child: Text('Price: High to low'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setSheetState(() {
                          tempSort = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
                  ),
                  child: SizedBox(
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          minPrice = double.tryParse(minController.text.trim());

                          maxPrice = double.tryParse(maxController.text.trim());

                          bedrooms = tempBedrooms;

                          selectedAmenityIds = tempAmenities.toList();

                          sort = tempSort;
                        });

                        Navigator.of(sheetContext).pop();

                        _search();
                      },
                      child: Text(
                        'Show stays',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      minController.dispose();
      maxController.dispose();
    });
  }

  void _showGuestPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guests',
                            style: GoogleFonts.urbanist(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'How many people are staying?',
                            style: GoogleFonts.inter(
                              color: Colors.grey.shade600,
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

                              setState(() {});
                            }
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),

                    Text(
                      '$guests',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    IconButton(
                      onPressed: guests < 16
                          ? () {
                              setSheetState(() {
                                guests++;
                              });

                              setState(() {});
                            }
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Explore',
          style: GoogleFonts.urbanist(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchPanel(),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Column(
        children: [
          TextField(
            controller: _destinationController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Where are you going?',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF7F7F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: purple),
              ),
            ),
            onSubmitted: (_) {
              _search();
            },
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _SearchOption(
                  icon: Icons.calendar_month_outlined,
                  title: 'Dates',
                  value: selectedDates == null
                      ? 'Add dates'
                      : '${_formatDate(selectedDates!.start)} – ${_formatDate(selectedDates!.end)}',
                  onTap: _selectDates,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _SearchOption(
                  icon: Icons.people_outline,
                  title: 'Guests',
                  value: '$guests guest${guests == 1 ? '' : 's'}',
                  onTap: _showGuestPicker,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: loading ? null : _search,
                    style: FilledButton.styleFrom(
                      backgroundColor: purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Search stays',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              SizedBox(
                width: 52,
                height: 52,
                child: OutlinedButton(
                  onPressed: _openFilters,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: Color(0xFFE2E2E5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: purple));
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (!searched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.travel_explore_rounded, size: 54, color: purple),
              const SizedBox(height: 16),
              Text(
                'Find your next stay',
                style: GoogleFonts.urbanist(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Search by destination, dates, and guests.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (properties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No stays found for this search.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: properties.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        return _ExplorePropertyCard(property: properties[index]);
      },
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
}

class _BedroomChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BedroomChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF896AFB);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 58),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3F0FF) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? purple : const Color(0xFFE1E1E5),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: selected ? purple : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _SearchOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SearchOption({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E5E7)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF896AFB)),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
}

class _ExplorePropertyCard extends StatelessWidget {
  final Property property;

  const _ExplorePropertyCard({required this.property});

  static const purple = Color(0xFF896AFB);

  @override
  Widget build(BuildContext context) {
    final imageUrl = property.coverImageUrl == null
        ? null
        : '${ApiClient.baseUrl}${property.coverImageUrl}';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(property: property),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: imageUrl == null
                  ? _fallback()
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _fallback();
                      },
                    ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  property.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.urbanist(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.star_rounded, size: 17),
              const SizedBox(width: 3),
              Text(
                property.reviewCount == 0
                    ? 'New'
                    : property.averageRating.toStringAsFixed(1),
                style: GoogleFonts.inter(fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            '${property.city}, ${property.state}',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 5),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '₦${_formatPrice(property.pricePerNight)}',
                  style: GoogleFonts.urbanist(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' / night',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _fallback() {
    return Container(
      color: const Color(0xFFF3F0FF),
      child: const Center(
        child: Icon(Icons.home_work_outlined, size: 54, color: purple),
      ),
    );
  }

  static String _formatPrice(String value) {
    final amount = double.tryParse(value)?.round() ?? 0;

    return amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }
}
