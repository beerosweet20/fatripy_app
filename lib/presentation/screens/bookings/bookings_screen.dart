import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/booking_repository.dart';
import '../../../domain/entities/booking.dart';
import '../../localization/app_localizations_ext.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingRepository _bookingRepo = BookingRepository();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return Scaffold(body: Center(child: Text(context.l10n.errorPleaseLogin)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navBookings)),
      body: FutureBuilder<List<Booking>>(
        future: _bookingRepo.getAllBookings(_uid),
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

          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return Center(child: Text(context.l10n.bookingsEmpty));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final dateLabel =
                  booking.createdAt.toLocal().toString().split(' ')[0];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: const Icon(Icons.receipt_long, size: 36),
                  title: Text(
                    context.l10n.bookingItemTitle(booking.itemType),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    context.l10n.bookingListSubtitle(
                      booking.status,
                      dateLabel,
                    ),
                  ),
                  onTap: () {
                    // TODO: Navigate to details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
