import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelsScreen extends StatelessWidget {
  const HotelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الفنادق')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Hotels').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ في تحميل البيانات'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final hotels = snapshot.data!.docs;

          print('عدد الفنادق: ${hotels.length}');

          return ListView.builder(
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final data = hotels[index].data() as Map<String, dynamic>;
              print(data);

              return ListTile(
                title: Text(data['name'] ?? 'اسم غير متوفر'),
                subtitle: Text(data['location'] ?? 'موقع غير معروف'),
              );
            },
          );
        },
      ),
    );
  }
}
