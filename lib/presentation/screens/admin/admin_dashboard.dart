import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/firebase/auth_service.dart';
import '../../../data/repositories/admin_content_repository.dart';
import '../../localization/app_localizations_ext.dart';
import 'admin_bottom_nav.dart';
import 'admin_design.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminContentRepository _adminRepo = AdminContentRepository();
  final AuthService _authService = AuthService();
  late final Future<bool> _isAdminFuture;
  late Future<AdminDashboardAnalytics> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _isAdminFuture = _authService.isAdmin();
    _analyticsFuture = _adminRepo.fetchDashboardAnalytics();
  }

  void _refreshStats() {
    setState(() {
      _analyticsFuture = _adminRepo.fetchDashboardAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<bool>(
      future: _isAdminFuture,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final isAdmin = snapshot.data == true;

        if (loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!isAdmin) {
          return Scaffold(
            appBar: adminAppBar(context, title: l10n.adminDashboardTitle),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 44),
                    const SizedBox(height: 12),
                    Text(l10n.adminNoAccess, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/profile'),
                      child: Text(l10n.adminBackToProfile),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AdminPalette.background,
          appBar: adminAppBar(
            context,
            title: l10n.adminDashboardTitle,
            actions: [
              IconButton(
                onPressed: _refreshStats,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: AdminDecoratedBody(
            child: FutureBuilder<AdminDashboardAnalytics>(
              future: _analyticsFuture,
              builder: (context, analyticsSnapshot) {
                if (analyticsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (analyticsSnapshot.hasError) {
                  return adminEmptyState(
                    context: context,
                    icon: Icons.error_outline,
                    message: l10n.errorWithDetails(
                      analyticsSnapshot.error.toString(),
                    ),
                  );
                }

                final analytics =
                    analyticsSnapshot.data ??
                    AdminDashboardAnalytics(
                      stats: const AdminStats(
                        users: 0,
                        tripPlans: 0,
                        bookings: 0,
                        hotels: 0,
                        activities: 0,
                      ),
                      bookingStatusCounts: const {
                        'pending': 0,
                        'confirmed': 0,
                        'cancelled': 0,
                        'other': 0,
                      },
                      topCities: const {},
                      topSelectedPlanTitles: const {},
                      selectedPlans: 0,
                      averageAiElapsedMs: 0,
                      slowAiResponses: 0,
                    );
                final stats = analytics.stats;

                final bookingStatusTotal = analytics.bookingStatusCounts.values
                    .fold<int>(0, (sum, value) => sum + value);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  children: [
                    Text(
                      l10n.adminStatsTitle,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AdminPalette.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _StatCard(
                          label: l10n.profileAdminUsers,
                          value: stats.users,
                          icon: Icons.people_outline,
                          accentIndex: 0,
                        ),
                        _StatCard(
                          label: l10n.profileAdminTripPlans,
                          value: stats.tripPlans,
                          icon: Icons.route_outlined,
                          accentIndex: 1,
                        ),
                        _StatCard(
                          label: l10n.adminStatBookings,
                          value: stats.bookings,
                          icon: Icons.receipt_long_outlined,
                          accentIndex: 2,
                        ),
                        _StatCard(
                          label: l10n.adminStatHotels,
                          value: stats.hotels,
                          icon: Icons.hotel_outlined,
                          accentIndex: 3,
                        ),
                        _StatCard(
                          label: l10n.adminStatActivities,
                          value: stats.activities,
                          icon: Icons.local_activity_outlined,
                          accentIndex: 4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      l10n.adminAnalyticsTitle,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AdminPalette.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AnalyticsCard(
                      title: l10n.adminAnalyticsBookingStatus,
                      icon: Icons.query_stats_outlined,
                      accentIndex: 2,
                      child: Column(
                        children: [
                          _MetricRow(
                            label: l10n.statusPending,
                            value:
                                analytics.bookingStatusCounts['pending'] ?? 0,
                            total: bookingStatusTotal,
                            accentIndex: 0,
                          ),
                          _MetricRow(
                            label: l10n.statusConfirmed,
                            value:
                                analytics.bookingStatusCounts['confirmed'] ?? 0,
                            total: bookingStatusTotal,
                            accentIndex: 3,
                          ),
                          _MetricRow(
                            label: l10n.statusCancelled,
                            value:
                                analytics.bookingStatusCounts['cancelled'] ?? 0,
                            total: bookingStatusTotal,
                            accentIndex: 5,
                          ),
                          _MetricRow(
                            label: l10n.adminStatusOther,
                            value: analytics.bookingStatusCounts['other'] ?? 0,
                            total: bookingStatusTotal,
                            accentIndex: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AnalyticsCard(
                      title: l10n.adminAnalyticsTopCities,
                      icon: Icons.location_city_outlined,
                      accentIndex: 1,
                      child: _SimpleRankList(
                        items: analytics.topCities,
                        emptyText: l10n.adminNoAnalyticsData,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AnalyticsCard(
                      title: l10n.adminAnalyticsSelectedPlans,
                      icon: Icons.checklist_rtl_outlined,
                      accentIndex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.adminAnalyticsSelectedPlansCount(
                              analytics.selectedPlans,
                            ),
                            style: const TextStyle(
                              color: AdminPalette.navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _SimpleRankList(
                            items: analytics.topSelectedPlanTitles,
                            emptyText: l10n.adminNoAnalyticsData,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AnalyticsCard(
                      title: l10n.adminAnalyticsAiPerformance,
                      icon: Icons.speed_outlined,
                      accentIndex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.adminAnalyticsAverageLatency(
                              analytics.averageAiElapsedMs.toStringAsFixed(0),
                            ),
                            style: const TextStyle(
                              color: AdminPalette.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.adminAnalyticsSlowResponses(
                              analytics.slowAiResponses,
                            ),
                            style: const TextStyle(
                              color: AdminPalette.navy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Divider(height: 1, color: AdminPalette.blush),
                          const SizedBox(height: 6),
                          Text(
                            l10n.adminAnalyticsHighLatencyNote,
                            style: const TextStyle(
                              color: AdminPalette.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.adminContentManagement,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AdminPalette.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AdminCard(
                      icon: Icons.hotel_outlined,
                      title: l10n.adminTabHotels,
                      subtitle: l10n.adminManageHotelsSubtitle,
                      accentIndex: 0,
                      onTap: () => context.go('/admin/hotels'),
                    ),
                    const SizedBox(height: 10),
                    _AdminCard(
                      icon: Icons.local_activity_outlined,
                      title: l10n.adminTabActivities,
                      subtitle: l10n.adminManageActivitiesSubtitle,
                      accentIndex: 2,
                      onTap: () => context.go('/admin/activities'),
                    ),
                    const SizedBox(height: 10),
                    _AdminCard(
                      icon: Icons.event_outlined,
                      title: l10n.plansLabelEvents,
                      subtitle: l10n.adminManageEventsSubtitle,
                      accentIndex: 5,
                      onTap: () => context.go('/admin/events'),
                    ),
                    const SizedBox(height: 10),
                    _AdminCard(
                      icon: Icons.receipt_long_outlined,
                      title: l10n.adminViewBookings,
                      subtitle: l10n.adminViewBookingsSubtitle,
                      accentIndex: 3,
                      onTap: () => context.go('/admin/bookings'),
                    ),
                    const SizedBox(height: 10),
                    _AdminCard(
                      icon: Icons.settings_outlined,
                      title: l10n.adminSettingsTitle,
                      subtitle: l10n.adminSettingsSubtitle,
                      accentIndex: 4,
                      onTap: () => context.go('/admin/settings'),
                    ),
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar: const AdminBottomNav(
            current: AdminNavTab.dashboard,
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final int accentIndex;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: adminCardShape(accentIndex: accentIndex),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AdminPalette.accentAt(accentIndex)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AdminPalette.text,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminPalette.navy,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int accentIndex;
  final Widget child;

  const _AnalyticsCard({
    required this.title,
    required this.icon,
    required this.accentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: adminCardShape(accentIndex: accentIndex),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AdminPalette.accentAt(accentIndex)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AdminPalette.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final int accentIndex;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.total,
    required this.accentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : value / math.max(total, 1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AdminPalette.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  color: AdminPalette.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: ratio,
              backgroundColor: AdminPalette.blush.withValues(alpha: 0.32),
              color: AdminPalette.accentAt(accentIndex),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleRankList extends StatelessWidget {
  final Map<String, int> items;
  final String emptyText;

  const _SimpleRankList({required this.items, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        emptyText,
        style: const TextStyle(color: AdminPalette.mutedText),
      );
    }

    final entries = items.entries.toList();
    return Column(
      children: List.generate(entries.length, (index) {
        final entry = entries[index];
        return Padding(
          padding: EdgeInsets.only(bottom: index == entries.length - 1 ? 0 : 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AdminPalette.accentAt(
                  index,
                ).withValues(alpha: 0.18),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: AdminPalette.accentAt(index),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    color: AdminPalette.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.value}',
                style: const TextStyle(
                  color: AdminPalette.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int accentIndex;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: adminCardShape(accentIndex: accentIndex),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AdminPalette.accentAt(
            accentIndex,
          ).withValues(alpha: 0.16),
          child: Icon(icon, color: AdminPalette.accentAt(accentIndex)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AdminPalette.text,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AdminPalette.navy),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AdminPalette.accentAt(accentIndex),
        ),
        onTap: onTap,
      ),
    );
  }
}
