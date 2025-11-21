import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentTransferSection extends StatelessWidget {
  const RecentTransferSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'รายการโอนล่าสุด',
              style: GoogleFonts.prompt(
                textStyle: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            RecentTransferItem(
              name: 'ตี๋น้อย แปดแปด***',
              phone: '080-***-8888',
              image: Icons.person,
            ),
            RecentTransferItem(
              name: 'สมชาย สมาน***',
              phone: '090-***-1234',
              image: Icons.face,
            ),
          ],
        ),
      ],
    );
  }
}

class RecentTransferItem extends StatelessWidget {
  final String name;
  final String phone;
  final IconData image;

  const RecentTransferItem({
    required this.name,
    required this.phone,
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          CircleAvatar(
            child: Icon(image),
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(height: 8),
          Text(name, overflow: TextOverflow.ellipsis),
          Text(phone, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
