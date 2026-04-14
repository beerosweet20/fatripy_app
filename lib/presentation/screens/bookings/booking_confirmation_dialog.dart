import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/app_localizations_ext.dart';

class BookingConfirmationDialog extends StatelessWidget {
  final String bookingReference;
  final String itemType;
  final String itemTitle;
  final DateTime bookingDate;

  const BookingConfirmationDialog({
    super.key,
    required this.bookingReference,
    required this.itemType,
    required this.itemTitle,
    required this.bookingDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateText =
        '${bookingDate.year}-${bookingDate.month.toString().padLeft(2, '0')}-${bookingDate.day.toString().padLeft(2, '0')}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFF6D0D9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 48,
                color: Color(0xFFE18299),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.bookingConfirmedTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inriaSerif(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              label: l10n.bookingsReceiptReference,
              value: bookingReference,
            ),
            _SummaryRow(label: l10n.bookingsReceiptType, value: itemType),
            _SummaryRow(label: l10n.bookingsReceiptItem, value: itemTitle),
            _SummaryRow(label: l10n.bookingsReceiptDate, value: dateText),
            const SizedBox(height: 16),
            Text(l10n.bookingConfirmedBody, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.actionDone),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/account/bookings');
                    },
                    child: Text(l10n.bookingViewBookings),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
