import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/trip_repository.dart';
import '../../../domain/entities/trip_plan.dart';
import '../../localization/app_localizations_ext.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final TripRepository _tripRepo = TripRepository();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return Scaffold(body: Center(child: Text(context.l10n.errorPleaseLogin)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navPlans)),
      body: FutureBuilder<List<TripPlan>>(
        future: _tripRepo.getAllPlans(_uid),
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

          final plans = snapshot.data ?? [];
          if (plans.isEmpty) {
            return Center(child: Text(context.l10n.emptyPlans));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: const Icon(Icons.map, size: 36),
                  title: Text(
                    plan.city,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    context.l10n.planListSubtitle(
                      plan.budget.toStringAsFixed(0),
                      plan.status,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to details
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open Create Plan
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
