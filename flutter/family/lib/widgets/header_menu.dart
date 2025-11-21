import 'package:family/screens/transfer-home.dart';
import 'package:family/screens/true_money_transfer_screen.dart';
import 'package:flutter/material.dart';

class HeaderMenu extends StatelessWidget {
  const HeaderMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MenuItem(
            icon: Icons.sync_alt,
            label: 'โอนเงิน',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TransferHome()),
              );
            },
          ),
          const MenuItem(icon: Icons.call_received, label: 'รับเงิน'),
          const MenuItem(icon: Icons.qr_code_scanner, label: 'สแกน'),
          const MenuItem(icon: Icons.receipt_long, label: 'จ่ายเงิน'),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const MenuItem({
    required this.icon,
    required this.label,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // กำหนดสีขาวให้ icon กับ text แม้ปุ่มจะ disable
    final iconColor = Colors.white;
    final textColor = Colors.white;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: iconColor, // ปรับตรงนี้ก็ได้
        padding: EdgeInsets.zero,
        minimumSize: const Size(60, 80),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

