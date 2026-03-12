import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../domain/entities/booking.dart';
import '../../localization/app_localizations_ext.dart';

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
  final List<DayDetail> days;
  final List<ActivityItem> nearby;
  final List<ActivityItem> distant;
  final List<String> eventLines;

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
    required this.days,
    required this.nearby,
    required this.distant,
    required this.eventLines,
  });
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
    context.push('/booking-success?type=$type');
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

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    print('Budget Status: ${data.budgetStatus}');
    final w = MediaQuery.of(context).size.width;
    final scale = (w / 390.0).clamp(0.85, 1.10);
    double s(double v) => v * scale;

    final paper = const Color(0xFFFFF3E1);
    final ink = const Color(0xFF111111);
    final stroke = data.borderColor;
    final lightCell = const Color(0xFFFFF6E8);
    final dayCell = const Color(0xFFFFDFA1);
    final budgetStatus = (data.budgetStatus ?? '').toLowerCase().trim();
    final isLowBudget =
        budgetStatus == 'low' ||
        (data.userBudget != null &&
            data.minimumRequired != null &&
            data.userBudget! < data.minimumRequired!);
    final userBudgetLabel = _formatSarNumber(data.userBudget);
    final minimumRequiredLabel = _formatSarNumber(data.minimumRequired);
    final bannerColors = _budgetBannerPalette(data.accentColor);

    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───────────────────────────────────────────────────
            Container(
              color: data.headerColor,
              padding: EdgeInsets.symmetric(horizontal: s(8), vertical: s(12)),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: s(18),
                      color: ink,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        context.l10n.planDetailTitle(data.title),
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: s(18),
                          color: ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: s(44)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(s(12), s(14), s(12), s(20)),
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
                    _PillOverlayBox(
                      scale: scale,
                      borderColor: stroke,
                      pillColor: dayCell,
                      pillAlignment: AlignmentDirectional.centerStart,
                      pillText: '${context.l10n.planDetailHotelSection}:',
                      child: _HotelInfoContent(
                        scale: scale,
                        hotel: data.accommodation,
                        planId: data.sourceTripPlanId,
                      ),
                    ),

                    SizedBox(height: s(24)),

                    // ─── Days ──────────────────────────────────────────
                    for (int di = 0; di < data.days.length; di++) ...[
                      _DayBlock(
                        scale: scale,
                        borderColor: stroke,
                        paper: paper,
                        lightCell: lightCell,
                        dayCell: dayCell,
                        ink: ink,
                        day: data.days[di],
                        planId: data.sourceTripPlanId,
                        // odd index (0-based) → Day label on RIGHT side
                        dayLabelOnRight: di.isOdd,
                      ),
                      SizedBox(height: s(14)),
                    ],

                    // ─── Nearby Attraction ─────────────────────────────
                    _PillOverlayBox(
                      scale: scale,
                      borderColor: stroke,
                      pillColor: dayCell,
                      pillAlignment: AlignmentDirectional.centerEnd,
                      pillText: '${context.l10n.plansLabelNearbyAttractions}:',
                      child: Column(
                        children: [
                          for (int i = 0; i < data.nearby.length; i++) ...[
                            _AttractionCard(
                              scale: scale,
                              borderColor: stroke,
                              lightCell: lightCell,
                              ink: ink,
                              item: data.nearby[i],
                              planId: data.sourceTripPlanId,
                            ),
                            if (i < data.nearby.length - 1)
                              SizedBox(height: s(10)),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: s(24)),

                    // ─── Distant Attraction ────────────────────────────
                    _PillOverlayBox(
                      scale: scale,
                      borderColor: stroke,
                      pillColor: dayCell,
                      pillAlignment: AlignmentDirectional.centerStart,
                      pillText: '${context.l10n.plansLabelDistantAttractions}:',
                      child: Column(
                        children: [
                          for (int i = 0; i < data.distant.length; i++) ...[
                            _AttractionCard(
                              scale: scale,
                              borderColor: stroke,
                              lightCell: lightCell,
                              ink: ink,
                              item: data.distant[i],
                              planId: data.sourceTripPlanId,
                            ),
                            if (i < data.distant.length - 1)
                              SizedBox(height: s(10)),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: s(24)),

                    // ─── Event ─────────────────────────────────────────
                    _PillOverlayBox(
                      scale: scale,
                      borderColor: stroke,
                      pillColor: dayCell,
                      pillAlignment: AlignmentDirectional.centerEnd,
                      pillText: '${context.l10n.plansLabelEvents}:',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data.eventLines.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: s(4)),
                              child: Text(
                                context.l10n.planDetailNoEvents,
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: s(13.5),
                                  color: const Color(0xFF111111),
                                  height: 1.4,
                                ),
                              ),
                            )
                          else
                            for (final line in data.eventLines)
                              Padding(
                                padding: EdgeInsets.only(bottom: s(4)),
                                child: Text(
                                  line,
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: s(13.5),
                                    color: const Color(0xFF111111),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
  final AlignmentGeometry pillAlignment;
  final String pillText;
  final Widget child;

  const _PillOverlayBox({
    required this.scale,
    required this.borderColor,
    required this.pillColor,
    required this.pillAlignment,
    required this.pillText,
    required this.child,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final ink = const Color(0xFF111111);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(top: s(18)),
          padding: EdgeInsets.fromLTRB(s(14), s(22), s(14), s(14)),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E8),
            border: Border.all(color: borderColor, width: s(1.8)),
            borderRadius: BorderRadius.circular(s(12)),
          ),
          child: child,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Align(
            alignment: pillAlignment,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: s(18), vertical: s(10)),
              decoration: BoxDecoration(
                color: pillColor,
                borderRadius: BorderRadius.circular(s(999)),
              ),
              child: Text(
                pillText,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: s(16.5),
                  color: ink,
                  fontWeight: FontWeight.w700,
                ),
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

  const _HotelInfoContent({
    required this.scale,
    required this.hotel,
    required this.planId,
  });
  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ink = const Color(0xFF111111);
    final lines = [
      '${l10n.plansLabelHotel}:  ${hotel.name}.',
      if (hotel.location.isNotEmpty)
        '${l10n.planDetailLocationLabel}:  ${hotel.location}.',
      if (hotel.price.isNotEmpty)
        '${l10n.planDetailPriceLabel}:  ${hotel.price}.',
      if (hotel.rating.isNotEmpty)
        '${l10n.planDetailRatingLabel}:  ${hotel.rating}.',
      if (hotel.amenities.isNotEmpty)
        '${l10n.planDetailAmenities}:  ${hotel.amenities}.',
      '${l10n.actionOpenInMaps}.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: s(8)),
        for (final line in lines)
          Padding(
            padding: EdgeInsets.only(bottom: s(3)),
            child: Text(
              line,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: s(13.5),
                color: ink,
                height: 1.35,
              ),
            ),
          ),
        SizedBox(height: s(12)),
        InkWell(
          onTap: () => _bookAndSave(
            context,
            planId,
            hotel.id,
            hotel.name,
            l10n.planDetailHotelItemType,
            bookingUrl: hotel.bookingUrl,
            mapsUrl: hotel.mapsUrl,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(s(8)),
            ),
            child: Text(
              l10n.planDetailBookHotelViaMaps,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Georgia',
                fontSize: s(13),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Day Block  — mimics the exact layout from the reference images
//  Day 1  : [Day label | left (gold)]  [Morning | right (light)]
//  Day 2  : [Morning  | left (light)]  [Day label | right (gold)]
// ═══════════════════════════════════════════════════════════════════════════
class _DayBlock extends StatelessWidget {
  final double scale;
  final Color borderColor;
  final Color paper;
  final Color lightCell;
  final Color dayCell;
  final Color ink;
  final DayDetail day;
  final String planId;
  final bool dayLabelOnRight;

  const _DayBlock({
    required this.scale,
    required this.borderColor,
    required this.paper,
    required this.lightCell,
    required this.dayCell,
    required this.ink,
    required this.day,
    required this.planId,
    required this.dayLabelOnRight,
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
      borderRadius: BorderRadius.circular(s(22)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: s(2)),
          borderRadius: BorderRadius.circular(s(22)),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final leftW = c.maxWidth * 0.28;
            final rightW = c.maxWidth - leftW;

            Widget divH() => Container(height: s(2), color: borderColor);
            Widget divV() => Container(width: s(2), color: borderColor);

            // Top header row
            Widget headerRow() {
              if (!dayLabelOnRight) {
                // Day 1: Day label LEFT, Morning RIGHT
                return Row(
                  children: [
                    Container(
                      width: leftW,
                      padding: EdgeInsets.symmetric(vertical: s(10)),
                      color: dayCell,
                      alignment: Alignment.center,
                      child: Text(
                        resolvedDayLabel,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: s(18),
                          color: ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    divV(),
                    Container(
                      width: rightW - s(2),
                      padding: EdgeInsets.symmetric(vertical: s(10)),
                      color: lightCell,
                      alignment: Alignment.center,
                      child: Text(
                        '${l10n.plansTableMorning}:',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: s(18),
                          color: ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Day 2: Morning LEFT, Day label RIGHT
                return Row(
                  children: [
                    Container(
                      width: leftW,
                      padding: EdgeInsets.symmetric(vertical: s(16)),
                      color: lightCell,
                      alignment: Alignment.center,
                      child: Text(
                        '${l10n.plansTableMorning}:',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: s(18),
                          color: ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    divV(),
                    Container(
                      width: rightW - s(2),
                      padding: EdgeInsets.symmetric(vertical: s(10)),
                      color: dayCell,
                      alignment: Alignment.center,
                      child: Text(
                        resolvedDayLabel,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: s(18),
                          color: ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              }
            }

            // Full-width section title (Afternoon / Evening) across entire row
            Widget sectionTitle(String title) => Container(
              color: lightCell,
              padding: EdgeInsets.symmetric(vertical: s(14)),
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: s(20),
                  color: ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );

            // Activities block (Morning items are shown in the right column)
            Widget activitiesBlock(
              List<ActivityItem> items, {
              bool lastSection = false,
            }) {
              return Container(
                color: lightCell,
                padding: EdgeInsets.fromLTRB(
                  s(10),
                  s(12),
                  s(10),
                  lastSection ? s(10) : s(12),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      _ActivityCard(
                        scale: scale,
                        ink: ink,
                        borderColor: borderColor,
                        item: items[i],
                        planId: planId,
                      ),
                      if (i < items.length - 1)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: s(10)),
                          child: Container(
                            height: s(1.5),
                            color: borderColor.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ],
                ),
              );
            }

            // For Day 1 (dayLabelOnRight = false):
            //   Header row: [Day | Morning]
            //   Body: left column = empty, right column = activities + Afternoon + activities + Evening + activities
            // For Day 2 (dayLabelOnRight = true):
            //   Header row: [Morning | Day]
            //   Body: left column = activities + Afternoon + activities + Evening + activities, right column = empty
            //   But from images, it looks like activities are always in the wider column

            if (!dayLabelOnRight) {
              // Day 1 layout: morning activities shown in the wider (right) column
              // Below header: left col=empty, right col=morning activities
              // Then full-width Afternoon, then full-width Evening sections
              return Column(
                children: [
                  headerRow(),
                  divH(),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left column – empty (day color background)
                        Container(width: leftW, color: paper),
                        divV(),
                        // Right column – morning activities
                        SizedBox(
                          width: rightW - s(2),
                          child: activitiesBlock(day.morning),
                        ),
                      ],
                    ),
                  ),
                  divH(),
                  sectionTitle('${l10n.plansTableAfternoon}:'),
                  divH(),
                  activitiesBlock(day.afternoon),
                  divH(),
                  sectionTitle('${l10n.plansTableEvening}:'),
                  divH(),
                  activitiesBlock(day.evening, lastSection: true),
                ],
              );
            } else {
              // Day 2 layout: morning activities shown in the wider (left) column
              return Column(
                children: [
                  headerRow(),
                  divH(),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left column – empty (narrow)
                        Container(width: leftW, color: paper),
                        divV(),
                        // Right column – morning activities (wider)
                        SizedBox(
                          width: rightW - s(2),
                          child: activitiesBlock(day.morning),
                        ),
                      ],
                    ),
                  ),
                  divH(),
                  sectionTitle('${l10n.plansTableAfternoon}:'),
                  divH(),
                  activitiesBlock(day.afternoon),
                  divH(),
                  sectionTitle('${l10n.plansTableEvening}:'),
                  divH(),
                  activitiesBlock(day.evening, lastSection: true),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Activity Card  — shows emoji-prefixed info lines + pill buttons
// ═══════════════════════════════════════════════════════════════════════════
class _ActivityCard extends StatelessWidget {
  final double scale;
  final Color ink;
  final Color borderColor;
  final ActivityItem item;
  final String planId;

  const _ActivityCard({
    required this.scale,
    required this.ink,
    required this.borderColor,
    required this.item,
    required this.planId,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        // Title with store emoji
        Text(
          '${item.title}.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: s(14),
            color: ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: s(4)),

        // Open / Close
        if ((item.open?.isNotEmpty ?? false) ||
            (item.close?.isNotEmpty ?? false))
          _EmojiLine(
            scale: scale,
            ink: ink,
            text:
                '${l10n.adminLabelOpenHours}: ${item.open ?? '-'} | ${l10n.adminLabelCloseHours}: ${item.close ?? '-'}.',
          ),

        // Price
        if (item.price?.isNotEmpty ?? false)
          _EmojiLine(
            scale: scale,
            ink: ink,
            text: '${l10n.planDetailPriceLabel}: ${item.price}.',
          ),

        // Location
        if (item.location.isNotEmpty)
          _EmojiLine(
            scale: scale,
            ink: ink,
            text: '${l10n.planDetailLocationLabel}: ${item.location}.',
          ),

        // Rating
        if (item.rating?.isNotEmpty ?? false)
          _EmojiLine(
            scale: scale,
            ink: ink,
            text: '${l10n.planDetailRatingLabel}: ${item.rating}.',
          ),

        // Time fallback
        if ((item.open == null && item.close == null) &&
            (item.time?.isNotEmpty ?? false))
          _EmojiLine(scale: scale, ink: ink, text: '${item.time}.'),

        SizedBox(height: s(8)),
        InkWell(
          onTap: () => _openMaps(item.mapsUrl, item.title),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(6)),
            decoration: BoxDecoration(
              border: Border.all(color: ink),
              borderRadius: BorderRadius.circular(s(8)),
            ),
            child: Text(
              l10n.planDetailNavigateToPlace,
              style: TextStyle(
                color: ink,
                fontFamily: 'Georgia',
                fontSize: s(12),
              ),
            ),
          ),
        ),
        // Distance fallback
        if (item.distance?.isNotEmpty ?? false)
          _EmojiLine(
            scale: scale,
            ink: ink,
            text: '${l10n.planDetailDistance}: ${item.distance}.',
          ),

        SizedBox(height: s(8)),
        // Buttons
        Wrap(
          alignment: WrapAlignment.center,
          spacing: s(8),
          runSpacing: s(6),
          children: [
            _PillBtn(
              scale: scale,
              text: '${l10n.actionOpenInMaps}.',
              onTap: () => _openMaps(item.mapsUrl, item.title),
            ),
            _PillBtn(
              scale: scale,
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

class _EmojiLine extends StatelessWidget {
  final double scale;
  final Color ink;
  final String text;
  const _EmojiLine({
    required this.scale,
    required this.ink,
    required this.text,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: scale * 2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Georgia',
          fontSize: scale * 13,
          color: ink,
          height: 1.3,
        ),
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final double scale;
  final String text;
  final VoidCallback? onTap;
  const _PillBtn({required this.scale, required this.text, this.onTap});
  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: s(14), vertical: s(8)),
        decoration: BoxDecoration(
          color: const Color(0xFFF7DFAE),
          borderRadius: BorderRadius.circular(s(999)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: s(13),
            color: const Color(0xFF111111),
            fontWeight: FontWeight.w600,
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
  final ActivityItem item;
  final String planId;

  const _AttractionCard({
    required this.scale,
    required this.borderColor,
    required this.lightCell,
    required this.ink,
    required this.item,
    required this.planId,
  });

  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.fromLTRB(s(12), s(10), s(12), s(12)),
      decoration: BoxDecoration(
        color: lightCell,
        borderRadius: BorderRadius.circular(s(12)),
        border: Border.all(color: borderColor, width: s(1.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '${item.title}.',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: s(14),
              color: ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: s(4)),

          if ((item.open?.isNotEmpty ?? false) ||
              (item.close?.isNotEmpty ?? false))
            _InfoLine(
              scale: scale,
              ink: ink,
              text:
                  '${l10n.adminLabelOpenHours}: ${item.open ?? '-'} | ${l10n.adminLabelCloseHours}: ${item.close ?? '-'}.',
            ),

          if (item.price?.isNotEmpty ?? false)
            _InfoLine(
              scale: scale,
              ink: ink,
              text: '${l10n.planDetailPriceLabel}: ${item.price}.',
            ),

          if (item.location.isNotEmpty)
            _InfoLine(
              scale: scale,
              ink: ink,
              text: '${l10n.planDetailLocationLabel}: ${item.location}.',
            ),

          if (item.rating?.isNotEmpty ?? false)
            _InfoLine(
              scale: scale,
              ink: ink,
              text: '${l10n.planDetailRatingLabel}: ${item.rating}.',
            ),

          if ((item.open == null && item.close == null) &&
              (item.time?.isNotEmpty ?? false))
            _InfoLine(scale: scale, ink: ink, text: '${item.time}.'),

          if (item.distance?.isNotEmpty ?? false)
            _InfoLine(
              scale: scale,
              ink: ink,
              text: '${l10n.planDetailDistance}: ${item.distance}.',
            ),

          SizedBox(height: s(8)),
          // Buttons — centered
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PillBtn(
                scale: scale,
                text: '${l10n.actionOpenInMaps}.',
                onTap: () => _openMaps(item.mapsUrl, item.title),
              ),
              SizedBox(width: s(12)),
              _PillBtn(
                scale: scale,
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
    );
  }
}

class _InfoLine extends StatelessWidget {
  final double scale;
  final Color ink;
  final String text;
  const _InfoLine({required this.scale, required this.ink, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: scale * 2.5),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Georgia',
          fontSize: scale * 13.5,
          color: ink,
          height: 1.35,
        ),
      ),
    );
  }
}
