import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_strings.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/booking.dart';

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
      return const Scaffold(body: Center(child: Text("Please login")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navBookings)),
      body: FutureBuilder<List<Booking>>(
        future: _bookingRepo.getAllBookings(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات حالياً.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: const Icon(Icons.receipt_long, size: 36),
                  title: Text(
                    'Booking: ${booking.itemType}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Status: ${booking.status} • Placed: ${booking.createdAt.toLocal().toString().split(' ')[0]}',
                  ),
                  onTap: () {
                    // Navigate to details
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
