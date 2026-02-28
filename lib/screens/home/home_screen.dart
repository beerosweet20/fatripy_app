import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/repositories/trip_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/models/trip_plan.dart';
import '../../../data/models/booking.dart';

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
  int _familyCount = 1; // Default to 1 (the user)

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
          // Ideally fetch family count from the familyGroups collection here.
          _familyCount = 1;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text("Please login to view dashboard"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                context.go('/profile'), // Simplified routing to profile tab
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Add basic responsive padding
          final isWide = constraints.maxWidth > 600;
          final padding = isWide ? constraints.maxWidth * 0.1 : 16.0;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Re-builds FutureBuilders
              await _loadDashboardData();
            },
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
              children: [
                _buildGreetingSection(),
                const SizedBox(height: 24),

                // Responsive Grid for Top Cards
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
                  AppStrings.latestPlans,
                  () => context.go('/plans'),
                ),
                const SizedBox(height: 16),
                _buildLatestPlans(),

                const SizedBox(height: 32),
                _buildSectionTitle(
                  AppStrings.recentBookings,
                  () => context.go('/bookings'),
                ),
                const SizedBox(height: 16),
                _buildRecentBookings(),

                const SizedBox(height: 48), // Padding at bottom
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.homeGreeting}، ${_fullName?.split(' ').first ?? 'يا صديق'}!',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.homeSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
        onTap: () => context.go('/profile'), // Navigate to family management
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                      '$_familyCount أفراد',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppStrings.familyManagement,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCTACard() {
    return Card(
      color: Theme.of(context).colorScheme.primary, // Navy emphasis
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
                      AppStrings.startPlanning,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ذكاء اصطناعي يجهز لك رحلتك',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary, // Pink Accent
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('عرض الكل')),
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
            child: Text('حدث خطأ أثناء تحميل الخطط\n${snapshot.error}'),
          );
        }

        final plans = snapshot.data ?? [];
        if (plans.isEmpty) {
          return _buildEmptyState(
            icon: Icons.map_outlined,
            message: AppStrings.emptyPlans,
            actionLabel: AppStrings.createPlan,
            onAction: () {}, // TODO: open preferences
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.15),
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
                  '${plan.days} أيام • ${plan.budget.toStringAsFixed(0)} ريال',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to details
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
          return const Center(child: Text('حدث خطأ أثناء تحميل الحجوزات'));
        }

        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.receipt_long_outlined,
            message: 'لا توجد حجوزات حديثة.',
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              child: ListTile(
                title: Text(
                  'حجز ${booking.itemType}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'تاريخ: ${booking.createdAt.toLocal().toString().split(' ')[0]}',
                ),
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

    if (status.toLowerCase() == 'confirmed' || status == 'مؤكد') {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      displayStatus = AppStrings.statusConfirmed;
    } else if (status.toLowerCase() == 'cancelled' || status == 'ملغي') {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      displayStatus = AppStrings.statusCancelled;
    } else {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      displayStatus = AppStrings.statusPending;
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
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
        // "Quiet luxury" empty state design
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
              color: Theme.of(context).dividerColor.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
