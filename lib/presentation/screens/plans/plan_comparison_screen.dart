import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/trip_repository.dart';
import '../../../domain/entities/trip_plan.dart';
import '../../localization/app_localizations_ext.dart';
import 'plan_detail_screen.dart';

class PlanComparisonPayload {
  final TripPlan trip;
  final List<Map<String, dynamic>> generatedPlans;

  const PlanComparisonPayload({
    required this.trip,
    required this.generatedPlans,
  });
}

class PlanComparisonScreen extends StatefulWidget {
  final PlanComparisonPayload? payload;

  const PlanComparisonScreen({super.key, this.payload});

  @override
  State<PlanComparisonScreen> createState() => _PlanComparisonScreenState();
}

class _PlanComparisonScreenState extends State<PlanComparisonScreen> {
  final TripRepository _tripRepo = TripRepository();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  static const Color _cream = Color(0xFFFFF7E5);
  static const Color _pink = Color(0xFFE18299);
  static const Color _navy = Color(0xFF31487A);
  static const Color _yellow = Color(0xFFF6D792);

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

  Color _colorForKind(String kind) {
    switch (kind) {
      case 'adventure':
        return _navy;
      case 'family':
        return _pink;
      default:
        return _yellow;
    }
  }

  PlanDetailData _toDetailData(
    BuildContext context,
    TripPlan trip,
    Map<String, dynamic> rawPlan,
  ) {
    final l10n = context.l10n;
    final kind = '${rawPlan['kind'] ?? 'family'}'.toLowerCase().trim();
    final headerColor = kind == 'adventure'
        ? const Color(0xFFB7C8E6)
        : kind == 'family'
        ? const Color(0xFFF2C8D2)
        : const Color(0xFFF6E2B9);
    final borderColor = _colorForKind(kind);

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
          : hotelPricePerNight * trip.days;
      hotelPrice = l10n.plansPricePerNight(
        hotelPricePerNight.toStringAsFixed(0),
      );
      hotelPrice += ' | ${l10n.plansTotalPrice(safeTotal.toStringAsFixed(0))}';
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

    final schedule = _asMapList(rawPlan['schedule'] ?? rawPlan['itinerary']);
    final days = <DayDetail>[
      for (final day in schedule)
        DayDetail(
          label: '${day['label'] ?? ''}',
          morning: _asMapList(day['morning']).map(toActivityItem).toList(),
          afternoon: _asMapList(day['afternoon']).map(toActivityItem).toList(),
          evening: _asMapList(day['evening']).map(toActivityItem).toList(),
        ),
    ];

    final nearby = _asMapList(rawPlan['nearby']).map(toActivityItem).toList();
    final distant = _asMapList(rawPlan['distant']).map(toActivityItem).toList();

    final events = _asMapList(rawPlan['events']);
    final eventLines = <String>[];
    for (final event in events) {
      final title = '${event['title'] ?? ''}'.trim();
      final date = '${event['date'] ?? ''}'.trim();
      final time = '${event['time'] ?? ''}'.trim();
      final location = '${event['location'] ?? ''}'.trim();
      final description = '${event['description'] ?? ''}'.trim();
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

    return PlanDetailData(
      title: '${rawPlan['title'] ?? l10n.plansGeneratedPlanTitle}'
          .replaceAll('.', '')
          .trim(),
      sourceTripPlanId: trip.id,
      budgetStatus: budgetStatus,
      minimumRequired: minimumRequired,
      userBudget: trip.budget,
      headerColor: headerColor,
      borderColor: borderColor,
      accentColor: borderColor,
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

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.comparePlansTitle)),
        body: Center(child: Text(context.l10n.errorPleaseLogin)),
      );
    }

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(title: Text(context.l10n.comparePlansTitle)),
      body: FutureBuilder<List<TripPlan>>(
        future: _tripRepo.getAllPlans(uid),
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

          TripPlan? latestTrip;
          List<Map<String, dynamic>> generatedPlans = const [];
          if (widget.payload != null &&
              widget.payload!.generatedPlans.isNotEmpty) {
            latestTrip = widget.payload!.trip;
            generatedPlans = widget.payload!.generatedPlans;
          } else {
            final latest = _latestTripWithGeneratedPlans(
              snapshot.data ?? const <TripPlan>[],
            );
            if (latest != null) {
              latestTrip = latest;
              generatedPlans = (latest.generatedPlans ?? const <dynamic>[])
                  .map(_asMap)
                  .whereType<Map<String, dynamic>>()
                  .toList();
            }
          }

          if (latestTrip == null || generatedPlans.isEmpty) {
            return Center(child: Text(context.l10n.emptyPlans));
          }
          final trip = latestTrip;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: generatedPlans.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rawPlan = generatedPlans[index];
              final kind = '${rawPlan['kind'] ?? 'family'}';
              final title =
                  '${rawPlan['title'] ?? context.l10n.plansGeneratedPlanTitle}';
              final hotel =
                  _asMap(rawPlan['accommodation']) ??
                  _asMap(rawPlan['hotel']) ??
                  const <String, dynamic>{};
              final nearbyCount = _asMapList(rawPlan['nearby']).length;
              final distantCount = _asMapList(rawPlan['distant']).length;
              final eventCount = _asMapList(rawPlan['events']).length;
              final totalCost = _asDouble(rawPlan['totalCost']);
              final accent = _colorForKind(kind);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      _MetricRow(
                        label: context.l10n.compareKindLabel,
                        value: kind,
                      ),
                      _MetricRow(
                        label: context.l10n.compareHotelLabel,
                        value:
                            '${hotel['name'] ?? context.l10n.hotelNameUnknown}',
                      ),
                      _MetricRow(
                        label: context.l10n.compareTotalCostLabel,
                        value: totalCost == null
                            ? '-'
                            : '${totalCost.toStringAsFixed(0)} SAR',
                      ),
                      _MetricRow(
                        label: context.l10n.compareNearbyLabel,
                        value: '$nearbyCount',
                      ),
                      _MetricRow(
                        label: context.l10n.compareDistantLabel,
                        value: '$distantCount',
                      ),
                      _MetricRow(
                        label: context.l10n.compareEventsLabel,
                        value: '$eventCount',
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            try {
                              await _tripRepo.markPlanSelection(
                                tripPlanId: trip.id,
                                selectedPlanIndex: index,
                                selectedPlanTitle: title,
                              );
                              if (!context.mounted) return;
                              final detailData = _toDetailData(
                                context,
                                trip,
                                rawPlan,
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PlanDetailScreen(data: detailData),
                                ),
                              );
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
                          child: Text(context.l10n.selectPlanCta),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
