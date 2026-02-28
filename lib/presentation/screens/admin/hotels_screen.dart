import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../localization/app_localizations_ext.dart';

class HotelsScreen extends StatelessWidget {
  const HotelsScreen({super.key});

  static const String routeName = '/hotels';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.hotelsTitle)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('Hotels').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(context.l10n.hotelsLoadError));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text(context.l10n.hotelsNoData));
          }

          final hotels = snapshot.data!.docs;

          if (hotels.isEmpty) {
            return Center(child: Text(context.l10n.hotelsEmpty));
          }

          return ListView.separated(
            itemCount: hotels.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = hotels[index].data();

              final name = (data['name'] ?? '').toString().trim();
              final location = (data['location'] ?? '').toString().trim();

              return ListTile(
                title: Text(
                  name.isEmpty ? context.l10n.hotelNameUnknown : name,
                ),
                subtitle: Text(
                  location.isEmpty
                      ? context.l10n.hotelLocationUnknown
                      : location,
                ),
                leading: const Icon(Icons.hotel),
              );
            },
          );
        },
      ),
    );
  }
}
