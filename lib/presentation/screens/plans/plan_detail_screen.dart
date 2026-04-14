import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../domain/entities/booking.dart';
import '../../localization/app_localizations_ext.dart';
import 'plan_share_preview_screen.dart';

final MemoryImage _transparentTileImage = MemoryImage(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+n6u8AAAAASUVORK5CYII=',
  ),
);

class PlanDetailData {
  final String title;
  final String sourceTripPlanId;
  final String? budgetStatus;
  final double? minimumRequired;
  final double? userBudget;
  final Color headerColor;
  final Color borderColor;
  final Color accentColor;
  final Color backgroundColor;
  final AccommodationInfo accommodation;
  final TourGuideInfo? tourGuide;
  final List<DayDetail> days;
  final List<ActivityItem> nearby;
  final List<ActivityItem> distant;
  final List<String> eventLines;
  final List<String> planReasons;
  final List<HotelPlanOption> hotelOptions;
  final int initialHotelIndex;

  const PlanDetailData({
    required this.title,
    required this.sourceTripPlanId,
    this.budgetStatus,
    this.minimumRequired,
    this.userBudget,
    required this.headerColor,
    required this.borderColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.accommodation,
    this.tourGuide,
    required this.days,
    required this.nearby,
    required this.distant,
    required this.eventLines,
    this.planReasons = const <String>[],
    this.hotelOptions = const <HotelPlanOption>[],
    this.initialHotelIndex = 0,
  });

  List<HotelPlanOption> get resolvedHotelOptions {
    if (hotelOptions.isNotEmpty) {
      return hotelOptions;
    }
    return <HotelPlanOption>[
      HotelPlanOption(
        accommodation: accommodation,
        days: days,
        nearby: nearby,
        distant: distant,
      ),
    ];
  }
}

class AccommodationInfo {
  final String id;
  final String name;
  final String location;
  final String price;
  final String rating;
  final String amenities;
  final String mapsNote;
  final String? bookingUrl;
  final String? mapsUrl;
  final double? lat;
  final double? lng;

  const AccommodationInfo({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.amenities,
    required this.mapsNote,
    this.bookingUrl,
    this.mapsUrl,
    this.lat,
    this.lng,
  });
}

class TourGuideInfo {
  final String name;
  final String experienceYears;
  final String languages;
  final String phone;
  final String rating;
  final String description;

  const TourGuideInfo({
    required this.name,
    required this.experienceYears,
    required this.languages,
    required this.phone,
    required this.rating,
    required this.description,
  });
}

class DayDetail {
  final String label; // "Day 1:"
  final List<ActivityItem> morning;
  final List<ActivityItem> afternoon;
  final List<ActivityItem> evening;

  const DayDetail({
    required this.label,
    required this.morning,
    required this.afternoon,
    required this.evening,
  });
}

class ActivityItem {
  final String id;
  final String title;
  final String location;
  final String? open;
  final String? close;
  final String? price;
  final String? rating;
  final String? time;
  final String? distance;
  final String? bookingUrl;
  final String? mapsUrl;
  final double? lat;
  final double? lng;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.location,
    this.open,
    this.close,
    this.price,
    this.rating,
    this.time,
    this.distance,
    this.bookingUrl,
    this.mapsUrl,
    this.lat,
    this.lng,
  });
}

class HotelPlanOption {
  final AccommodationInfo accommodation;
  final List<DayDetail> days;
  final List<ActivityItem> nearby;
  final List<ActivityItem> distant;
  final List<String> hotelReasons;
  final List<DayRouteInfo> dayRoutes;
  final double? totalCost;

  const HotelPlanOption({
    required this.accommodation,
    required this.days,
    required this.nearby,
    required this.distant,
    this.hotelReasons = const <String>[],
    this.dayRoutes = const <DayRouteInfo>[],
    this.totalCost,
  });
}

class DayRouteInfo {
  final String dayLabel;
  final double centerLat;
  final double centerLng;
  final List<RouteStopInfo> stops;

  const DayRouteInfo({
    required this.dayLabel,
    required this.centerLat,
    required this.centerLng,
    required this.stops,
  });
}

class RouteStopInfo {
  final String title;
  final double lat;
  final double lng;
  final bool isHotel;

  const RouteStopInfo({
    required this.title,
    required this.lat,
    required this.lng,
    this.isHotel = false,
  });
}

Uri _mapsSearchUri(String title) {
  final query = Uri.encodeComponent(title);
  return Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
}

Uri? _normalizeUrl(String? url) {
  if (url == null) return null;
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  final parsed = Uri.parse(trimmed);
  if (parsed.scheme.isNotEmpty) return parsed;
  return Uri.parse('https://$trimmed');
}

Future<void> _openExternalUrl(Uri url) async {
  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('Could not launch url: $e');
  }
}

Future<void> _openMaps(String? mapsUrl, String title) async {
  final uri = _normalizeUrl(mapsUrl) ?? _mapsSearchUri(title);
  await _openExternalUrl(uri);
}

Future<void> _saveBooking(
  BuildContext context,
  String planId,
  String itemId,
  String title,
  String type,
) async {
  final normalizedPlanId = planId.trim();
  if (normalizedPlanId.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.bookingPlanUnavailable)),
      );
    }
    return;
  }

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.bookingLoginRequiredSaveFailed)),
      );
    }
    return;
  }

  final normalizedItemId = itemId.trim().isEmpty ? title.trim() : itemId.trim();
  final normalizedTitle = title.trim().isEmpty
      ? normalizedItemId
      : title.trim();
  final bookingReference =
      '${type.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

  final repo = BookingRepository();
  final booking = Booking(
    id: '',
    uid: uid,
    planId: normalizedPlanId,
    itemType: type,
    itemId: normalizedItemId,
    itemTitle: normalizedTitle,
    bookingReference: bookingReference,
    status: 'Booked',
    createdAt: DateTime.now(),
  );
  await repo.addBooking(booking);

  if (context.mounted) {
    context.push('/plans/booking-success?type=$type');
  }
}

Future<void> _bookAndSave(
  BuildContext context,
  String planId,
  String itemId,
  String title,
  String type, {
  String? bookingUrl,
  String? mapsUrl,
}) async {
  try {
    final uri = _normalizeUrl(bookingUrl) ?? _normalizeUrl(mapsUrl);
    if (uri != null) {
      await _openExternalUrl(uri);
    } else {
      await _openMaps(mapsUrl, title);
    }
    if (!context.mounted) return;
    await _saveBooking(context, planId, itemId, title, type);
  } catch (e) {
    debugPrint('Error booking: $e');
  }
}

Uri? _routeDirectionsUri(List<RouteStopInfo> stops) {
  if (stops.length < 2) return null;

  String point(RouteStopInfo stop) => '${stop.lat},${stop.lng}';

  final origin = point(stops.first);
  final destination = point(stops.last);
  final waypoints = stops.length > 2
      ? stops.sublist(1, stops.length - 1).map(point).join('|')
      : '';

  final params = <String, String>{
    'api': '1',
    'origin': origin,
    'destination': destination,
    'travelmode': 'driving',
  };
  if (waypoints.isNotEmpty) {
    params['waypoints'] = waypoints;
  }
  return Uri.https('www.google.com', '/maps/dir/', params);
}

DayRouteInfo? _routeForDay(HotelPlanOption option, DayDetail day) {
  for (final route in option.dayRoutes) {
    if (route.dayLabel.trim() == day.label.trim()) {
      return route;
    }
  }
  if (option.dayRoutes.length == option.days.length) {
    final index = option.days.indexOf(day);
    if (index >= 0 && index < option.dayRoutes.length) {
      return option.dayRoutes[index];
    }
  }
  return null;
}

class _PlanEventEntry {
  final String title;
  final List<String> details;

  const _PlanEventEntry({required this.title, required this.details});
}

bool _isEventDetailLine(BuildContext context, String line) {
  final l10n = context.l10n;
  final prefixes = <String>[
    '${l10n.bookingsReceiptDate}:',
    '${l10n.plansTimeLabel}:',
    '${l10n.adminLabelLocation}:',
    '${l10n.plansDescriptionLabel}:',
  ];
  return prefixes.any((prefix) => line.startsWith(prefix));
}

List<_PlanEventEntry> _groupEventLines(
  BuildContext context,
  List<String> lines,
) {
  final entries = <_PlanEventEntry>[];
  String? currentTitle;
  final currentDetails = <String>[];

  void flush() {
    if ((currentTitle ?? '').trim().isEmpty) return;
    entries.add(
      _PlanEventEntry(
        title: currentTitle!.trim(),
        details: List<String>.from(currentDetails),
      ),
    );
    currentTitle = null;
    currentDetails.clear();
  }

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    if (_isEventDetailLine(context, line)) {
      if (currentTitle == null) {
        currentTitle = line;
      } else {
        currentDetails.add(line);
      }
      continue;
    }
    flush();
    currentTitle = line;
  }
  flush();
  return entries;
}

class PlanDetailScreen extends StatelessWidget {
  final PlanDetailData data;

  const PlanDetailScreen({super.key, required this.data});

  String _formatSarNumber(double? value) {
    if (value == null) return '-';
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.01) {
      return rounded.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  ({Color background, Color border, Color text, Color icon})
  _budgetBannerPalette(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final background = hsl
        .withLightness((hsl.lightness + 0.35).clamp(0.88, 0.95))
        .withSaturation((hsl.saturation * 0.35).clamp(0.22, 0.60))
        .toColor();
    final border = hsl
        .withLightness((hsl.lightness + 0.08).clamp(0.42, 0.68))
        .withSaturation((hsl.saturation * 0.78).clamp(0.35, 0.95))
        .toColor();
    final text = hsl
        .withLightness((hsl.lightness * 0.32).clamp(0.18, 0.33))
        .withSaturation((hsl.saturation * 0.95).clamp(0.35, 1.0))
        .toColor();
    return (background: background, border: border, text: text, icon: border);
  }

  Color _mix(Color a, Color b, double t) {
    return Color.lerp(a, b, t.clamp(0.0, 1.0)) ?? a;
  }

  Color _onColor(Color color) {
    return color.computeLuminance() < 0.46
        ? Colors.white
        : const Color(0xFF111111);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final scale = (w / 390.0).clamp(0.85, 1.10);
    double s(double v) => v * scale;

    final ink = const Color(0xFF111111);
    final paper = _mix(const Color(0xFFFFFBF3), data.backgroundColor, 0.78);
    final stroke = data.borderColor;
    final sectionPill = data.accentColor;
    final sectionPillText = _onColor(sectionPill);
    final titleBand = data.headerColor;
    final titleText = _onColor(titleBand);
    final panelFill = _mix(paper, data.headerColor, 0.32);
    final lightCell = _mix(paper, data.headerColor, 0.46);
    final dayCell = data.accentColor;
    final dayCellText = _onColor(dayCell);
    final budgetStatus = (data.budgetStatus ?? '').toLowerCase().trim();
    final isLowBudget =
        budgetStatus == 'low' ||
        (data.userBudget != null &&
            data.minimumRequired != null &&
            data.userBudget! < data.minimumRequired!);
    final userBudgetLabel = _formatSarNumber(data.userBudget);
    final minimumRequiredLabel = _formatSarNumber(data.minimumRequired);
    final bannerColors = _budgetBannerPalette(data.accentColor);
    final showBack = Navigator.of(context).canPop();
    final hotelOptions = data.resolvedHotelOptions;
    final eventEntries = _groupEventLines(context, data.eventLines);
    var selectedHotelIndex = hotelOptions.isEmpty
        ? 0
        : data.initialHotelIndex.clamp(0, hotelOptions.length - 1);

    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: StatefulBuilder(
          builder: (context, setPlanState) {
            final activeOption = hotelOptions[selectedHotelIndex];
            return Column(
              children: [
                // ─── Header ───────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(s(18), s(10), s(18), s(12)),
                  child: Container(
                    width: double.infinity,
                    color: titleBand,
                    padding: EdgeInsets.symmetric(
                      horizontal: s(8),
                      vertical: s(12),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (showBack)
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                size: s(18),
                                color: titleText,
                              ),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: IconButton(
                            tooltip: context.l10n.planDetailShareSummary,
                            icon: Icon(
                              Icons.ios_share_outlined,
                              size: s(20),
                              color: titleText,
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PlanSharePreviewScreen(
                                  data: data,
                                  hotelOption: activeOption,
                                  hotelIndex: selectedHotelIndex,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: s(42)),
                          child: Text(
                            context.l10n.planDetailTitle(data.title),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: s(18),
                              color: titleText,
                              fontWeight: FontWeight.w500,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(s(18), s(8), s(18), s(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isLowBudget) ...[
                          Container(
                            padding: EdgeInsets.all(s(12)),
                            decoration: BoxDecoration(
                              color: bannerColors.background,
                              border: Border.all(color: bannerColors.border),
                              borderRadius: BorderRadius.circular(s(12)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: bannerColors.icon,
                                  size: s(22),
                                ),
                                SizedBox(width: s(10)),
                                Expanded(
                                  child: Text(
                                    context.l10n.plansBudgetLowBannerMessage(
                                      userBudgetLabel,
                                      minimumRequiredLabel,
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: s(13.5),
                                      color: bannerColors.text,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: s(16)),
                        ],
                        // ─── Hotel Information ─────────────────────────────
                        Column(
                          children: [
                            _PillOverlayBox(
                              scale: scale,
                              borderColor: stroke,
                              pillColor: sectionPill,
                              panelColor: panelFill,
                              pillTextColor: sectionPillText,
                              pillAlignment: AlignmentDirectional.centerStart,
                              pillText:
                                  '${context.l10n.planDetailHotelSection}:',
                              child: _HotelInfoContent(
                                scale: scale,
                                hotel: activeOption.accommodation,
                                planId: data.sourceTripPlanId,
                                planReasons: data.planReasons,
                                hotelReasons: activeOption.hotelReasons,
                                hotelCount: hotelOptions.length,
                                onPreviousHotel: () => setPlanState(() {
                                  selectedHotelIndex =
                                      (selectedHotelIndex -
                                          1 +
                                          hotelOptions.length) %
                                      hotelOptions.length;
                                }),
                                onNextHotel: () => setPlanState(() {
                                  selectedHotelIndex =
                                      (selectedHotelIndex + 1) %
                                      hotelOptions.length;
                                }),
                              ),
                            ),
                            if (hotelOptions.length > 1) ...[
                              SizedBox(height: s(8)),
                              _HotelSelectorControls(
                                scale: scale,
                                color: sectionPill,
                                hotelCount: hotelOptions.length,
                                hotelIndex: selectedHotelIndex,
                                hintText:
                                    context.l10n.planDetailSelectHotelHint,
                                onSelectHotel: (index) => setPlanState(() {
                                  selectedHotelIndex = index;
                                }),
                              ),
                            ],
                          ],
                        ),

                        if (data.tourGuide != null) ...[
                          SizedBox(height: s(24)),
                          _PillOverlayBox(
                            scale: scale,
                            borderColor: stroke,
                            pillColor: sectionPill,
                            panelColor: panelFill,
                            pillTextColor: sectionPillText,
                            pillAlignment: AlignmentDirectional.centerEnd,
                            pillText:
                                '${context.l10n.planDetailTourGuideSection}:',
                            child: _TourGuideContent(
                              scale: scale,
                              guide: data.tourGuide!,
                            ),
                          ),
                        ],

                        SizedBox(height: s(24)),

                        // ─── Days ──────────────────────────────────────────
                        for (
                          int di = 0;
                          di < activeOption.days.length;
                          di++
                        ) ...[
                          Builder(
                            builder: (context) {
                              final day = activeOption.days[di];
                              final dayRoute = _routeForDay(activeOption, day);
                              return Column(
                                children: [
                                  _DayBlock(
                                    scale: scale,
                                    borderColor: stroke,
                                    paper: paper,
                                    lightCell: lightCell,
                                    dayCell: dayCell,
                                    ink: ink,
                                    dayHeaderTextColor: dayCellText,
                                    dayLabelOnRight: di.isOdd,
                                    day: day,
                                    planId: data.sourceTripPlanId,
                                    accentColor: sectionPill,
                                  ),
                                  if (dayRoute != null) ...[
                                    SizedBox(height: s(14)),
                                    _PillOverlayBox(
                                      scale: scale,
                                      borderColor: stroke,
                                      pillColor: sectionPill,
                                      panelColor: panelFill,
                                      pillTextColor: sectionPillText,
                                      pillAlignment: di.isOdd
                                          ? AlignmentDirectional.centerStart
                                          : AlignmentDirectional.centerEnd,
                                      pillText:
                                          '${context.l10n.planDetailDayRouteTitle(day.label.replaceAll(':', ''))}:',
                                      child: _DayRouteMapContent(
                                        scale: scale,
                                        borderColor: stroke,
                                        paper: paper,
                                        lightCell: lightCell,
                                        accentColor: sectionPill,
                                        ink: ink,
                                        route: dayRoute,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: s(22)),
                                ],
                              );
                            },
                          ),
                        ],

                        // ─── Nearby Attraction ─────────────────────────────
                        _PillOverlayBox(
                          scale: scale,
                          borderColor: stroke,
                          pillColor: sectionPill,
                          panelColor: panelFill,
                          pillTextColor: sectionPillText,
                          pillAlignment: AlignmentDirectional.centerEnd,
                          pillText:
                              '${context.l10n.plansLabelNearbyAttractions}:',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (activeOption.nearby.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(bottom: s(4)),
                                  child: Text(
                                    context.l10n.planDetailNoActivities,
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: s(13.5),
                                      color: ink,
                                      height: 1.4,
                                    ),
                                  ),
                                )
                              else
                                for (
                                  int i = 0;
                                  i < activeOption.nearby.length;
                                  i++
                                ) ...[
                                  _AttractionCard(
                                    scale: scale,
                                    borderColor: stroke,
                                    lightCell: lightCell,
                                    ink: ink,
                                    buttonColor: sectionPill,
                                    item: activeOption.nearby[i],
                                    planId: data.sourceTripPlanId,
                                  ),
                                  if (i < activeOption.nearby.length - 1)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: s(8),
                                      ),
                                      child: Container(
                                        height: s(1.5),
                                        color: stroke.withValues(alpha: 0.55),
                                      ),
                                    ),
                                ],
                            ],
                          ),
                        ),
                        SizedBox(height: s(24)),

                        // ─── Distant Attraction ────────────────────────────
                        _PillOverlayBox(
                          scale: scale,
                          borderColor: stroke,
                          pillColor: sectionPill,
                          panelColor: panelFill,
                          pillTextColor: sectionPillText,
                          pillAlignment: AlignmentDirectional.centerStart,
                          pillText:
                              '${context.l10n.plansLabelDistantAttractions}:',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (activeOption.distant.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(bottom: s(4)),
                                  child: Text(
                                    context.l10n.planDetailNoActivities,
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: s(13.5),
                                      color: ink,
                                      height: 1.4,
                                    ),
                                  ),
                                )
                              else
                                for (
                                  int i = 0;
                                  i < activeOption.distant.length;
                                  i++
                                ) ...[
                                  _AttractionCard(
                                    scale: scale,
                                    borderColor: stroke,
                                    lightCell: lightCell,
                                    ink: ink,
                                    buttonColor: sectionPill,
                                    item: activeOption.distant[i],
                                    planId: data.sourceTripPlanId,
                                  ),
                                  if (i < activeOption.distant.length - 1)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: s(8),
                                      ),
                                      child: Container(
                                        height: s(1.5),
                                        color: stroke.withValues(alpha: 0.55),
                                      ),
                                    ),
                                ],
                            ],
                          ),
                        ),
                        SizedBox(height: s(24)),

                        // ─── Event ─────────────────────────────────────────
                        _PillOverlayBox(
                          scale: scale,
                          borderColor: stroke,
                          pillColor: sectionPill,
                          panelColor: panelFill,
                          pillTextColor: sectionPillText,
                          pillAlignment: AlignmentDirectional.centerEnd,
                          pillText: '${context.l10n.plansLabelEvents}:',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (eventEntries.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(bottom: s(4)),
                                  child: Text(
                                    context.l10n.planDetailNoEvents,
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: s(13.5),
                                      color: ink,
                                      height: 1.4,
                                    ),
                                  ),
                                )
                              else
                                for (
                                  int i = 0;
                                  i < eventEntries.length;
                                  i++
                                ) ...[
                                  _EventEntryCard(
                                    scale: scale,
                                    ink: ink,
                                    lightCell: lightCell,
                                    borderColor: stroke,
                                    entry: eventEntries[i],
                                  ),
                                  if (i < eventEntries.length - 1)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: s(8),
                                      ),
                                      child: Container(
                                        height: s(1.5),
                                        color: stroke.withValues(alpha: 0.55),
                                      ),
                                    ),
                                ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Pill Overlay Box  (used for Hotel & Tour Guide sections)
// ═══════════════════════════════════════════════════════════════════════════
class _PillOverlayBox extends StatelessWidget {
  final double scale;
  final Color borderColor;
  final Color pillColor;
  final Color panelColor;
  final Color pillTextColor;
  final AlignmentGeometry pillAlignment;
  final String pillText;
  final Widget child;

  const _PillOverlayBox({
    required this.scale,
    required this.borderColor,
    required this.pillColor,
    required this.panelColor,
    required this.pillTextColor,
    required this.pillAlignment,
    required this.pillText,
    required this.child,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final alignEnd = pillAlignment == AlignmentDirectional.centerEnd;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: s(18)),
          padding: EdgeInsets.fromLTRB(s(10), s(24), s(10), s(12)),
          decoration: BoxDecoration(
            color: panelColor,
            border: Border.all(color: borderColor, width: s(2)),
          ),
          child: child,
        ),
        Positioned(
          top: 0,
          left: alignEnd ? null : 0,
          right: alignEnd ? 0 : null,
          child: Container(
            padding: EdgeInsets.fromLTRB(s(14), s(7), s(14), s(9)),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: alignEnd
                  ? BorderRadius.only(
                      topLeft: Radius.circular(s(24)),
                      bottomLeft: Radius.circular(s(24)),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(s(24)),
                      bottomRight: Radius.circular(s(24)),
                    ),
            ),
            child: Text(
              pillText,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: s(16.5),
                color: pillTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Hotel Info Content
// ═══════════════════════════════════════════════════════════════════════════
class _HotelInfoContent extends StatelessWidget {
  final double scale;
  final AccommodationInfo hotel;
  final String planId;
  final List<String> planReasons;
  final List<String> hotelReasons;
  final int hotelCount;
  final VoidCallback onPreviousHotel;
  final VoidCallback onNextHotel;

  const _HotelInfoContent({
    required this.scale,
    required this.hotel,
    required this.planId,
    this.planReasons = const <String>[],
    this.hotelReasons = const <String>[],
    this.hotelCount = 1,
    required this.onPreviousHotel,
    required this.onNextHotel,
  });
  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ink = const Color(0xFF111111);
    final lines = <String>[
      '${l10n.plansLabelHotel} : ${hotel.name}.',
      if (hotel.location.isNotEmpty)
        '${l10n.planDetailLocationLabel}: ${hotel.location}.',
      if (hotel.price.isNotEmpty)
        '${l10n.planDetailPriceLabel}: ${hotel.price}.',
      if (hotel.rating.isNotEmpty)
        '${l10n.planDetailRatingLabel}: ${hotel.rating}.',
      if (hotel.amenities.isNotEmpty)
        '${l10n.planDetailAmenities}: ${hotel.amenities}.',
      if (planReasons.isNotEmpty)
        '${l10n.planDetailWhyPlan}: ${planReasons.join(' | ')}.',
      if (hotelReasons.isNotEmpty)
        '${l10n.planDetailWhyHotel}: ${hotelReasons.join(' | ')}.',
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: hotelCount <= 1
          ? null
          : (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -120) {
                onNextHotel();
              } else if (velocity > 120) {
                onPreviousHotel();
              }
            },
      child: Padding(
        padding: EdgeInsets.fromLTRB(s(4), s(6), s(4), s(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final line in lines)
              Padding(
                padding: EdgeInsets.only(bottom: s(2)),
                child: Text(
                  line,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: s(13.8),
                    color: ink,
                    height: 1.28,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () => _bookAndSave(
                context,
                planId,
                hotel.id,
                hotel.name,
                l10n.planDetailHotelItemType,
                bookingUrl: hotel.bookingUrl,
                mapsUrl: hotel.mapsUrl,
              ),
              child: Text(
                '${l10n.actionOpenInMaps}.',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: s(13.8),
                  color: ink,
                  height: 1.28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventEntryCard extends StatelessWidget {
  final double scale;
  final Color ink;
  final Color lightCell;
  final Color borderColor;
  final _PlanEventEntry entry;

  const _EventEntryCard({
    required this.scale,
    required this.ink,
    required this.lightCell,
    required this.borderColor,
    required this.entry,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(s(10), s(10), s(10), s(10)),
      decoration: BoxDecoration(
        color: lightCell,
        border: Border.all(color: borderColor.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.title,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: s(14.4),
              color: ink,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          if (entry.details.isNotEmpty) SizedBox(height: s(6)),
          for (final detail in entry.details)
            Padding(
              padding: EdgeInsets.only(bottom: s(4)),
              child: Text(
                detail,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: s(13.2),
                  color: ink,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HotelSelectorControls extends StatelessWidget {
  final double scale;
  final Color color;
  final int hotelCount;
  final int hotelIndex;
  final String hintText;
  final ValueChanged<int> onSelectHotel;

  const _HotelSelectorControls({
    required this.scale,
    required this.color,
    required this.hotelCount,
    required this.hotelIndex,
    required this.hintText,
    required this.onSelectHotel,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final foreground = color.computeLuminance() < 0.46
        ? Colors.white
        : const Color(0xFF111111);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < hotelCount; i++) ...[
              GestureDetector(
                onTap: () => onSelectHotel(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: s(i == hotelIndex ? 8 : 6),
                  height: s(i == hotelIndex ? 8 : 6),
                  decoration: BoxDecoration(
                    color: i == hotelIndex
                        ? color.withValues(alpha: 0.82)
                        : color.withValues(alpha: 0.28),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              if (i < hotelCount - 1) SizedBox(width: s(8)),
            ],
          ],
        ),
        SizedBox(height: s(8)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: s(12), vertical: s(4)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(s(999)),
          ),
          child: Text(
            hintText,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: s(10.2),
              color: foreground,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _DayRouteMapContent extends StatelessWidget {
  final double scale;
  final Color borderColor;
  final Color paper;
  final Color lightCell;
  final Color accentColor;
  final Color ink;
  final DayRouteInfo route;

  const _DayRouteMapContent({
    required this.scale,
    required this.borderColor,
    required this.paper,
    required this.lightCell,
    required this.accentColor,
    required this.ink,
    required this.route,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final routeUri = _routeDirectionsUri(route.stops);
    final points = <latlng.LatLng>[
      for (final stop in route.stops) latlng.LatLng(stop.lat, stop.lng),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(s(4), s(6), s(4), s(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: s(170),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(s(18)),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: paper,
                  borderRadius: BorderRadius.circular(s(18)),
                  border: Border.all(color: borderColor, width: s(1.2)),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: latlng.LatLng(
                      route.centerLat,
                      route.centerLng,
                    ),
                    initialZoom: 12.3,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.fatripy.app',
                      tileProvider: NetworkTileProvider(
                        silenceExceptions: true,
                        attemptDecodeOfHttpErrorResponses: false,
                      ),
                      errorImage: _transparentTileImage,
                      errorTileCallback: (_, _, _) {},
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          color: accentColor,
                          strokeWidth: s(3),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        for (final stop in route.stops)
                          Marker(
                            point: latlng.LatLng(stop.lat, stop.lng),
                            width: s(28),
                            height: s(28),
                            child: Container(
                              decoration: BoxDecoration(
                                color: stop.isHotel ? accentColor : lightCell,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: borderColor,
                                  width: s(1.1),
                                ),
                              ),
                              child: Icon(
                                stop.isHotel
                                    ? Icons.hotel_rounded
                                    : Icons.location_on_rounded,
                                size: s(16),
                                color: stop.isHotel ? Colors.white : ink,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: s(10)),
          Text(
            '${context.l10n.planDetailRouteStops}: ${route.stops.map((stop) => stop.title).join('  •  ')}.',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: s(12.7),
              color: ink,
              height: 1.3,
            ),
          ),
          if (routeUri != null) ...[
            SizedBox(height: s(8)),
            Center(
              child: _PillBtn(
                scale: scale,
                color: accentColor,
                text: context.l10n.planDetailOpenRoute,
                onTap: () => _openExternalUrl(routeUri),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Day Block  — mimics the exact layout from the reference images
//  Day 1  : [Day label | left (gold)]  [Morning | right (light)]
//  Day 2  : [Morning  | left (light)]  [Day label | right (gold)]
// ═══════════════════════════════════════════════════════════════════════════
class _TourGuideContent extends StatelessWidget {
  final double scale;
  final TourGuideInfo guide;

  const _TourGuideContent({required this.scale, required this.guide});

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final ink = const Color(0xFF111111);
    final lines = <String>[
      'Name: ${guide.name}.',
      'ExperienceYears: ${guide.experienceYears}.',
      'Languages:${guide.languages}.',
      'Phone:${guide.phone}.',
      'Rating:${guide.rating}.',
      'Description:${guide.description}.',
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(s(4), s(6), s(4), s(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: EdgeInsets.only(bottom: s(2)),
              child: Text(
                line,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: s(13.8),
                  color: ink,
                  height: 1.28,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayBlock extends StatelessWidget {
  final double scale;
  final Color borderColor;
  final Color paper;
  final Color lightCell;
  final Color dayCell;
  final Color ink;
  final Color dayHeaderTextColor;
  final Color accentColor;
  final bool dayLabelOnRight;
  final DayDetail day;
  final String planId;

  const _DayBlock({
    required this.scale,
    required this.borderColor,
    required this.paper,
    required this.lightCell,
    required this.dayCell,
    required this.ink,
    required this.dayHeaderTextColor,
    required this.accentColor,
    required this.dayLabelOnRight,
    required this.day,
    required this.planId,
  });

  double s(double v) => v * scale;

  String _localizedDayLabel(BuildContext context, String rawLabel) {
    final match = RegExp(r'(\d+)').firstMatch(rawLabel);
    final dayNumber = match == null ? null : int.tryParse(match.group(1)!);
    if (dayNumber == null || dayNumber <= 0) return rawLabel;
    return '${context.l10n.plansDayLabel(dayNumber)}:';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final resolvedDayLabel = _localizedDayLabel(context, day.label);

    return ClipRRect(
      borderRadius: BorderRadius.circular(s(28)),
      child: Container(
        decoration: BoxDecoration(
          color: paper,
          border: Border.all(color: borderColor, width: s(2)),
          borderRadius: BorderRadius.circular(s(28)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sideWidth = constraints.maxWidth * 0.35;

            Widget horizontalDivider() =>
                Container(height: s(2), color: borderColor);
            Widget verticalDivider() =>
                Container(width: s(2), color: borderColor);

            Widget sectionTitle(String title) => Container(
              width: double.infinity,
              color: lightCell,
              padding: EdgeInsets.symmetric(vertical: s(14)),
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: s(20),
                  color: ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );

            Widget activitiesBlock(
              List<ActivityItem> items, {
              bool lastSection = false,
            }) {
              return Container(
                color: paper,
                padding: EdgeInsets.fromLTRB(
                  s(10),
                  s(10),
                  s(10),
                  lastSection ? s(8) : s(10),
                ),
                child: items.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: s(6)),
                        child: Text(
                          l10n.planDetailNoActivities,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: s(12.8),
                            color: ink,
                            height: 1.25,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (int i = 0; i < items.length; i++) ...[
                            _ActivityCard(
                              scale: scale,
                              ink: ink,
                              accentColor: accentColor,
                              item: items[i],
                              planId: planId,
                            ),
                            if (i < items.length - 1)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: s(8)),
                                child: Container(
                                  height: s(1.5),
                                  color: borderColor,
                                ),
                              ),
                          ],
                        ],
                      ),
              );
            }

            Widget contentColumn() => Expanded(
              child: Column(
                children: [
                  activitiesBlock(day.morning),
                  horizontalDivider(),
                  sectionTitle('${l10n.plansTableAfternoon}:'),
                  horizontalDivider(),
                  activitiesBlock(day.afternoon),
                  horizontalDivider(),
                  sectionTitle('${l10n.plansTableEvening}:'),
                  horizontalDivider(),
                  activitiesBlock(day.evening, lastSection: true),
                ],
              ),
            );

            Widget dayHeaderCell() => Container(
              width: sideWidth,
              padding: EdgeInsets.symmetric(vertical: s(11)),
              color: dayCell,
              alignment: Alignment.center,
              child: Text(
                resolvedDayLabel,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: s(18),
                  color: dayHeaderTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );

            Widget morningHeaderCell() => Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: s(11)),
                color: lightCell,
                alignment: Alignment.center,
                child: Text(
                  '${l10n.plansTableMorning}:',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: s(18),
                    color: ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );

            Widget sideColumn() => Container(width: sideWidth, color: paper);

            final headerChildren = dayLabelOnRight
                ? <Widget>[
                    morningHeaderCell(),
                    verticalDivider(),
                    dayHeaderCell(),
                  ]
                : <Widget>[
                    dayHeaderCell(),
                    verticalDivider(),
                    morningHeaderCell(),
                  ];

            final bodyChildren = dayLabelOnRight
                ? <Widget>[contentColumn(), verticalDivider(), sideColumn()]
                : <Widget>[sideColumn(), verticalDivider(), contentColumn()];

            return Column(
              children: [
                Row(children: headerChildren),
                horizontalDivider(),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: bodyChildren,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final double scale;
  final Color ink;
  final Color accentColor;
  final ActivityItem item;
  final String planId;

  const _ActivityCard({
    required this.scale,
    required this.ink,
    required this.accentColor,
    required this.item,
    required this.planId,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Text(
          '${item.title}.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: s(12.8),
            color: ink,
            fontWeight: FontWeight.w500,
            height: 1.15,
          ),
        ),
        SizedBox(height: s(3)),

        if ((item.open?.isNotEmpty ?? false) ||
            (item.close?.isNotEmpty ?? false))
          _IconLine(
            scale: scale,
            ink: ink,
            icon: Icons.access_time_outlined,
            centered: true,
            text:
                '${l10n.adminLabelOpenHours}: ${item.open ?? '-'} | ${l10n.adminLabelCloseHours}: ${item.close ?? '-'}.',
          ),

        if (item.price?.isNotEmpty ?? false)
          _IconLine(
            scale: scale,
            ink: ink,
            icon: Icons.payments_outlined,
            centered: true,
            text: '${l10n.planDetailPriceLabel}: ${item.price}.',
          ),

        if (item.location.isNotEmpty)
          _IconLine(
            scale: scale,
            ink: ink,
            icon: Icons.map_outlined,
            centered: true,
            text: '${l10n.planDetailLocationLabel}: ${item.location}.',
          ),

        if (item.rating?.isNotEmpty ?? false)
          _IconLine(
            scale: scale,
            ink: ink,
            icon: Icons.star_border_rounded,
            centered: true,
            text: '${l10n.planDetailRatingLabel}: ${item.rating}.',
          ),

        if ((item.open == null && item.close == null) &&
            (item.time?.isNotEmpty ?? false))
          _IconLine(
            scale: scale,
            ink: ink,
            icon: Icons.access_time_outlined,
            centered: true,
            text: '${item.time}.',
          ),
        if (item.distance?.isNotEmpty ?? false)
          _IconLine(
            scale: scale,
            ink: ink,
            icon: Icons.near_me_outlined,
            centered: true,
            text: '${l10n.planDetailDistance}: ${item.distance}.',
          ),

        SizedBox(height: s(7)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PillBtn(
              scale: scale,
              color: accentColor,
              text: '${l10n.actionOpenInMaps}.',
              onTap: () => _openMaps(item.mapsUrl, item.title),
            ),
            SizedBox(width: s(10)),
            _PillBtn(
              scale: scale,
              color: accentColor,
              text: '${l10n.actionBookNow}.',
              onTap: () => _bookAndSave(
                context,
                planId,
                item.id,
                item.title,
                l10n.planDetailActivityItemType,
                bookingUrl: item.bookingUrl,
                mapsUrl: item.mapsUrl,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IconLine extends StatelessWidget {
  final double scale;
  final Color ink;
  final IconData icon;
  final bool centered;
  final String text;

  const _IconLine({
    required this.scale,
    required this.ink,
    required this.icon,
    this.centered = false,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: scale * 2.2),
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(right: scale * 4),
                child: Icon(icon, size: scale * 11.5, color: ink),
              ),
            ),
            TextSpan(
              text: text,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: scale * 11.6,
                color: ink,
                height: 1.25,
              ),
            ),
          ],
        ),
        textAlign: centered ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final double scale;
  final Color color;
  final String text;
  final VoidCallback? onTap;
  const _PillBtn({
    required this.scale,
    required this.color,
    required this.text,
    this.onTap,
  });
  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: s(12), vertical: s(4.5)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(s(999)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: s(10.6),
            color: color.computeLuminance() < 0.46
                ? Colors.white
                : const Color(0xFF111111),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Attraction Card  (Nearby / Distant items)
// ═══════════════════════════════════════════════════════════════════════════
class _AttractionCard extends StatelessWidget {
  final double scale;
  final Color borderColor;
  final Color lightCell;
  final Color ink;
  final Color buttonColor;
  final ActivityItem item;
  final String planId;

  const _AttractionCard({
    required this.scale,
    required this.borderColor,
    required this.lightCell,
    required this.ink,
    required this.buttonColor,
    required this.item,
    required this.planId,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: lightCell,
      child: Padding(
        padding: EdgeInsets.fromLTRB(s(6), s(8), s(6), s(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.title}.',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: s(13.2),
                color: ink,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            SizedBox(height: s(3)),
            if ((item.open?.isNotEmpty ?? false) ||
                (item.close?.isNotEmpty ?? false))
              _IconLine(
                scale: scale,
                ink: ink,
                icon: Icons.access_time_outlined,
                text:
                    '${l10n.adminLabelOpenHours}: ${item.open ?? '-'} | ${l10n.adminLabelCloseHours}: ${item.close ?? '-'}.',
              ),
            if (item.price?.isNotEmpty ?? false)
              _IconLine(
                scale: scale,
                ink: ink,
                icon: Icons.payments_outlined,
                text: '${l10n.planDetailPriceLabel}: ${item.price}.',
              ),
            if (item.location.isNotEmpty)
              _IconLine(
                scale: scale,
                ink: ink,
                icon: Icons.map_outlined,
                text: '${l10n.planDetailLocationLabel}: ${item.location}.',
              ),
            if (item.rating?.isNotEmpty ?? false)
              _IconLine(
                scale: scale,
                ink: ink,
                icon: Icons.star_border_rounded,
                text: '${l10n.planDetailRatingLabel}: ${item.rating}.',
              ),
            if ((item.open == null && item.close == null) &&
                (item.time?.isNotEmpty ?? false))
              _IconLine(
                scale: scale,
                ink: ink,
                icon: Icons.access_time_outlined,
                text: '${item.time}.',
              ),
            if (item.distance?.isNotEmpty ?? false)
              _IconLine(
                scale: scale,
                ink: ink,
                icon: Icons.near_me_outlined,
                text: '${l10n.planDetailDistance}: ${item.distance}.',
              ),
            SizedBox(height: s(7)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PillBtn(
                  scale: scale,
                  color: buttonColor,
                  text: '${l10n.actionOpenInMaps}.',
                  onTap: () => _openMaps(item.mapsUrl, item.title),
                ),
                SizedBox(width: s(12)),
                _PillBtn(
                  scale: scale,
                  color: buttonColor,
                  text: '${l10n.actionBookNow}.',
                  onTap: () => _bookAndSave(
                    context,
                    planId,
                    item.id,
                    item.title,
                    l10n.planDetailActivityItemType,
                    bookingUrl: item.bookingUrl,
                    mapsUrl: item.mapsUrl,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
