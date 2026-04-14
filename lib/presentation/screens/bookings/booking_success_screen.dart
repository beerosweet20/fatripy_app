import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/app_localizations_ext.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String itemType; // e.g. "Attraction" or "Hotel"

  const BookingSuccessScreen({super.key, required this.itemType});

  static const String routeName = '/plans/booking-success';

  @override
  Widget build(BuildContext context) {
    // Colors based on the screenshot
    const Color bgColor = Color(0xFFFFF7E5);
    const Color pinkColor = Color(0xFFE18299);
    const Color pinkFill = Color(0xFFF6D0D9);

    final w = MediaQuery.of(context).size.width;
    final scale = (w / 390.0).clamp(0.85, 1.15);
    double s(double v) => v * scale;
    final l10n = context.l10n;

    final typeDisplay = itemType.isNotEmpty
        ? itemType
        : l10n.bookingSuccessDefaultItemType;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: Text(l10n.bookingSuccessTitle)),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: s(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Pink Circle with Checkmark
              Container(
                width: s(160),
                height: s(160),
                decoration: BoxDecoration(
                  color: pinkFill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: pinkColor.withValues(alpha: 0.6),
                    width: s(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: s(10),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(Icons.check, color: pinkColor, size: s(80)),
                ),
              ),
              SizedBox(height: s(40)),
              // Success Text
              Text(
                l10n.bookingSuccessTitle,
                style: GoogleFonts.inriaSerif(
                  fontSize: s(46),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              SizedBox(height: s(24)),
              // Description Text
              Text(
                l10n.bookingSuccessBody(typeDisplay),
                textAlign: TextAlign.center,
                style: GoogleFonts.inriaSerif(
                  fontSize: s(22),
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              SizedBox(height: s(40)),
              // Click here text
              GestureDetector(
                onTap: () {
                  // Navigate to bookings tab
                  context.go('/account/bookings');
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inriaSerif(
                      fontSize: s(18),
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: l10n.bookingSuccessViewAllPrompt(
                          typeDisplay.toLowerCase(),
                        ),
                      ),
                      TextSpan(
                        text: l10n.bookingSuccessClickHere,
                        style: TextStyle(color: pinkColor),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 4),
              // Back to plan button
              SizedBox(
                width: double.infinity,
                height: s(64),
                child: ElevatedButton(
                  onPressed: () {
                    // Pop back to plan detail
                    if (Navigator.of(context).canPop()) {
                      context.pop();
                    } else {
                      context.go('/plans');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(s(40)),
                    ),
                  ),
                  child: Text(
                    l10n.bookingSuccessBackToPlan,
                    style: GoogleFonts.inriaSerif(
                      fontSize: s(24),
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: s(32)),
            ],
          ),
        ),
      ),
    );
  }
}
