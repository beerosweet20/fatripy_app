import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/supported_cities.dart';
import '../../../data/repositories/trip_repository.dart';
import '../../../domain/entities/trip_plan.dart';
import '../../localization/app_localizations_ext.dart';
import 'plan_comparison_screen.dart';
import 'plan_detail_builder.dart';
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
      note: 'Prioritizes museums, heritage districts, and local culture.',
      hotelChoices: const [
        'Bab Samhan Diriyah Hotel.',
        'Fairmont Riyadh.',
        'Narcissus Riyadh Hotel & Spa.',
      ],
      possiblePlaces: const [
        'Al Masmak Fortress',
        'King Abdulaziz Historical Center',
        'Souk Al Zal',
        'Al-Turaif',
      ],
      hasNearbyOptions: true,
      hasDistantOptions: true,
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
      note: 'Prioritizes active attractions and outdoor experiences.',
      hotelChoices: const [
        'Hyatt Regency Riyadh Olaya.',
        'Hilton Riyadh Hotel.',
        'Radisson Blu Riyadh.',
      ],
      possiblePlaces: const [
        'Red Sand Dunes',
        'Arena VR',
        'Riyadh Adventure',
        'Wadi Hanifa',
      ],
      hasNearbyOptions: true,
      hasDistantOptions: true,
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
      note: 'Balanced pacing for families with a more relaxed rhythm.',
      hotelChoices: const [
        'Novotel Riyadh Al Anoud.',
        'Movenpick Hotel Riyadh.',
        'Braira Qurtubah Hotel.',
      ],
      possiblePlaces: const [
        'Hello Park Riyadh',
        'Museum of Illusions',
        'Winter Wonderland',
        'King Abdullah Park',
      ],
      hasNearbyOptions: true,
      hasDistantOptions: true,
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

  String _defaultHighlightForKind(BuildContext context, _PlanKind kind) {
    final l10n = context.l10n;
    switch (kind) {
      case _PlanKind.cultural:
        return l10n.compareCulturalHighlight;
      case _PlanKind.adventure:
        return l10n.compareAdventureHighlight;
      case _PlanKind.family:
        return l10n.compareFamilyHighlight;
    }
  }

  String _primaryPlanNote(
    BuildContext context,
    PlanDetailData detailData,
    _PlanKind kind,
  ) {
    for (final reason in detailData.planReasons) {
      final cleaned = reason.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }
    return _defaultHighlightForKind(context, kind);
  }

  List<String> _hotelChoices(PlanDetailData detailData) {
    final hotels = <String>[];
    final seen = <String>{};

    for (final option in detailData.resolvedHotelOptions) {
      final name = option.accommodation.name.trim();
      if (name.isEmpty) continue;
      final key = name.toLowerCase();
      if (seen.add(key)) {
        hotels.add(name);
      }
    }

    return hotels;
  }

  List<String> _possiblePlaces(PlanDetailData detailData) {
    final places = <String>[];
    final seen = <String>{};

    void addPlace(String text) {
      final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (cleaned.isEmpty) return;
      final key = cleaned.toLowerCase();
      if (seen.add(key)) {
        places.add(cleaned);
      }
    }

    for (final option in detailData.resolvedHotelOptions) {
      for (final day in option.days) {
        for (final item in day.morning) {
          addPlace(item.title);
        }
        for (final item in day.afternoon) {
          addPlace(item.title);
        }
        for (final item in day.evening) {
          addPlace(item.title);
        }
      }
    }

    if (places.isEmpty) {
      for (final option in detailData.resolvedHotelOptions) {
        for (final item in option.nearby) {
          addPlace(item.title);
        }
        for (final item in option.distant) {
          addPlace(item.title);
        }
      }
    }

    return places.take(5).toList();
  }

  bool _hasNearbyOptions(PlanDetailData detailData) {
    return detailData.resolvedHotelOptions.any(
      (option) => option.nearby.isNotEmpty,
    );
  }

  bool _hasDistantOptions(PlanDetailData detailData) {
    return detailData.resolvedHotelOptions.any(
      (option) => option.distant.isNotEmpty,
    );
  }

  static const TourGuideInfo _fallbackTourGuide = TourGuideInfo(
    name: 'Mohammed Atef',
    experienceYears: '5',
    languages: 'Arabic-English',
    phone: '0511119999',
    rating: '4.4',
    description:
        'A certified tour guide with strong field experience in nature exploration. He designs and leads safe, memorable, and authentic travel experiences for every traveler',
  );

  int _extractDayNumber(dynamic rawLabel, {required int fallbackIndex}) {
    final text = (rawLabel ?? '').toString();
    final match = RegExp(r'(\d+)').firstMatch(text);
    final parsed = match == null ? null : int.tryParse(match.group(1)!);
    if (parsed != null && parsed > 0) return parsed;
    return fallbackIndex + 1;
  }

  String _localizedDayLabel(
    BuildContext context,
    dynamic rawLabel, {
    required int fallbackIndex,
  }) {
    final dayNumber = _extractDayNumber(rawLabel, fallbackIndex: fallbackIndex);
    return '${context.l10n.plansDayLabel(dayNumber)}:';
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

  List<_PlanVisual> _localizedFallbackVisuals(BuildContext context) {
    final l10n = context.l10n;
    return List<_PlanVisual>.generate(_fallbackVisuals.length, (planIndex) {
      final visual = _fallbackVisuals[planIndex];
      final normalizedCity = visual.info.city.replaceAll('.', '').trim();
      return _PlanVisual(
        kind: visual.kind,
        title: visual.title,
        accent: visual.accent,
        border: visual.border,
        headerBar: visual.headerBar,
        tableBg: visual.tableBg,
        tableText: visual.tableText,
        info: _PlanInfo(
          city: localizeCityLabel(l10n, normalizedCity),
          dates: visual.info.dates,
          duration: visual.info.duration,
          hotel: visual.info.hotel,
        ),
        note: _defaultHighlightForKind(context, visual.kind),
        hotelChoices: visual.hotelChoices,
        possiblePlaces: visual.possiblePlaces,
        hasNearbyOptions: visual.hasNearbyOptions,
        hasDistantOptions: visual.hasDistantOptions,
        schedule: [
          for (int dayIndex = 0; dayIndex < visual.schedule.length; dayIndex++)
            _DaySchedule(
              dayLabel: _localizedDayLabel(
                context,
                visual.schedule[dayIndex].dayLabel,
                fallbackIndex: dayIndex,
              ),
              morning: visual.schedule[dayIndex].morning,
              afternoon: visual.schedule[dayIndex].afternoon,
              evening: visual.schedule[dayIndex].evening,
            ),
        ],
        nearby: visual.nearby,
        distant: visual.distant,
        event: visual.event,
        totalBudget: visual.totalBudget,
        buttonColor: visual.buttonColor,
      );
    });
  }

  List<_PlanVisual> _parsePlans(BuildContext context, TripPlan? sourceTrip) {
    final l10n = context.l10n;
    if (sourceTrip == null || sourceTrip.generatedPlans == null) {
      return _localizedFallbackVisuals(context);
    }

    final rawPlans = _asMapList(sourceTrip.generatedPlans);
    if (rawPlans.isEmpty) {
      return _localizedFallbackVisuals(context);
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

      final detailData = PlanDetailBuilder.buildDetailData(
        context,
        trip: sourceTrip,
        rawPlan: p,
        resolvedTitle: '${p['title'] ?? l10n.plansGeneratedPlanTitle}'
            .replaceAll('.', '')
            .trim(),
      );
      final accommodationMap =
          _asMap(p['accommodation']) ?? _asMap(p['hotel']) ?? const {};
      final hName = accommodationMap['name'] ?? 'Unknown Hotel';

      final schedules = <_DaySchedule>[];
      final rawSchedule = p['schedule'] ?? p['itinerary'];
      if (rawSchedule is List) {
        for (int dayIndex = 0; dayIndex < rawSchedule.length; dayIndex++) {
          final d = _asMap(rawSchedule[dayIndex]) ?? const {};
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
              dayLabel: _localizedDayLabel(
                context,
                d['label'],
                fallbackIndex: dayIndex,
              ),
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
            city: localizeCityLabel(l10n, sourceTrip.city),
            dates: 'Generated dynamically',
            duration: '${sourceTrip.days} days',
            hotel: hName,
          ),
          note: _primaryPlanNote(context, detailData, kind),
          hotelChoices: _hotelChoices(detailData),
          possiblePlaces: _possiblePlaces(detailData),
          hasNearbyOptions: _hasNearbyOptions(detailData),
          hasDistantOptions: _hasDistantOptions(detailData),
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
    if (sourceTrip != null && rawPlan != null) {
      return PlanDetailBuilder.buildDetailData(
        context,
        trip: sourceTrip,
        rawPlan: rawPlan,
        resolvedTitle: _localizedPlanTitle(context, plan),
        sourceTripPlanId: sourceTripPlanId,
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
          label: _localizedDayLabel(
            context,
            plan.schedule[i].dayLabel,
            fallbackIndex: i,
          ),
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
      title: _localizedPlanTitle(context, plan),
      sourceTripPlanId: sourceTripPlanId,
      headerColor: plan.headerBar,
      borderColor: plan.border,
      accentColor: plan.accent,
      backgroundColor: Color.lerp(_cream, plan.headerBar, 0.42) ?? _cream,
      accommodation: hotel,
      tourGuide: _fallbackTourGuide,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PlanTabsOneSide(
                          plans: displayVisuals,
                          selectedIndex: selectedIndex,
                          isRtl: isRtl,
                          scale: scale,
                          onSelected: (i) {
                            setState(() => _selectedIndex = i);
                          },
                        ),
                        SizedBox(height: s(28)),

                        // Card content (only selected plan details)
                        _PlanDetailCard(
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
                              await context.push(
                                '/plans/detail',
                                extra: _toDetailData(
                                  context,
                                  selectedPlan,
                                  sourceTripPlanId: sourceTripPlanId,
                                  sourceTrip: latestTrip,
                                  rawPlan: rawSelectedPlan,
                                ),
                              );
                              if (!mounted) return;
                              _refreshPlans();
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n.errorWithDetails(e.toString()),
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
  final int selectedIndex;
  final bool isRtl;
  final double scale;
  final ValueChanged<int> onSelected;

  const _PlanTabsOneSide({
    required this.plans,
    required this.selectedIndex,
    required this.isRtl,
    required this.scale,
    required this.onSelected,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final visibleIndexes = <int>[
      for (int i = 0; i < plans.length; i++)
        if (i != selectedIndex) i,
    ];

    if (visibleIndexes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isRtl
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          for (int row = 0; row < visibleIndexes.length; row++) ...[
            _PlanTabRowOneSide(
              title: _localizedPlanTitle(context, plans[visibleIndexes[row]]),
              color: plans[visibleIndexes[row]].accent,
              borderColor: plans[visibleIndexes[row]].border,
              scale: scale,
              onTap: () => onSelected(visibleIndexes[row]),
            ),
            if (row != visibleIndexes.length - 1) SizedBox(height: s(12)),
          ],
        ],
      ),
    );
  }
}

class _PlanTabRowOneSide extends StatelessWidget {
  final String title;
  final Color color;
  final Color borderColor;
  final double scale;
  final VoidCallback onTap;

  const _PlanTabRowOneSide({
    required this.title,
    required this.color,
    required this.borderColor,
    required this.scale,
    required this.onTap,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(s(26)),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: s(18), vertical: s(10)),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(s(26)),
            border: Border.all(color: borderColor, width: s(1.8)),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: s(17),
              fontFamily: 'serif',
              color: _PlansScreenState._text,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------- Detail Card (NO duplicate title) ---------------- */

class _PlanDetailCard extends StatelessWidget {
  final _PlanVisual plan;
  final bool isRtl;
  final double scale;
  final Future<void> Function() onSelect;

  const _PlanDetailCard({
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
                      icon: Icons.auto_awesome_outlined,
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
                  SizedBox(height: s(14)),
                  _SummarySectionList(
                    icon: Icons.hotel_outlined,
                    title: '${l10n.compareHotelsSectionTitle}:',
                    color: plan.accent,
                    items: plan.hotelChoices.isEmpty
                        ? <String>[l10n.hotelNameUnknown]
                        : plan.hotelChoices,
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  _SummarySectionList(
                    icon: Icons.place_outlined,
                    title: '${l10n.comparePlacesSectionTitle}:',
                    color: plan.accent,
                    items: plan.possiblePlaces.isEmpty
                        ? <String>[l10n.comparePlacesFallback]
                        : plan.possiblePlaces,
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  _SummarySectionList(
                    icon: Icons.directions_walk,
                    title: '${l10n.plansLabelNearbyAttractions}:',
                    color: plan.accent,
                    items: <String>[
                      plan.hasNearbyOptions
                          ? l10n.compareNearbySummary
                          : l10n.planDetailNoActivities,
                    ],
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  _SummarySectionList(
                    icon: Icons.map_outlined,
                    title: '${l10n.plansLabelDistantAttractions}:',
                    color: plan.accent,
                    items: <String>[
                      plan.hasDistantOptions
                          ? l10n.compareDistantSummary
                          : l10n.planDetailNoActivities,
                    ],
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  _SummarySectionList(
                    icon: Icons.lightbulb_outline,
                    title: '${l10n.plansLabelEvents}:',
                    color: plan.accent,
                    items: <String>[
                      l10n.compareHotelActivitiesNote,
                      l10n.compareEventsDeferredNote,
                    ],
                    isRtl: isRtl,
                    scale: scale,
                  ),
                  _SummarySectionList(
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

class _SummarySectionList extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<String> items;
  final bool isRtl;
  final double scale;

  const _SummarySectionList({
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
                      '- $item',
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

// ignore: unused_element
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
  final List<String> hotelChoices;
  final List<String> possiblePlaces;
  final bool hasNearbyOptions;
  final bool hasDistantOptions;
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
    required this.hotelChoices,
    required this.possiblePlaces,
    required this.hasNearbyOptions,
    required this.hasDistantOptions,
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
