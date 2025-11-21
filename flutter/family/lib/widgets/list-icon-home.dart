import 'package:family/widgets/noti-icon.dart';// ถ้าไฟล์ของคุณชื่อ noti-icon.dart ให้เปลี่ยนเป็น noti_icon.dart จะปลอดภัยกว่า
import 'package:flutter/material.dart';

class IconMenuGrid extends StatelessWidget {
  const IconMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4, // 4 คอลัมภ์ -> จะเป็น 2 แถวเมื่อมี 8 ไอเท็ม
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      childAspectRatio: 0.9, // ปรับถ้าต้องการให้ไอเท็มสูง/กว้างต่างออกไป
      children: [
        _buildMenuItem(const TrueMoneyIcon(size: 32), 'TrueMoney Coin', onTap: () {}),
        _buildMenuItem(const Icon(Icons.card_giftcard, size: 28), 'Alipay+ Rewards', onTap: () {}),
        _buildMenuItem(const Icon(Icons.wifi, size: 28), 'ซื้อแพ็กเน็ตทรู', onTap: () {}),
        _buildMenuItem(const Icon(Icons.phone_android, size: 28), 'เติมเงินมือถือทรู', onTap: () {}),
        _buildMenuItem(const Icon(Icons.receipt_long, size: 28), 'บิลทรูทั้งหมด', onTap: () {}),
        _buildMenuItem(const Icon(Icons.apps, size: 28), 'บริการ App Store', onTap: () {}),
        _buildMenuItem(const Icon(Icons.security, size: 28), 'ประกันภัยทั้งหมด', onTap: () {}),
        _buildMenuItem(const Icon(Icons.arrow_forward_ios, size: 20), 'ดูทั้งหมด', onTap: () {}),
      ],
    );
  }

  Widget _buildMenuItem(Widget icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
