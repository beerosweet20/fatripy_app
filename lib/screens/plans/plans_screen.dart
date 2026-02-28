import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_strings.dart';
import '../../data/repositories/trip_repository.dart';
import '../../data/models/trip_plan.dart';

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
      return const Scaffold(body: Center(child: Text("Please login")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navPlans)),
      body: FutureBuilder<List<TripPlan>>(
        future: _tripRepo.getAllPlans(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final plans = snapshot.data ?? [];
          if (plans.isEmpty) {
            return const Center(child: Text(AppStrings.emptyPlans));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                  subtitle: Text('Budget: \$${plan.budget} • ${plan.status}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to details
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
