import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/trip_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../domain/entities/trip_plan.dart';
import '../../../domain/entities/booking.dart';
import '../../localization/app_localizations_ext.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TripRepository _tripRepo = TripRepository();
  final BookingRepository _bookingRepo = BookingRepository();

  String? _fullName;
  int _familyCount = 1;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _fullName = doc.data()?['fullName'];
          _familyCount = 1;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Center(child: Text(context.l10n.errorPleaseLogin));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final padding = isWide ? constraints.maxWidth * 0.1 : 16.0;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              await _loadDashboardData();
            },
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
              children: [
                _buildGreetingSection(),
                const SizedBox(height: 24),
                if (isWide)
                  Row(
                    children: [
                      Expanded(child: _buildFamilyCard()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCTACard()),
                    ],
                  )
                else ...[
                  _buildFamilyCard(),
                  const SizedBox(height: 16),
                  _buildCTACard(),
                ],
                const SizedBox(height: 32),
                _buildSectionTitle(
                  context.l10n.latestPlans,
                  () => context.go('/plans'),
                ),
                const SizedBox(height: 16),
                _buildLatestPlans(),
                const SizedBox(height: 32),
                _buildSectionTitle(
                  context.l10n.recentBookings,
                  () => context.go('/bookings'),
                ),
                const SizedBox(height: 16),
                _buildRecentBookings(),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreetingSection() {
    final firstName = _fullName?.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.homeGreetingName(
            firstName ?? context.l10n.homeFriendName,
          ),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.homeSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }

  Widget _buildFamilyCard() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go('/profile'),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.family_restroom,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.familyCountLabel(_familyCount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      context.l10n.familyManagement,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCTACard() {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // TODO: Open Trip Preferences Flow
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.startPlanning,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.homeAiTeaser,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flight_takeoff,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(context.l10n.seeAll),
        ),
      ],
    );
  }

  Widget _buildLatestPlans() {
    return FutureBuilder<List<TripPlan>>(
      future: _tripRepo.getLatestPlans(currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _PlaceholderList();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              context.l10n.errorWithDetails(snapshot.error.toString()),
            ),
          );
        }

        final plans = snapshot.data ?? [];
        if (plans.isEmpty) {
          return _buildEmptyState(
            icon: Icons.map_outlined,
            message: context.l10n.emptyPlans,
            actionLabel: context.l10n.createPlan,
            onAction: () {},
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plans.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_city,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                title: Text(
                  plan.city,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  context.l10n.planSummary(
                    plan.days,
                    plan.budget.toStringAsFixed(0),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Navigate to details
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentBookings() {
    return FutureBuilder<List<Booking>>(
      future: _bookingRepo.getLatestBookings(currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _PlaceholderList();
        }
        if (snapshot.hasError) {
          return Center(child: Text(context.l10n.bookingsLoadError));
        }

        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.receipt_long_outlined,
            message: context.l10n.bookingsEmpty,
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final booking = bookings[index];
            final dateLabel = DateFormat.yMMMd(
              Localizations.localeOf(context).toString(),
            ).format(booking.createdAt.toLocal());

            return Card(
              child: ListTile(
                title: Text(
                  context.l10n.bookingItemTitle(booking.itemType),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(context.l10n.bookingPlacedOn(dateLabel)),
                trailing: _buildStatusBadge(booking.status),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String displayStatus;

    if (status.toLowerCase() == 'confirmed' ||
        status == context.l10n.statusConfirmed) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      displayStatus = context.l10n.statusConfirmed;
    } else if (status.toLowerCase() == 'cancelled' ||
        status == context.l10n.statusCancelled) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      displayStatus = context.l10n.statusCancelled;
    } else {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      displayStatus = context.l10n.statusPending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }
}

class _PlaceholderList extends StatelessWidget {
  const _PlaceholderList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
