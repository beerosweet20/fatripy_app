import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/trip_repository.dart';
import '../../../domain/entities/trip_plan.dart';
import '../../localization/app_localizations_ext.dart';
import 'plan_detail_builder.dart';
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

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  String _kindLabel(BuildContext context, String kind) {
    switch (kind.toLowerCase().trim()) {
      case 'adventure':
        return context.l10n.plansAdventureTitle;
      case 'cultural':
        return context.l10n.plansCulturalTitle;
      default:
        return context.l10n.plansFamilyTitle;
    }
  }

  List<String> _planHighlightsFor(
    BuildContext context,
    PlanDetailData data,
    String kind,
  ) {
    final highlights = data.planReasons
        .map((reason) => reason.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((reason) => reason.isNotEmpty)
        .take(2)
        .toList();
    if (highlights.isNotEmpty) {
      return highlights;
    }

    switch (kind.toLowerCase().trim()) {
      case 'adventure':
        return <String>[context.l10n.compareAdventureHighlight];
      case 'cultural':
        return <String>[context.l10n.compareCulturalHighlight];
      default:
        return <String>[context.l10n.compareFamilyHighlight];
    }
  }

  List<String> _hotelNamesFor(PlanDetailData data) {
    final names = <String>[];
    final seen = <String>{};
    for (final option in data.resolvedHotelOptions) {
      final name = option.accommodation.name.trim();
      if (name.isEmpty) continue;
      final key = name.toLowerCase();
      if (seen.add(key)) {
        names.add(name);
      }
    }
    return names;
  }

  List<String> _placesToVisitFor(PlanDetailData data) {
    final places = <String>[];
    final seen = <String>{};

    void addPlace(String value) {
      final cleaned = value.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (cleaned.isEmpty) return;
      final key = cleaned.toLowerCase();
      if (seen.add(key)) {
        places.add(cleaned);
      }
    }

    for (final option in data.resolvedHotelOptions) {
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
      for (final option in data.resolvedHotelOptions) {
        for (final item in option.nearby) {
          addPlace(item.title);
        }
        for (final item in option.distant) {
          addPlace(item.title);
        }
      }
    }

    return places.take(4).toList();
  }

  bool _hasNearbyOptions(PlanDetailData data) {
    return data.resolvedHotelOptions.any((option) => option.nearby.isNotEmpty);
  }

  bool _hasDistantOptions(PlanDetailData data) {
    return data.resolvedHotelOptions.any((option) => option.distant.isNotEmpty);
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
    return PlanDetailBuilder.buildDetailData(
      context,
      trip: trip,
      rawPlan: rawPlan,
      resolvedTitle:
          '${rawPlan['title'] ?? context.l10n.plansGeneratedPlanTitle}'
              .replaceAll('.', '')
              .trim(),
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
              final totalCost = _asDouble(rawPlan['totalCost']);
              final accent = _colorForKind(kind);
              final detailData = _toDetailData(context, trip, rawPlan);
              final planHighlights = _planHighlightsFor(
                context,
                detailData,
                kind,
              );
              final hotelNames = _hotelNamesFor(detailData);
              final placeNames = _placesToVisitFor(detailData);
              final hasNearby = _hasNearbyOptions(detailData);
              final hasDistant = _hasDistantOptions(detailData);

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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            text: _kindLabel(context, kind),
                            color: accent,
                          ),
                          if (totalCost != null)
                            _InfoChip(
                              text:
                                  '${context.l10n.compareTotalCostLabel}: ${totalCost.toStringAsFixed(0)} SAR',
                              color: accent,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _HighlightCard(
                        accent: accent,
                        title: context.l10n.comparePlanHighlightTitle,
                        items: planHighlights,
                      ),
                      const SizedBox(height: 12),
                      _PlanSectionTitle(
                        title: context.l10n.compareHotelsSectionTitle,
                        accent: accent,
                      ),
                      const SizedBox(height: 6),
                      _BulletList(
                        items: hotelNames.isEmpty
                            ? <String>[context.l10n.hotelNameUnknown]
                            : hotelNames,
                      ),
                      const SizedBox(height: 12),
                      _PlanSectionTitle(
                        title: context.l10n.comparePlacesSectionTitle,
                        accent: accent,
                      ),
                      const SizedBox(height: 6),
                      if (placeNames.isEmpty)
                        _SummaryNote(text: context.l10n.comparePlacesFallback)
                      else
                        _BulletList(items: placeNames),
                      const SizedBox(height: 12),
                      _PlanSectionTitle(
                        title: context.l10n.plansLabelNearbyAttractions,
                        accent: accent,
                      ),
                      const SizedBox(height: 6),
                      _SummaryNote(
                        text: hasNearby
                            ? context.l10n.compareNearbySummary
                            : context.l10n.planDetailNoActivities,
                      ),
                      const SizedBox(height: 12),
                      _PlanSectionTitle(
                        title: context.l10n.plansLabelDistantAttractions,
                        accent: accent,
                      ),
                      const SizedBox(height: 6),
                      _SummaryNote(
                        text: hasDistant
                            ? context.l10n.compareDistantSummary
                            : context.l10n.planDetailNoActivities,
                      ),
                      const SizedBox(height: 10),
                      _SummaryNote(
                        text: context.l10n.compareHotelActivitiesNote,
                        emphasize: true,
                      ),
                      const SizedBox(height: 8),
                      _SummaryNote(
                        text: context.l10n.compareEventsDeferredNote,
                        emphasize: true,
                      ),
                      const SizedBox(height: 12),
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
                              context.push('/plans/detail', extra: detailData);
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

class _HighlightCard extends StatelessWidget {
  final Color accent;
  final String title;
  final List<String> items;

  const _HighlightCard({
    required this.accent,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: accent, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _BulletList(items: items),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final Color color;

  const _InfoChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PlanSectionTitle extends StatelessWidget {
  final String title;
  final Color accent;

  const _PlanSectionTitle({required this.title, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: accent,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;

  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SummaryNote extends StatelessWidget {
  final String text;
  final bool emphasize;

  const _SummaryNote({required this.text, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      height: 1.45,
      color: emphasize ? null : Colors.black87,
      fontWeight: emphasize ? FontWeight.w600 : FontWeight.w400,
    );

    return Text(text, style: style);
  }
}
