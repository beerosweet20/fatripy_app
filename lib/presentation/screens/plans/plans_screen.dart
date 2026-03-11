import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/trip_repository.dart';
import '../../../domain/entities/trip_plan.dart';
import '../../localization/app_localizations_ext.dart';
import 'plan_comparison_screen.dart';
import 'plan_detail_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> with WidgetsBindingObserver {
  final TripRepository _tripRepo = TripRepository();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  late Future<List<TripPlan>> _plansFuture;

  int _selectedIndex = 2;

  // Colors
  static const Color _cream = Color(0xFFFFF4E8);
  static const Color _text = Color(0xFF2A2A2A);

  static const Color _pink = Color(0xFFE18299);
  static const Color _navy = Color(0xFF2E4474);
  static const Color _yellow = Color(0xFFF6D792);
  static const Color _yellowLine = Color(0xFFF0C57D);

  // Keys for measuring anchors
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();
  late final List<GlobalKey> _pillKeys = List.generate(
    3,
    (_) => GlobalKey(debugLabel: 'pill'),
  );

  Rect? _cardRectInStack;
  final Map<int, Rect> _pillRectsInStack = {};

  Future<List<TripPlan>> _loadPlans() {
    final uid = _uid;
    if (uid == null) {
      return Future<List<TripPlan>>.value(const <TripPlan>[]);
    }
    return _tripRepo.getAllPlans(uid);
  }

  void _refreshPlans() {
    if (!mounted) return;
    setState(() {
      _plansFuture = _loadPlans();
    });
  }

  // ---------------- Demo visuals fallback ----------------
  final List<_PlanVisual> _fallbackVisuals = [
    _PlanVisual(
      kind: _PlanKind.cultural,
      title: 'Cultural Plan.',
      accent: _yellow,
      border: _yellowLine,
      headerBar: const Color(0xFFF6E2B9),
      tableBg: const Color(0xFFF4D69B),
      tableText: Colors.white,
      info: const _PlanInfo(
        city: 'Riyadh.',
        dates: 'from 1 to 3 dec 2026.',
        duration: '3 days and 2 nights.',
        hotel: 'Bab Samhan Diriyah Hotel.',
      ),
      note: 'This Plan Come With Tour guide.',
      schedule: const [
        _DaySchedule(
          dayLabel: 'Day 1:',
          morning: 'Café Bateel\n-\nAl Masmak fortress',
          afternoon: 'Najd Village\n-\nKing Abdulaziz\nHistorical Center',
          evening: 'The Globe',
        ),
        _DaySchedule(
          dayLabel: 'Day 2:',
          morning: 'Paul\n-\nKing Fahd national\nlibrary',
          afternoon: 'Al Orjouan\n-\nSouk El Zal',
          evening: 'Takya',
        ),
        _DaySchedule(
          dayLabel: 'Day 3:',
          morning: 'Joe & The Juice\n-\nAl-Turaif',
          afternoon: 'Salt Riyadh',
          evening: 'Villa mamas\n-\nDiriyah Biennial of\nContemporary Art',
        ),
      ],
      nearby: const [
        'Seasonal Market (4 min).',
        'Saudi National Museum (20 min).',
        'Hall al Qusoor (4 min).',
      ],
      distant: const [
        'Marqab Muneikh Visitors (2 H).',
        'Design Space AlUla (2 h).',
        'Al Hokm Palace (28 min).',
      ],
      event: const [
        'Cultural Nights at King Fahad Cultural Center.',
        'Date: December.',
        'Time: Varies by schedule.',
        'Location: Al Rafiah.',
        'Description: A cultural event featuring book exhibitions, author meetups, poetry nights, and literary workshops as part of Riyadh’s winter cultural activities..',
      ],
      totalBudget: '5000 - 6500 SAR.',
      buttonColor: _yellow,
    ),
    _PlanVisual(
      kind: _PlanKind.adventure,
      title: 'Adventure Plan.',
      accent: _navy,
      border: _navy,
      headerBar: const Color(0xFFB7C8E6),
      tableBg: const Color(0xFF304577),
      tableText: Colors.white,
      info: const _PlanInfo(
        city: 'Riyadh.',
        dates: 'from 1 to 3 dec 2026.',
        duration: '3 days and 2 nights.',
        hotel: 'Hyatt Regency Riyadh Olaya.',
      ),
      schedule: const [
        _DaySchedule(
          dayLabel: 'Day 1:',
          morning: 'Dose Café\n-\nRed Sand Dunes',
          afternoon: 'California Pizza\nKitchen\n-\nArena VR',
          evening: 'Le Grenier à\nPain',
        ),
        _DaySchedule(
          dayLabel: 'Day 2:',
          morning: 'Brew Crew Café\n-\nRiyadh Adventure',
          afternoon: 'Najd Village',
          evening: 'LPM Riyadh\n-\nSa’ad Red Sand',
        ),
        _DaySchedule(
          dayLabel: 'Day 3:',
          morning: 'Brew92\n-\nWadi Hanifa Bicycles',
          afternoon: 'BLY’S\n-\nRUSH',
          evening: 'Burger\nBoutique',
        ),
      ],
      nearby: const [
        'Al-Dahna Desert (17 min).',
        'Boulevard World (19 min).',
        'Gravity Riyadh (21 min).',
      ],
      distant: const [
        'Edge of the World (1 h).',
        'Riyadh Safari (43 min).',
        'wadi namar (31 min).',
      ],
      event: const [
        'LIV Golf Riyadh.',
        'Date: December.',
        'Time: 4 PM - 2 AM.',
        'Location: Golf Saudi.',
        'Description: International golf championship featuring global players..',
      ],
      totalBudget: '5000 - 6500 SAR.',
      buttonColor: _navy,
    ),
    _PlanVisual(
      kind: _PlanKind.family,
      title: 'Family Relax Plan.',
      accent: _pink,
      border: _pink,
      headerBar: const Color(0xFFF2C8D2),
      tableBg: const Color(0xFFE58AA0),
      tableText: Colors.white,
      info: const _PlanInfo(
        city: 'Riyadh.',
        dates: 'from 1 to 3 dec 2026.',
        duration: '3 days and 2 nights.',
        hotel: 'Novotel Riyadh Al Anoud.',
      ),
      schedule: const [
        _DaySchedule(
          dayLabel: 'Day 1:',
          morning: 'Urth Caffe\n-\nHello Park Riyadh',
          afternoon: 'The Cheesecake\nFactory\n-\nMuseum Illusions',
          evening: 'TGI Fridays\n-\nRoshn Front Walk',
        ),
        _DaySchedule(
          dayLabel: 'Day 2:',
          morning: 'Starbucks Reserve',
          afternoon: 'Paul\n-\nWinter Wonderland',
          evening: 'Texas Roadhouse\n-\nBoulevard Fountain',
        ),
        _DaySchedule(
          dayLabel: 'Day 3:',
          morning: 'Riyadh Zoo\nSection B\n-\nKing Abdullah Park',
          afternoon: 'Mamo Michelangelo\n-\nFunXtreme Kids',
          evening: 'The Zone\nRestaurants',
        ),
      ],
      nearby: const [
        'Kids station (6 min).',
        'Snow City (18 min).',
        'House of hype (18 min).',
      ],
      distant: const [
        'Riyadh Safari (1:18 h).',
        'Red Sand Dunes (52 min).',
        'Park Avenue (30 min).',
      ],
      event: const [
        'Noor Riyadh Light Festival.',
        'Date: December.',
        'Time: 6 PM - 11 PM.',
        'Location: Boulevard Riyadh City.',
        'Description: Interactive light shows depicting the evolution of Riyadh..',
      ],
      totalBudget: '4500-6000 SAR.',
      buttonColor: _pink,
    ),
  ];

  List<int> _tabOrder(int selectedIndex) {
    const base = [0, 1, 2]; // cultural, adventure, family
    final pos = base.indexOf(selectedIndex);
    if (pos == -1) return base;
    return [...base.sublist(pos + 1), ...base.sublist(0, pos + 1)];
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    return value.map(_asMap).whereType<Map<String, dynamic>>().toList();
  }

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  TripPlan? _latestTripWithGeneratedPlans(List<TripPlan> plans) {
    if (plans.isEmpty) return null;
    final sorted = List<TripPlan>.from(plans)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (final trip in sorted) {
      if ((trip.generatedPlans?.isNotEmpty ?? false)) {
        return trip;
      }
    }
    return sorted.first;
  }

  List<_PlanVisual> _parsePlans(BuildContext context, TripPlan? sourceTrip) {
    final l10n = context.l10n;
    if (sourceTrip == null || sourceTrip.generatedPlans == null) {
      return _fallbackVisuals;
    }

    final rawPlans = _asMapList(sourceTrip.generatedPlans);
    if (rawPlans.isEmpty) {
      return _fallbackVisuals;
    }

    final parsed = <_PlanVisual>[];

    for (var raw in rawPlans) {
      final p = raw;
      final kindStr = p['kind'] as String? ?? 'family';
      final kind = kindStr == 'cultural'
          ? _PlanKind.cultural
          : kindStr == 'adventure'
          ? _PlanKind.adventure
          : _PlanKind.family;

      Color border = _yellowLine;
      Color accent = _yellow;
      Color headerBar = const Color(0xFFF6E2B9);
      Color tableBg = const Color(0xFFF4D69B);
      Color btnColor = _yellow;

      if (kind == _PlanKind.adventure) {
        border = _navy;
        accent = _navy;
        headerBar = const Color(0xFFB7C8E6);
        tableBg = const Color(0xFF304577);
        btnColor = _navy;
      } else if (kind == _PlanKind.family) {
        border = _pink;
        accent = _pink;
        headerBar = const Color(0xFFF2C8D2);
        tableBg = const Color(0xFFE58AA0);
        btnColor = _pink;
      }

      final accommodationMap =
          _asMap(p['accommodation']) ?? _asMap(p['hotel']) ?? const {};
      final hName = accommodationMap['name'] ?? 'Unknown Hotel';

      final schedules = <_DaySchedule>[];
      final rawSchedule = p['schedule'] ?? p['itinerary'];
      if (rawSchedule is List) {
        for (var d in rawSchedule) {
          final m =
              (d['morning'] as List?)
                  ?.map(
                    (x) => (x['name'] ?? x['title'] ?? '').toString().trim(),
                  )
                  .where((x) => x.isNotEmpty)
                  .join('\\n-\\n') ??
              '';
          final a =
              (d['afternoon'] as List?)
                  ?.map(
                    (x) => (x['name'] ?? x['title'] ?? '').toString().trim(),
                  )
                  .where((x) => x.isNotEmpty)
                  .join('\\n-\\n') ??
              '';
          final e =
              (d['evening'] as List?)
                  ?.map(
                    (x) => (x['name'] ?? x['title'] ?? '').toString().trim(),
                  )
                  .where((x) => x.isNotEmpty)
                  .join('\\n-\\n') ??
              '';
          schedules.add(
            _DaySchedule(
              dayLabel: d['label'] ?? '',
              morning: m,
              afternoon: a,
              evening: e,
            ),
          );
        }
      }

      final nearbyList =
          (p['nearby'] as List?)
              ?.map((x) {
                final name = (x['name'] ?? x['title'] ?? '').toString().trim();
                final distance = x['distance_km']?.toString();
                if (name.isEmpty) return '';
                if (distance == null || distance.trim().isEmpty) return name;
                return "$name ($distance km)";
              })
              .where((x) => x.isNotEmpty)
              .toList() ??
          [];
      final distantList =
          (p['distant'] as List?)
              ?.map((x) {
                final name = (x['name'] ?? x['title'] ?? '').toString().trim();
                final distance = x['distance_km']?.toString();
                if (name.isEmpty) return '';
                if (distance == null || distance.trim().isEmpty) return name;
                return "$name ($distance km)";
              })
              .where((x) => x.isNotEmpty)
              .toList() ??
          [];

      parsed.add(
        _PlanVisual(
          kind: kind,
          title: p['title'] ?? l10n.plansGeneratedPlanTitle,
          accent: accent,
          border: border,
          headerBar: headerBar,
          tableBg: tableBg,
          tableText: Colors.white,
          info: _PlanInfo(
            city: sourceTrip.city,
            dates: 'Generated dynamically',
            duration: '${sourceTrip.days} days',
            hotel: hName,
          ),
          schedule: schedules,
          nearby: nearbyList,
          distant: distantList,
          event: [
            l10n.plansDynamicEventPlaceholder,
            l10n.plansDynamicEventDescription,
          ],
          totalBudget:
              '${(_asDouble(p['totalCost']) ?? 0).toStringAsFixed(0)} SAR',
          buttonColor: btnColor,
        ),
      );
    }
    return parsed;
  }

  PlanDetailData _toDetailData(
    BuildContext context,
    _PlanVisual plan, {
    required String sourceTripPlanId,
    required TripPlan? sourceTrip,
    required Map<String, dynamic>? rawPlan,
  }) {
    final l10n = context.l10n;

    if (sourceTrip != null && rawPlan != null) {
      final hotelMap =
          _asMap(rawPlan['accommodation']) ??
          _asMap(rawPlan['hotel']) ??
          const <String, dynamic>{};
      final hotelName = '${hotelMap['name'] ?? l10n.hotelNameUnknown}';
      final hotelId =
          '${hotelMap['hotelId'] ?? hotelMap['id'] ?? hotelMap['name'] ?? 'hotel'}';
      final hotelLocation = '${hotelMap['location'] ?? ''}';
      final hotelRating = '${hotelMap['rating'] ?? ''}';
      final hotelAmenities = '${hotelMap['amenities'] ?? ''}';
      final hotelBookingUrl = hotelMap['bookingUrl']?.toString();
      final hotelMapsUrl = hotelMap['mapsUrl']?.toString();
      final hotelPricePerNight = _asDouble(hotelMap['pricePerNight']);
      final totalCost = _asDouble(rawPlan['totalCost']);
      final budgetStatus = (rawPlan['budget_status'] ?? rawPlan['budgetStatus'])
          ?.toString();
      final minimumRequired = _asDouble(
        rawPlan['minimum_required'] ?? rawPlan['minimumRequired'],
      );
      var hotelPrice = '';
      if (hotelPricePerNight != null && hotelPricePerNight > 0) {
        final safeTotal = (totalCost != null && totalCost > 0)
            ? totalCost
            : hotelPricePerNight * sourceTrip.days;
        hotelPrice = l10n.plansPricePerNight(
          hotelPricePerNight.toStringAsFixed(0),
        );
        hotelPrice +=
            ' | ${l10n.plansTotalPrice(safeTotal.toStringAsFixed(0))}';
      }

      ActivityItem toActivityItem(Map<String, dynamic> rawActivity) {
        return ActivityItem(
          id: '${rawActivity['activityId'] ?? rawActivity['id'] ?? rawActivity['name'] ?? 'activity'}',
          title: '${rawActivity['name'] ?? ''}',
          location: '${rawActivity['location'] ?? ''}',
          open:
              rawActivity['open']?.toString() ??
              rawActivity['openHours']?.toString(),
          close:
              rawActivity['close']?.toString() ??
              rawActivity['closeHours']?.toString(),
          price: rawActivity['price']?.toString(),
          rating: rawActivity['rating']?.toString(),
          time: rawActivity['time']?.toString(),
          distance: rawActivity['distance_km'] != null
              ? '${rawActivity['distance_km']} km'
              : null,
          bookingUrl: rawActivity['bookingUrl']?.toString(),
          mapsUrl: rawActivity['mapsUrl']?.toString(),
        );
      }

      final days = <DayDetail>[
        for (final day in _asMapList(
          rawPlan['schedule'] ?? rawPlan['itinerary'],
        ))
          DayDetail(
            label: '${day['label'] ?? ''}',
            morning: _asMapList(day['morning']).map(toActivityItem).toList(),
            afternoon: _asMapList(
              day['afternoon'],
            ).map(toActivityItem).toList(),
            evening: _asMapList(day['evening']).map(toActivityItem).toList(),
          ),
      ];

      final nearby = _asMapList(rawPlan['nearby']).map(toActivityItem).toList();
      final distant = _asMapList(
        rawPlan['distant'],
      ).map(toActivityItem).toList();

      final events = _asMapList(rawPlan['events']);
      final eventLines = <String>[];
      for (final event in events) {
        final title = '${event['title'] ?? ''}'.trim();
        final date = '${event['date'] ?? ''}'.trim();
        final time = '${event['time'] ?? ''}'.trim();
        final location = '${event['location'] ?? ''}'.trim();
        final description = '${event['description'] ?? ''}'.trim();
        if (title.isNotEmpty) eventLines.add(title);
        if (date.isNotEmpty) {
          eventLines.add('${l10n.bookingsReceiptDate}: $date');
        }
        if (time.isNotEmpty) {
          eventLines.add('${l10n.plansTimeLabel}: $time');
        }
        if (location.isNotEmpty) {
          eventLines.add('${l10n.adminLabelLocation}: $location');
        }
        if (description.isNotEmpty) {
          eventLines.add('${l10n.plansDescriptionLabel}: $description');
        }
      }

      return PlanDetailData(
        title: '${rawPlan['title'] ?? l10n.plansGeneratedPlanTitle}'
            .replaceAll('.', '')
            .trim(),
        sourceTripPlanId: sourceTripPlanId,
        budgetStatus: budgetStatus,
        minimumRequired: minimumRequired,
        userBudget: sourceTrip.budget,
        headerColor: plan.headerBar,
        borderColor: plan.border,
        accentColor: plan.accent,
        backgroundColor: _cream,
        accommodation: AccommodationInfo(
          id: hotelId,
          name: hotelName,
          location: hotelLocation,
          price: hotelPrice,
          rating: hotelRating,
          amenities: hotelAmenities,
          mapsNote: l10n.actionOpenInMaps,
          bookingUrl: hotelBookingUrl,
          mapsUrl: hotelMapsUrl,
        ),
        days: days,
        nearby: nearby,
        distant: distant,
        eventLines: eventLines,
      );
    }

    List<ActivityItem> fromCell(String cell, String prefix) {
      final chunks = cell
          .split('\\n-\\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (chunks.isEmpty) return const <ActivityItem>[];
      return [
        for (int i = 0; i < chunks.length; i++)
          ActivityItem(id: '$prefix$i', title: chunks[i], location: ''),
      ];
    }

    final fallbackDays = [
      for (int i = 0; i < plan.schedule.length; i++)
        DayDetail(
          label: plan.schedule[i].dayLabel,
          morning: fromCell(plan.schedule[i].morning, 'm$i-'),
          afternoon: fromCell(plan.schedule[i].afternoon, 'a$i-'),
          evening: fromCell(plan.schedule[i].evening, 'e$i-'),
        ),
    ];
    final fallbackNearby = [
      for (int i = 0; i < plan.nearby.length; i++)
        ActivityItem(id: 'n$i', title: plan.nearby[i], location: ''),
    ];
    final fallbackDistant = [
      for (int i = 0; i < plan.distant.length; i++)
        ActivityItem(id: 'd$i', title: plan.distant[i], location: ''),
    ];

    final hotel = AccommodationInfo(
      id: 'h1',
      name: plan.info.hotel,
      location: 'Al Olaya Riyadh.',
      price: '550.00 SAR.',
      rating: '4.2.',
      amenities: 'Restaurant.',
      mapsNote: 'Open in Maps.',
    );

    return PlanDetailData(
      title: plan.title.replaceAll('.', '').trim(),
      sourceTripPlanId: sourceTripPlanId,
      headerColor: plan.headerBar,
      borderColor: plan.border,
      accentColor: plan.accent,
      backgroundColor: _cream,
      accommodation: hotel,
      days: fallbackDays,
      nearby: fallbackNearby,
      distant: fallbackDistant,
      eventLines: plan.event,
    );
  }

  // ---------------- Measuring ----------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _plansFuture = _loadPlans();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAnchors());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPlans();
    }
  }

  void _measureAnchors() {
    final stackCtx = _stackKey.currentContext;
    final cardCtx = _cardKey.currentContext;
    if (stackCtx == null || cardCtx == null) return;

    final stackBox = stackCtx.findRenderObject() as RenderBox?;
    final cardBox = cardCtx.findRenderObject() as RenderBox?;
    if (stackBox == null ||
        cardBox == null ||
        !stackBox.hasSize ||
        !cardBox.hasSize) {
      return;
    }

    final cardTopLeft = cardBox.localToGlobal(Offset.zero, ancestor: stackBox);
    final newCardRect = cardTopLeft & cardBox.size;

    final newPillRects = <int, Rect>{};
    for (int i = 0; i < _pillKeys.length; i++) {
      final pillCtx = _pillKeys[i].currentContext;
      final pillBox = pillCtx?.findRenderObject() as RenderBox?;
      if (pillBox == null || !pillBox.hasSize) continue;
      final pillTopLeft = pillBox.localToGlobal(
        Offset.zero,
        ancestor: stackBox,
      );
      newPillRects[i] = pillTopLeft & pillBox.size;
    }

    setState(() {
      _cardRectInStack = newCardRect;
      _pillRectsInStack
        ..clear()
        ..addAll(newPillRects);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return Scaffold(
        backgroundColor: _cream,
        body: Center(child: Text(context.l10n.errorPleaseLogin)),
      );
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Responsive scale (based on typical 390 width design)
    final w = MediaQuery.of(context).size.width;
    final scale = (w / 390.0).clamp(0.85, 1.20);
    double s(double v) => v * scale;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.navPlans),
        actions: [
          IconButton(
            tooltip: context.l10n.actionRefresh,
            onPressed: _refreshPlans,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<TripPlan>>(
        future: _plansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                context.l10n.errorWithDetails(snapshot.error.toString()),
              ),
            );
          }

          final latestTrip = _latestTripWithGeneratedPlans(snapshot.data ?? []);
          final rawGeneratedPlans = _asMapList(latestTrip?.generatedPlans);
          final displayVisuals = _parsePlans(context, latestTrip);
          if (displayVisuals.isEmpty) return const SizedBox();
          final sourceTripPlanId = latestTrip?.id ?? '';
          final selectedIndex = _selectedIndex.clamp(
            0,
            displayVisuals.length - 1,
          );
          final rawSelectedPlan = selectedIndex < rawGeneratedPlans.length
              ? rawGeneratedPlans[selectedIndex]
              : null;

          final selectedPlan = displayVisuals[selectedIndex];

          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: s(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header bar changes color with selected plan (like your mock)
                  Container(
                    height: s(56),
                    padding: EdgeInsets.symmetric(horizontal: s(16)),
                    alignment: isRtl
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    color: selectedPlan.headerBar,
                    child: Text(
                      context.l10n.plansSelectFavoriteHeader,
                      style: TextStyle(
                        fontSize: s(26),
                        fontFamily: 'serif',
                        color: _text,
                        height: 1.15,
                      ),
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                  SizedBox(height: s(18)),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: s(16)),
                    child: Stack(
                      key: _stackKey,
                      clipBehavior: Clip.none,
                      children: [
                        // 3 frames always (one per plan) - selected on top
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _FramesPainter(
                                plans: displayVisuals,
                                selectedIndex: _selectedIndex,
                                pillRects: _pillRectsInStack,
                                cardRect: _cardRectInStack,
                                isRtl: isRtl,
                                scale: scale,
                              ),
                            ),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _PlanTabsOneSide(
                              plans: displayVisuals,
                              order: _tabOrder(_selectedIndex),
                              selectedIndex: _selectedIndex,
                              isRtl: isRtl,
                              scale: scale,
                              pillKeys: _pillKeys,
                              onSelected: (i) {
                                setState(() => _selectedIndex = i);
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => _measureAnchors(),
                                );
                              },
                            ),
                            SizedBox(height: s(50)),

                            // Card content (only selected plan details)
                            _PlanDetailCard(
                              cardKey: _cardKey,
                              plan: selectedPlan,
                              isRtl: isRtl,
                              scale: scale,
                              onSelect: () async {
                                try {
                                  if (latestTrip != null) {
                                    await _tripRepo.markPlanSelection(
                                      tripPlanId: latestTrip.id,
                                      selectedPlanIndex: selectedIndex,
                                      selectedPlanTitle: selectedPlan.title,
                                    );
                                  }
                                  if (!context.mounted) return;
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PlanDetailScreen(
                                        data: _toDetailData(
                                          context,
                                          selectedPlan,
                                          sourceTripPlanId: sourceTripPlanId,
                                          sourceTrip: latestTrip,
                                          rawPlan: rawSelectedPlan,
                                        ),
                                      ),
                                    ),
                                  );
                                  if (!mounted) return;
                                  _refreshPlans();
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n.errorWithDetails(
                                          e.toString(),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: s(14)),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final payload =
                                      latestTrip != null &&
                                          rawGeneratedPlans.isNotEmpty
                                      ? PlanComparisonPayload(
                                          trip: latestTrip,
                                          generatedPlans: rawGeneratedPlans,
                                        )
                                      : null;
                                  await context.push(
                                    '/plans/compare',
                                    extra: payload,
                                  );
                                  if (!mounted) return;
                                  _refreshPlans();
                                },
                                icon: const Icon(Icons.compare_arrows),
                                label: Text(context.l10n.comparePlansCta),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: s(24)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ---------------- Tabs (all one side) ---------------- */

String _localizedPlanTitle(BuildContext context, _PlanVisual plan) {
  final l10n = context.l10n;
  switch (plan.kind) {
    case _PlanKind.family:
      return l10n.plansFamilyTitle;
    case _PlanKind.cultural:
      return l10n.plansCulturalTitle;
    case _PlanKind.adventure:
      return l10n.plansAdventureTitle;
  }
}

class _PlanTabsOneSide extends StatelessWidget {
  final List<_PlanVisual> plans;
  final List<int> order;
  final int selectedIndex;
  final bool isRtl;
  final double scale;
  final List<GlobalKey> pillKeys;
  final ValueChanged<int> onSelected;

  const _PlanTabsOneSide({
    required this.plans,
    required this.order,
    required this.selectedIndex,
    required this.isRtl,
    required this.scale,
    required this.pillKeys,
    required this.onSelected,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final visible = order.where((i) => i != selectedIndex).toList();
    return Column(
      children: [
        for (int i = 0; i < visible.length; i++) ...[
          _PlanTabRowOneSide(
            pillKey: pillKeys[visible[i]], // key per plan index
            title: _localizedPlanTitle(context, plans[visible[i]]),
            color: plans[visible[i]].accent,
            lineColor: plans[visible[i]].border,
            isSelected: false,
            isRtl: isRtl,
            scale: scale,
            onTap: () => onSelected(visible[i]),
          ),
          if (i != visible.length - 1) SizedBox(height: s(14)),
        ],
      ],
    );
  }
}

class _PlanTabRowOneSide extends StatelessWidget {
  final GlobalKey pillKey;
  final String title;
  final Color color;
  final Color lineColor;
  final bool isSelected;
  final bool isRtl;
  final double scale;
  final VoidCallback onTap;

  const _PlanTabRowOneSide({
    required this.pillKey,
    required this.title,
    required this.color,
    required this.lineColor,
    required this.isSelected,
    required this.isRtl,
    required this.scale,
    required this.onTap,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    // One-side layout: pill at "start" side, line extends to the other side.
    final pill = Material(
      color: Colors.transparent,
      elevation: isSelected ? 2 : 0,
      shadowColor: Colors.black26,
      child: Container(
        key: pillKey,
        padding: EdgeInsets.symmetric(horizontal: s(18), vertical: s(8)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(s(26)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: s(18),
            fontFamily: 'serif',
            color: _PlansScreenState._text,
            height: 1.1,
          ),
        ),
      ),
    );

    final line = Expanded(
      child: Container(
        height: s(2),
        margin: EdgeInsets.only(
          left: isRtl ? 0 : s(8),
          right: isRtl ? s(8) : 0,
        ),
        color: lineColor,
      ),
    );

    return InkWell(
      onTap: onTap,
      child: Row(children: isRtl ? [line, pill] : [pill, line]),
    );
  }
}

/* ---------------- Detail Card (NO duplicate title) ---------------- */

class _PlanDetailCard extends StatelessWidget {
  final GlobalKey cardKey;
  final _PlanVisual plan;
  final bool isRtl;
  final double scale;
  final Future<void> Function() onSelect;

  const _PlanDetailCard({
    required this.cardKey,
    required this.plan,
    required this.isRtl,
    required this.scale,
    required this.onSelect,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final durationCount = int.tryParse(plan.info.duration.trim());
    final durationText = durationCount == null
        ? plan.info.duration
        : l10n.plansDurationValue(durationCount);
    final datesText =
        plan.info.dates == 'Generated dynamically' ||
            plan.info.dates == l10n.plansGeneratedDynamically
        ? l10n.plansGeneratedDynamically
        : plan.info.dates;

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = (constraints.maxWidth * 0.6).clamp(160.0, 220.0);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              key: cardKey,
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(s(16), s(28), s(16), s(16)),
              decoration: BoxDecoration(
                color: _PlansScreenState._cream,
                borderRadius: BorderRadius.circular(s(12)),
                border: Border.all(color: plan.border, width: s(3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (plan.note != null) ...[
                    _InfoLine(
                      icon: Icons.person_outline,
                      text: plan.note!,
                      color: plan.accent,
                      isRtl: isRtl,
                      scale: scale,
                    ),
                    SizedBox(height: s(12)),
                  ],
                  _InfoLine(
                    icon: Icons.location_on_outlined,
                    text: '${l10n.plansLabelSelectedCity} : ${plan.info.city}',
                    color: plan.accent,
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  _InfoLine(
                    icon: Icons.calendar_today_outlined,
                    text: '${l10n.plansLabelDates} : $datesText',
                    color: plan.accent,
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  _InfoLine(
                    icon: Icons.access_time,
                    text: '${l10n.plansLabelTripDuration} : $durationText',
                    color: plan.accent,
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  _InfoLine(
                    icon: Icons.home_outlined,
                    text: '${l10n.plansLabelHotel} : ${plan.info.hotel}',
                    color: plan.accent,
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  SizedBox(height: s(14)),
                  _PlanTable(plan: plan, isRtl: isRtl, scale: scale),
                  SizedBox(height: s(14)),
                  _SectionList(
                    icon: Icons.directions_walk,
                    title: '${l10n.plansLabelNearbyAttractions}:',
                    color: plan.accent,
                    items: plan.nearby,
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  _SectionList(
                    icon: Icons.map_outlined,
                    title: '${l10n.plansLabelDistantAttractions}:',
                    color: plan.accent,
                    items: plan.distant,
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  _SectionList(
                    icon: Icons.lightbulb_outline,
                    title: '${l10n.plansLabelEvents}:',
                    color: plan.accent,
                    items: plan.event,
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  _SectionList(
                    icon: Icons.account_balance_wallet_outlined,
                    title: '${l10n.plansLabelTotalBudget}:',
                    color: plan.accent,
                    items: [plan.totalBudget],
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  SizedBox(height: s(10)),
                  Center(
                    child: SizedBox(
                      width: buttonWidth,
                      height: s(60),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: plan.buttonColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(s(22)),
                          ),
                        ),
                        onPressed: () {
                          onSelect();
                        },
                        child: Text(
                          l10n.selectPlanCta,
                          style: TextStyle(
                            fontSize: s(18),
                            fontFamily: 'serif',
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: isRtl ? null : s(12),
              right: isRtl ? s(12) : null,
              top: -s(16),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: s(18),
                  vertical: s(8),
                ),
                decoration: BoxDecoration(
                  color: plan.accent,
                  borderRadius: BorderRadius.circular(s(22)),
                ),
                child: Text(
                  _localizedPlanTitle(context, plan),
                  style: TextStyle(
                    fontSize: s(18),
                    fontFamily: 'serif',
                    color: _PlansScreenState._text,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isRtl;
  final double scale;

  const _InfoLine({
    required this.icon,
    required this.text,
    required this.color,
    required this.isRtl,
    required this.scale,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: s(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Icon(icon, size: s(17), color: color),
          SizedBox(width: s(8)),
          Expanded(
            child: Text(
              text,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontSize: s(15),
                fontFamily: 'serif',
                color: _PlansScreenState._text,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanTable extends StatelessWidget {
  final _PlanVisual plan;
  final bool isRtl;
  final double scale;

  const _PlanTable({
    required this.plan,
    required this.isRtl,
    required this.scale,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(s(18)),
      child: Container(
        color: plan.tableBg,
        child: Table(
          border: TableBorder.symmetric(
            inside: BorderSide(
              color: Colors.white.withValues(alpha: 0.7),
              width: s(1),
            ),
          ),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
          },
          children: [
            _tableHeader(context),
            for (final row in plan.schedule) _tableRow(row),
          ],
        ),
      ),
    );
  }

  TableRow _tableHeader(BuildContext context) {
    final l10n = context.l10n;
    final headers = isRtl
        ? [
            l10n.plansTableEvening,
            l10n.plansTableAfternoon,
            l10n.plansTableMorning,
            l10n.plansTableDays,
          ]
        : [
            l10n.plansTableDays,
            l10n.plansTableMorning,
            l10n.plansTableAfternoon,
            l10n.plansTableEvening,
          ];
    return TableRow(
      decoration: BoxDecoration(color: plan.tableBg),
      children: [for (final h in headers) _cell(h, isHeader: true)],
    );
  }

  TableRow _tableRow(_DaySchedule row) {
    final cells = isRtl
        ? [row.evening, row.afternoon, row.morning, row.dayLabel]
        : [row.dayLabel, row.morning, row.afternoon, row.evening];
    return TableRow(children: [for (final v in cells) _cell(v)]);
  }

  Widget _cell(String text, {bool isHeader = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s(6), horizontal: s(5)),
      child: Text(
        text.isEmpty ? ' ' : text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: s(isHeader ? 13 : 11.5),
          fontFamily: 'serif',
          color: plan.tableText,
          height: 1.2,
        ),
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<String> items;
  final bool isRtl;
  final double scale;

  const _SectionList({
    required this.icon,
    required this.title,
    required this.color,
    required this.items,
    required this.isRtl,
    required this.scale,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: s(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Icon(icon, size: s(18), color: color),
          SizedBox(width: s(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: isRtl
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: s(16.5),
                    fontFamily: 'serif',
                    color: _PlansScreenState._text,
                    height: 1.2,
                  ),
                ),
                for (final item in items)
                  Padding(
                    padding: EdgeInsets.only(top: s(4)),
                    child: Text(
                      '•  $item',
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: s(15),
                        fontFamily: 'serif',
                        color: _PlansScreenState._text,
                        height: 1.25,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- Painter: 3 frames stacked + selected on top ---------------- */

class _FramesPainter extends CustomPainter {
  final List<_PlanVisual> plans;
  final int selectedIndex;
  final Map<int, Rect> pillRects;
  final Rect? cardRect;
  final bool isRtl;
  final double scale;

  _FramesPainter({
    required this.plans,
    required this.selectedIndex,
    required this.pillRects,
    required this.cardRect,
    required this.isRtl,
    required this.scale,
  });

  double s(double v) => v * scale;

  @override
  void paint(Canvas canvas, Size size) {
    final c = cardRect;
    if (c == null) return;

    // Layering: selected is depth 0 (front), others behind as depth 1/2
    final all = List<int>.generate(plans.length, (i) => i);
    final others = all.where((i) => i != selectedIndex).toList();

    // Draw back -> front
    final drawOrder = <int>[...others, selectedIndex];

    int depthOf(int i) {
      if (i == selectedIndex) return 0;
      return others.indexOf(i) + 1; // 1..2
    }

    // Shift direction: keep all to one side
    final sideSign = isRtl ? -1.0 : 1.0;

    for (final i in drawOrder) {
      final depth = depthOf(i);

      final strokeW = (i == selectedIndex) ? s(3.2) : s(2.4);
      final paint = Paint()
        ..color = plans[i].border
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW;

      // Frames stacked "under each other"
      final dx = sideSign * depth * s(10);
      final dy = depth * s(10);

      final frameRect = c.shift(Offset(dx, dy));
      final radius = Radius.circular(s(12));
      final rr = RRect.fromRectAndRadius(frameRect, radius);

      // Draw full rectangle (square/box)
      canvas.drawRRect(rr, paint);

      // Connector from pill to its own frame (always)
      final pill = pillRects[i];
      if (pill != null) {
        final start = Offset(isRtl ? pill.left : pill.right, pill.center.dy);

        // connect to the "outer" side of the frame
        final joinX = isRtl ? (frameRect.left) : (frameRect.right);
        final joinY = frameRect.top + s(26);

        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(joinX + (isRtl ? -s(8) : s(8)), start.dy)
          ..lineTo(joinX + (isRtl ? -s(8) : s(8)), joinY)
          ..lineTo(joinX, joinY);

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FramesPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.cardRect != cardRect ||
        oldDelegate.pillRects != pillRects ||
        oldDelegate.isRtl != isRtl ||
        oldDelegate.scale != scale;
  }
}

/* ---------------- Models ---------------- */

class _PlanInfo {
  final String city;
  final String dates;
  final String duration;
  final String hotel;

  const _PlanInfo({
    required this.city,
    required this.dates,
    required this.duration,
    required this.hotel,
  });
}

class _DaySchedule {
  final String dayLabel;
  final String morning;
  final String afternoon;
  final String evening;

  const _DaySchedule({
    required this.dayLabel,
    required this.morning,
    required this.afternoon,
    required this.evening,
  });
}

class _PlanVisual {
  final _PlanKind kind;
  final String title;
  final Color accent;
  final Color border;
  final Color headerBar;
  final Color tableBg;
  final Color tableText;
  final _PlanInfo info;
  final List<_DaySchedule> schedule;
  final List<String> nearby;
  final List<String> distant;
  final List<String> event;
  final String totalBudget;
  final Color buttonColor;
  final String? note;

  const _PlanVisual({
    required this.kind,
    required this.title,
    required this.accent,
    required this.border,
    required this.headerBar,
    required this.tableBg,
    required this.tableText,
    required this.info,
    required this.schedule,
    required this.nearby,
    required this.distant,
    required this.event,
    required this.totalBudget,
    required this.buttonColor,
    this.note,
  });
}

enum _PlanKind { cultural, adventure, family }
