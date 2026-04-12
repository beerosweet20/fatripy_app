import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../localization/app_localizations_ext.dart';
import 'plan_detail_screen.dart';

class PlanSharePreviewScreen extends StatelessWidget {
  final PlanDetailData data;
  final HotelPlanOption hotelOption;
  final int hotelIndex;

  const PlanSharePreviewScreen({
    super.key,
    required this.data,
    required this.hotelOption,
    required this.hotelIndex,
  });

  Future<Uint8List> _buildPdf(BuildContext context, PdfPageFormat format) async {
    final l10n = context.l10n;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final baseFont = await PdfGoogleFonts.notoNaskhArabicRegular();
    final boldFont = await PdfGoogleFonts.notoNaskhArabicBold();
    final doc = pw.Document();

    pw.Widget sectionTitle(String text) => pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F2E0B6'),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
          ),
          child: pw.Text(
            text,
            style: pw.TextStyle(font: boldFont, fontSize: 14),
            textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
        );

    pw.Widget paragraphLine(String text, {bool bold = false}) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text(
            text,
            style: pw.TextStyle(
              font: bold ? boldFont : baseFont,
              fontSize: 11,
              lineSpacing: 2,
            ),
            textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
        );

    pw.Widget activityList(List<ActivityItem> items) {
      if (items.isEmpty) {
        return paragraphLine(l10n.planDetailNoActivities);
      }
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final item in items)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Bullet(
                text: [
                  item.title,
                  if (item.location.isNotEmpty) item.location,
                  if ((item.distance ?? '').isNotEmpty) item.distance!,
                ].join(' - '),
                style: pw.TextStyle(font: baseFont, fontSize: 11),
              ),
            ),
        ],
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
        margin: const pw.EdgeInsets.all(24),
        build: (pdfContext) => [
          pw.Text(
            data.title,
            style: pw.TextStyle(font: boldFont, fontSize: 20),
            textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          ),
          pw.SizedBox(height: 8),
          paragraphLine(
            l10n.planDetailHotelPosition(
              hotelIndex + 1,
              data.resolvedHotelOptions.length,
            ),
          ),
          pw.SizedBox(height: 12),
          sectionTitle(l10n.planDetailHotelSection),
          pw.SizedBox(height: 8),
          paragraphLine('${l10n.plansLabelHotel}: ${hotelOption.accommodation.name}'),
          if (hotelOption.accommodation.location.isNotEmpty)
            paragraphLine(
              '${l10n.planDetailLocationLabel}: ${hotelOption.accommodation.location}',
            ),
          if (hotelOption.accommodation.price.isNotEmpty)
            paragraphLine(
              '${l10n.planDetailPriceLabel}: ${hotelOption.accommodation.price}',
            ),
          if (hotelOption.accommodation.rating.isNotEmpty)
            paragraphLine(
              '${l10n.planDetailRatingLabel}: ${hotelOption.accommodation.rating}',
            ),
          if (hotelOption.accommodation.amenities.isNotEmpty)
            paragraphLine(
              '${l10n.planDetailAmenities}: ${hotelOption.accommodation.amenities}',
            ),
          if (data.planReasons.isNotEmpty)
            paragraphLine(
              '${l10n.planDetailWhyPlan}: ${data.planReasons.join(' | ')}',
            ),
          if (hotelOption.hotelReasons.isNotEmpty)
            paragraphLine(
              '${l10n.planDetailWhyHotel}: ${hotelOption.hotelReasons.join(' | ')}',
            ),
          if (data.tourGuide != null) ...[
            pw.SizedBox(height: 12),
            sectionTitle(l10n.planDetailTourGuideSection),
            pw.SizedBox(height: 8),
            paragraphLine('Name: ${data.tourGuide!.name}'),
            paragraphLine('Experience: ${data.tourGuide!.experienceYears}'),
            paragraphLine('Languages: ${data.tourGuide!.languages}'),
            paragraphLine('Phone: ${data.tourGuide!.phone}'),
            paragraphLine('Rating: ${data.tourGuide!.rating}'),
            paragraphLine('Description: ${data.tourGuide!.description}'),
          ],
          for (final day in hotelOption.days) ...[
            pw.SizedBox(height: 12),
            sectionTitle(day.label.replaceAll(':', '')),
            pw.SizedBox(height: 8),
            paragraphLine(
              'Morning: ${day.morning.isEmpty ? '-' : day.morning.map((item) => item.title).join(' | ')}',
              bold: true,
            ),
            paragraphLine(
              'Afternoon: ${day.afternoon.isEmpty ? '-' : day.afternoon.map((item) => item.title).join(' | ')}',
            ),
            paragraphLine(
              'Evening: ${day.evening.isEmpty ? '-' : day.evening.map((item) => item.title).join(' | ')}',
            ),
          ],
          pw.SizedBox(height: 12),
          sectionTitle(l10n.plansLabelNearbyAttractions),
          pw.SizedBox(height: 8),
          activityList(hotelOption.nearby),
          pw.SizedBox(height: 12),
          sectionTitle(l10n.plansLabelDistantAttractions),
          pw.SizedBox(height: 8),
          activityList(hotelOption.distant),
          pw.SizedBox(height: 12),
          sectionTitle(l10n.plansLabelEvents),
          pw.SizedBox(height: 8),
          if (data.eventLines.isEmpty)
            paragraphLine(l10n.planDetailNoEvents)
          else
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                for (final line in data.eventLines)
                  paragraphLine(line),
              ],
            ),
        ],
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.planDetailPdfPreview),
      ),
      body: PdfPreview(
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: false,
        build: (format) => _buildPdf(context, format),
      ),
    );
  }
}
