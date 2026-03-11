import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../data/firebase/auth_service.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../domain/entities/booking.dart';
import '../../localization/app_localizations_ext.dart';
import '../admin/admin_bottom_nav.dart';
import '../admin/admin_design.dart';

class BookingsScreen extends StatefulWidget {
  final bool showAllForAdmin;

  const BookingsScreen({super.key, this.showAllForAdmin = false});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingRepository _bookingRepo = BookingRepository();
  final AuthService _authService = AuthService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  Color _bookingTypeColor(BuildContext context, String itemType) {
    final type = itemType.toLowerCase().trim();
    if (type.contains('hotel') || type.contains('accommodation')) {
      return const Color(0xFFE18299); // Brand pink for stays
    }
    if (type.contains('activity') || type.contains('event')) {
      return const Color(0xFF2E4474); // Brand navy for activities
    }
    return Theme.of(context).primaryColor;
  }

  String _localizedStatus(BuildContext context, String status) {
    final normalized = status.toLowerCase().trim();
    if (normalized == 'booked') return context.l10n.statusBooked;
    if (normalized == 'confirmed') return context.l10n.statusConfirmed;
    if (normalized == 'pending') return context.l10n.statusPending;
    if (normalized == 'cancelled' || normalized == 'canceled') {
      return context.l10n.statusCancelled;
    }
    return status;
  }

  Widget _statusChip(BuildContext context, String status) {
    final text = _localizedStatus(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F8EE),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFE8CB)),
      ),
      child: Text(
        '${context.l10n.bookingsReceiptStatus}: $text',
        style: const TextStyle(
          color: Color(0xFF1E7A38),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return Scaffold(body: Center(child: Text(context.l10n.errorPleaseLogin)));
    }

    final body = FutureBuilder<bool>(
      future: widget.showAllForAdmin
          ? _authService.isAdmin()
          : Future<bool>.value(false),
      builder: (context, adminSnapshot) {
        if (adminSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (adminSnapshot.hasError) {
          return Center(
            child: Text(
              context.l10n.errorWithDetails(adminSnapshot.error.toString()),
            ),
          );
        }

        final canViewAll = widget.showAllForAdmin && adminSnapshot.data == true;

        return FutureBuilder<List<Booking>>(
          future: canViewAll
              ? _bookingRepo.getAllBookingsForAdmin()
              : _bookingRepo.getAllBookings(_uid),
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

            final bookings = [...(snapshot.data ?? const <Booking>[])];
            if (bookings.isEmpty) {
              if (widget.showAllForAdmin) {
                return adminEmptyState(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  message: context.l10n.bookingsEmpty,
                );
              }
              return Center(child: Text(context.l10n.bookingsEmpty));
            }

            bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (!widget.showAllForAdmin) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return _buildBookingTile(
                    context,
                    booking,
                    adminMode: false,
                    accentIndex: index,
                  );
                },
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _buildBookingTile(
                  context,
                  booking,
                  adminMode: true,
                  accentIndex: index,
                );
              },
            );
          },
        );
      },
    );

    if (widget.showAllForAdmin) {
      return Scaffold(
        backgroundColor: AdminPalette.background,
        appBar: adminAppBar(context, title: context.l10n.navBookings),
        body: AdminDecoratedBody(child: body),
        bottomNavigationBar: const AdminBottomNav(
          current: AdminNavTab.bookings,
        ),
      );
    }

    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: primary,
        iconTheme: IconThemeData(color: primary),
        title: Text(
          context.l10n.navBookings,
          style: TextStyle(color: primary, fontWeight: FontWeight.w700),
        ),
      ),
      body: body,
    );
  }

  Widget _buildBookingTile(
    BuildContext context,
    Booking booking, {
    required bool adminMode,
    required int accentIndex,
  }) {
    final dateLabel = booking.createdAt.toLocal().toString().split(' ')[0];
    final reference = booking.bookingReference ?? '-';
    final itemTitle = booking.itemTitle ?? booking.itemId;
    final typeColor = _bookingTypeColor(context, booking.itemType);

    if (!adminMode) {
      return Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: CircleAvatar(
            backgroundColor: typeColor.withValues(alpha: 0.14),
            child: Icon(Icons.receipt_long_rounded, size: 22, color: typeColor),
          ),
          title: Text(
            itemTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                context.l10n.bookingItemTitle(booking.itemType),
                style: TextStyle(color: typeColor),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _statusChip(context, booking.status),
                  Text(context.l10n.bookingPlacedOn(dateLabel)),
                ],
              ),
              const SizedBox(height: 4),
              Text('${context.l10n.bookingsReceiptReference}: $reference'),
            ],
          ),
          isThreeLine: true,
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () => _showReceiptDialog(
            context,
            booking,
            dateLabel,
            itemTitle,
            reference,
          ),
        ),
      );
    }

    return Card(
      color: AdminPalette.surface,
      elevation: 0,
      shape: adminCardShape(accentIndex: accentIndex),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: typeColor.withValues(alpha: 0.16),
          child: Icon(Icons.receipt_long_outlined, color: typeColor),
        ),
        title: Text(
          itemTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AdminPalette.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              context.l10n.bookingItemTitle(booking.itemType),
              style: TextStyle(color: typeColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _statusChip(context, booking.status),
                Text(
                  context.l10n.bookingPlacedOn(dateLabel),
                  style: const TextStyle(color: AdminPalette.mutedText),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${context.l10n.bookingsReceiptReference}: $reference',
              style: const TextStyle(color: AdminPalette.mutedText),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right, color: AdminPalette.navy),
        onTap: () => _showReceiptDialog(
          context,
          booking,
          dateLabel,
          itemTitle,
          reference,
        ),
      ),
    );
  }

  void _showReceiptDialog(
    BuildContext context,
    Booking booking,
    String dateLabel,
    String itemTitle,
    String reference,
  ) {
    final primary = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminPalette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.bookingsReceiptTitle,
              style: textTheme.titleLarge?.copyWith(
                color: primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: primary.withValues(alpha: 0.22), thickness: 1),
          ],
        ),
        content: DefaultTextStyle(
          style:
              textTheme.bodyMedium?.copyWith(height: 1.45) ??
              const TextStyle(height: 1.45),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${context.l10n.bookingsReceiptId}: ${booking.id}'),
              const SizedBox(height: 10),
              Text('${context.l10n.bookingsReceiptReference}: $reference'),
              const SizedBox(height: 10),
              Text('${context.l10n.bookingsReceiptItem}: $itemTitle'),
              const SizedBox(height: 10),
              Text('${context.l10n.bookingsReceiptType}: ${booking.itemType}'),
              const SizedBox(height: 10),
              Text(
                '${context.l10n.bookingsReceiptStatus}: ${_localizedStatus(context, booking.status)}',
              ),
              const SizedBox(height: 10),
              Text('${context.l10n.bookingsReceiptDate}: $dateLabel'),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: primary),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              context.l10n.actionClose,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
