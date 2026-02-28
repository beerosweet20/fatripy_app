import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelsScreen extends StatelessWidget {
  const HotelsScreen({super.key});

  static const String routeName = '/hotels';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الفنادق')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('Hotels').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ في تحميل البيانات'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('لا توجد بيانات حالياً'));
          }

          final hotels = snapshot.data!.docs;

          if (hotels.isEmpty) {
            return const Center(child: Text('لا توجد فنادق لعرضها'));
          }

          return ListView.separated(
            itemCount: hotels.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = hotels[index].data();

              final name = (data['name'] ?? '').toString().trim();
              final location = (data['location'] ?? '').toString().trim();

              return ListTile(
                title: Text(name.isEmpty ? 'اسم غير متوفر' : name),
                subtitle: Text(location.isEmpty ? 'موقع غير معروف' : location),
                leading: const Icon(Icons.hotel),
              );
            },
          );
        },
      ),
    );
  }
}
