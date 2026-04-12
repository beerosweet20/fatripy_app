import 'package:flutter/material.dart';

import '../../../domain/entities/trip_plan.dart';
import '../../localization/app_localizations_ext.dart';
import 'plan_detail_screen.dart';

typedef JsonMap = Map<String, dynamic>;

class PlanColorPalette {
  final Color headerColor;
  final Color borderColor;
  final Color accentColor;
  final Color backgroundColor;

  const PlanColorPalette({
    required this.headerColor,
    required this.borderColor,
    required this.accentColor,
    required this.backgroundColor,
  });
}

class PlanDetailBuilder {
  static const Color _cream = Color(0xFFFFF7E5);

  static const Map<String, TourGuideInfo>
  _cityGuideFallbacks = <String, TourGuideInfo>{
    'Riyadh': TourGuideInfo(
      name: 'Mohammed Atef',
      experienceYears: '5',
      languages: 'Arabic - English',
      phone: '0511111999',
      rating: '4.4',
      description:
          'Certified guide for Najdi heritage, museums, and cultural districts in Riyadh.',
    ),
    'Jeddah': TourGuideInfo(
      name: 'Lina Hassan',
      experienceYears: '8',
      languages: 'Arabic - English',
      phone: '0522222888',
      rating: '4.8',
      description:
          'Specializes in Historic Jeddah, art walks, and family cultural experiences by the waterfront.',
    ),
    'Mecca': TourGuideInfo(
      name: 'Abdulrahman Al Harbi',
      experienceYears: '9',
      languages: 'Arabic - English - Urdu',
      phone: '0533200441',
      rating: '4.9',
      description:
          'Experienced cultural guide for heritage museums, exhibitions, and visitor-friendly city landmarks in Makkah.',
    ),
    'Medina': TourGuideInfo(
      name: 'Sara Al Zahrani',
      experienceYears: '6',
      languages: 'Arabic - English',
      phone: '0541188332',
      rating: '4.7',
      description:
          'Focuses on Madinah history, museums, and calm family-oriented cultural visits.',
    ),
    'Dammam': TourGuideInfo(
      name: 'Yousef Al Qahtani',
      experienceYears: '7',
      languages: 'Arabic - English',
      phone: '0551177334',
      rating: '4.6',
      description:
          'Guides visitors through Eastern Province heritage sites, corniche culture, and local family attractions.',
    ),
    'Khobar': TourGuideInfo(
      name: 'Norah Al Dosari',
      experienceYears: '6',
      languages: 'Arabic - English',
      phone: '0561144221',
      rating: '4.7',
      description:
          'Curates relaxed cultural walks across Khobar waterfronts, galleries, and family-friendly districts.',
    ),
    'Abha': TourGuideInfo(
      name: 'Aisha Asiri',
      experienceYears: '8',
      languages: 'Arabic - English',
      phone: '0504411882',
      rating: '4.9',
      description:
          'Mountain culture expert for heritage villages, art districts, and panoramic experiences in Abha.',
    ),
    'Taif': TourGuideInfo(
      name: 'Faisal Al Thaqafi',
      experienceYears: '7',
      languages: 'Arabic - English',
      phone: '0509933772',
      rating: '4.8',
      description:
          'Known for Taif rose routes, heritage markets, and scenic cultural itineraries for families.',
    ),
    'Jazan': TourGuideInfo(
      name: 'Huda Al Hakami',
      experienceYears: '6',
      languages: 'Arabic - English',
      phone: '0537711008',
      rating: '4.6',
      description:
          'Designs cultural programs around Jazan heritage, local crafts, coastal life, and family-friendly stops.',
    ),
  };

  static PlanColorPalette paletteForKind(String rawKind) {
    final kind = rawKind.toLowerCase().trim();
    final headerColor = kind == 'adventure'
        ? const Color(0xFFB7C8E6)
        : kind == 'family'
        ? const Color(0xFFF2C8D2)
        : const Color(0xFFF6E2B9);
    final borderColor = kind == 'adventure'
        ? const Color(0xFF31487A)
        : kind == 'family'
        ? const Color(0xFFE18299)
        : const Color(0xFFF0C57D);
    return PlanColorPalette(
      headerColor: headerColor,
      borderColor: borderColor,
      accentColor: borderColor,
      backgroundColor: Color.lerp(_cream, headerColor, 0.42) ?? _cream,
    );
  }

  static JsonMap? asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static List<JsonMap> asMapList(dynamic value) {
    if (value is! List) {
      return const <JsonMap>[];
    }
    return value.map(asMap).whereType<JsonMap>().toList();
  }

  static double? asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return double.tryParse(trimmed);
    }
    return null;
  }

  static String asText(dynamic value) => value?.toString().trim() ?? '';

  static PlanDetailData buildDetailData(
    BuildContext context, {
    required TripPlan trip,
    required JsonMap rawPlan,
    required String resolvedTitle,
    String? sourceTripPlanId,
  }) {
    final l10n = context.l10n;
    final kind = asText(rawPlan['kind']).toLowerCase();
    final palette = paletteForKind(kind);
    final planReasons = _parseStringList(
      rawPlan['selectionReasons'] ??
          rawPlan['recommendationReasons'] ??
          rawPlan['planReasons'],
    );
    final events = asMapList(rawPlan['events']);
    final eventLines = _buildEventLines(l10n, events);
    final tourGuide = _resolveTourGuide(rawPlan, city: trip.city, kind: kind);
    final hotelOptions = _buildHotelOptions(l10n, trip, rawPlan);

    final primaryOption = hotelOptions.isNotEmpty
        ? hotelOptions.first
        : HotelPlanOption(
            accommodation: AccommodationInfo(
              id: 'hotel',
              name: l10n.hotelNameUnknown,
              location: '',
              price: '',
              rating: '',
              amenities: '',
              mapsNote: l10n.actionOpenInMaps,
            ),
            days: const <DayDetail>[],
            nearby: const <ActivityItem>[],
            distant: const <ActivityItem>[],
          );

    return PlanDetailData(
      title: resolvedTitle,
      sourceTripPlanId: sourceTripPlanId ?? trip.id,
      budgetStatus: asText(rawPlan['budget_status'] ?? rawPlan['budgetStatus']),
      minimumRequired: asDouble(
        rawPlan['minimum_required'] ?? rawPlan['minimumRequired'],
      ),
      userBudget: trip.budget,
      headerColor: palette.headerColor,
      borderColor: palette.borderColor,
      accentColor: palette.accentColor,
      backgroundColor: palette.backgroundColor,
      accommodation: primaryOption.accommodation,
      tourGuide: tourGuide,
      days: primaryOption.days,
      nearby: primaryOption.nearby,
      distant: primaryOption.distant,
      eventLines: eventLines,
      planReasons: planReasons,
      hotelOptions: hotelOptions,
      initialHotelIndex: _resolveInitialHotelIndex(
        rawPlan,
        hotelOptions.length,
      ),
    );
  }

  static int _resolveInitialHotelIndex(JsonMap rawPlan, int length) {
    final rawIndex = rawPlan['selectedHotelIndex'];
    if (rawIndex is num && rawIndex >= 0 && rawIndex < length) {
      return rawIndex.toInt();
    }
    return 0;
  }

  static List<HotelPlanOption> _buildHotelOptions(
    dynamic l10n,
    TripPlan trip,
    JsonMap rawPlan,
  ) {
    final options = asMapList(rawPlan['hotelOptions']);
    if (options.isNotEmpty) {
      return options.map((option) {
        final hotelMap =
            asMap(option['accommodation']) ??
            asMap(option['hotel']) ??
            const {};
        final days = _buildDays(option);
        final accommodation = _buildAccommodationInfo(
          l10n,
          hotelMap,
          option['totalCost'] ?? rawPlan['totalCost'],
          trip.days,
        );
        return HotelPlanOption(
          accommodation: accommodation,
          days: days,
          nearby: asMapList(option['nearby']).map(_toActivityItem).toList(),
          distant: asMapList(option['distant']).map(_toActivityItem).toList(),
          hotelReasons: _parseStringList(
            option['hotelReasons'] ??
                option['recommendationReasons'] ??
                option['reasons'],
          ),
          dayRoutes: _buildDayRoutes(accommodation, days),
          totalCost: asDouble(option['totalCost']),
        );
      }).toList();
    }

    final hotelMap =
        asMap(rawPlan['accommodation']) ?? asMap(rawPlan['hotel']) ?? const {};
    final days = _buildDays(rawPlan);
    final accommodation = _buildAccommodationInfo(
      l10n,
      hotelMap,
      rawPlan['totalCost'],
      trip.days,
    );
    return <HotelPlanOption>[
      HotelPlanOption(
        accommodation: accommodation,
        days: days,
        nearby: asMapList(rawPlan['nearby']).map(_toActivityItem).toList(),
        distant: asMapList(rawPlan['distant']).map(_toActivityItem).toList(),
        hotelReasons: _parseStringList(
          rawPlan['hotelReasons'] ?? rawPlan['recommendationReasons'],
        ),
        dayRoutes: _buildDayRoutes(accommodation, days),
        totalCost: asDouble(rawPlan['totalCost']),
      ),
    ];
  }

  static AccommodationInfo _buildAccommodationInfo(
    dynamic l10n,
    JsonMap hotelMap,
    dynamic rawTotalCost,
    int tripDays,
  ) {
    final hotelPricePerNight = asDouble(hotelMap['pricePerNight']);
    final totalCost = asDouble(rawTotalCost);
    var hotelPrice = '';
    if (hotelPricePerNight != null && hotelPricePerNight > 0) {
      final safeTotal = (totalCost != null && totalCost > 0)
          ? totalCost
          : hotelPricePerNight * tripDays;
      hotelPrice = l10n.plansPricePerNight(
        hotelPricePerNight.toStringAsFixed(0),
      );
      hotelPrice += ' | ${l10n.plansTotalPrice(safeTotal.toStringAsFixed(0))}';
    }

    return AccommodationInfo(
      id: asText(hotelMap['hotelId'] ?? hotelMap['id'] ?? hotelMap['name']),
      name: asText(hotelMap['name']).isEmpty
          ? l10n.hotelNameUnknown
          : asText(hotelMap['name']),
      location: asText(hotelMap['location']),
      price: hotelPrice,
      rating: asText(hotelMap['rating']),
      amenities: asText(hotelMap['amenities']),
      mapsNote: l10n.actionOpenInMaps,
      bookingUrl: hotelMap['bookingUrl']?.toString(),
      mapsUrl: hotelMap['mapsUrl']?.toString(),
      lat: asDouble(hotelMap['lat'] ?? hotelMap['latitude']),
      lng: asDouble(hotelMap['lng'] ?? hotelMap['longitude']),
    );
  }

  static List<DayDetail> _buildDays(JsonMap rawScope) {
    final rawDays = asMapList(rawScope['schedule'] ?? rawScope['itinerary']);
    return <DayDetail>[
      for (int dayIndex = 0; dayIndex < rawDays.length; dayIndex++)
        DayDetail(
          label: asText(rawDays[dayIndex]['label']).isEmpty
              ? 'Day ${dayIndex + 1}:'
              : asText(rawDays[dayIndex]['label']),
          morning: asMapList(
            rawDays[dayIndex]['morning'],
          ).map(_toActivityItem).toList(),
          afternoon: asMapList(
            rawDays[dayIndex]['afternoon'],
          ).map(_toActivityItem).toList(),
          evening: asMapList(
            rawDays[dayIndex]['evening'],
          ).map(_toActivityItem).toList(),
        ),
    ];
  }

  static ActivityItem _toActivityItem(JsonMap rawActivity) {
    return ActivityItem(
      id: asText(
        rawActivity['activityId'] ?? rawActivity['id'] ?? rawActivity['name'],
      ),
      title: asText(rawActivity['name'] ?? rawActivity['title']),
      location: asText(rawActivity['location']),
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
      lat: asDouble(rawActivity['lat'] ?? rawActivity['latitude']),
      lng: asDouble(rawActivity['lng'] ?? rawActivity['longitude']),
    );
  }

  static List<String> _buildEventLines(dynamic l10n, List<JsonMap> events) {
    final eventLines = <String>[];
    for (final event in events) {
      final title = asText(event['title'] ?? event['name']);
      final date = asText(event['date']);
      final time = asText(event['time']);
      final location = asText(event['location']);
      final description = asText(event['description']);
      if (title.isNotEmpty) eventLines.add(title);
      if (date.isNotEmpty) eventLines.add('${l10n.bookingsReceiptDate}: $date');
      if (time.isNotEmpty) eventLines.add('${l10n.plansTimeLabel}: $time');
      if (location.isNotEmpty) {
        eventLines.add('${l10n.adminLabelLocation}: $location');
      }
      if (description.isNotEmpty) {
        eventLines.add('${l10n.plansDescriptionLabel}: $description');
      }
    }
    return eventLines;
  }

  static TourGuideInfo? _resolveTourGuide(
    JsonMap rawPlan, {
    required String city,
    required String kind,
  }) {
    if (kind != 'cultural') {
      return null;
    }

    final rawGuide =
        asMap(rawPlan['tourGuide']) ??
        asMap(rawPlan['tour_guide']) ??
        asMap(rawPlan['guide']) ??
        const <String, dynamic>{};
    final fallback =
        _cityGuideFallbacks[city.trim()] ?? _cityGuideFallbacks['Riyadh']!;

    final name = asText(
      rawGuide['name'] ?? rawGuide['fullName'] ?? rawGuide['guideName'],
    );
    final experienceYears = asText(
      rawGuide['experienceYears'] ??
          rawGuide['experience'] ??
          rawGuide['years'],
    );
    final languages = asText(
      rawGuide['languages'] ??
          rawGuide['language'] ??
          rawGuide['spokenLanguages'],
    );
    final phone = asText(
      rawGuide['phone'] ?? rawGuide['phoneNumber'] ?? rawGuide['mobile'],
    );
    final rating = asText(rawGuide['rating']);
    final description = asText(
      rawGuide['description'] ?? rawGuide['bio'] ?? rawGuide['about'],
    );

    return TourGuideInfo(
      name: name.isEmpty ? fallback.name : name,
      experienceYears: experienceYears.isEmpty
          ? fallback.experienceYears
          : experienceYears,
      languages: languages.isEmpty ? fallback.languages : languages,
      phone: phone.isEmpty ? fallback.phone : phone,
      rating: rating.isEmpty ? fallback.rating : rating,
      description: description.isEmpty ? fallback.description : description,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return <String>[value.trim()];
    }
    return const <String>[];
  }

  static List<DayRouteInfo> _buildDayRoutes(
    AccommodationInfo hotel,
    List<DayDetail> days,
  ) {
    if (hotel.lat == null || hotel.lng == null) {
      return const <DayRouteInfo>[];
    }

    final routes = <DayRouteInfo>[];
    for (final day in days) {
      final stops = <RouteStopInfo>[
        RouteStopInfo(
          title: hotel.name,
          lat: hotel.lat!,
          lng: hotel.lng!,
          isHotel: true,
        ),
      ];

      for (final item in <ActivityItem>[
        ...day.morning,
        ...day.afternoon,
        ...day.evening,
      ]) {
        if (item.lat == null || item.lng == null) {
          continue;
        }
        stops.add(
          RouteStopInfo(title: item.title, lat: item.lat!, lng: item.lng!),
        );
      }

      if (stops.length < 2) {
        continue;
      }

      final avgLat =
          stops.map((stop) => stop.lat).reduce((a, b) => a + b) / stops.length;
      final avgLng =
          stops.map((stop) => stop.lng).reduce((a, b) => a + b) / stops.length;

      routes.add(
        DayRouteInfo(
          dayLabel: day.label,
          centerLat: avgLat,
          centerLng: avgLng,
          stops: stops,
        ),
      );
    }
    return routes;
  }
}
