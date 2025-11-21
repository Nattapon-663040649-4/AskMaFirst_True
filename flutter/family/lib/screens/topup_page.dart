import 'package:flutter/material.dart';

class TopUpPage extends StatelessWidget {
  const TopUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // <-- เพิ่มบรรทัดนี้
        title: const Text(
          'เติมเงิน',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(child: Text('หน้าจอเติมเงิน')),
    );
  }
}
