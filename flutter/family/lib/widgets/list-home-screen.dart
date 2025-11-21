import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:family/styles/colors.dart';
import '../data/user_data.dart';

class WalletFeaturesSection extends StatefulWidget {
  const WalletFeaturesSection({super.key});

  @override
  State<WalletFeaturesSection> createState() => _WalletFeaturesSectionState();
}

class _WalletFeaturesSectionState extends State<WalletFeaturesSection> {
  double? balance;
  bool loading = true;
  Timer? _timer;

  final List<_FeatureItem> defaultItems = [
    _FeatureItem(
      title: "วอลเล็ต",
      value: "", // จะเติมข้อมูลตอน build
      icon: Icons.account_balance_wallet_outlined,
      isWalletBalance: true,
    ),
    _FeatureItem(
      title: "ทรูมันนี่คอยน์",
      value: "แลกคอยน์เป็นเงิน",
      icon: Icons.monetization_on_outlined,
    ),
    _FeatureItem(
      title: "Pay Next",
      value: "วงเงินพร้อมใช้",
      icon: Icons.credit_card,
    ),
    _FeatureItem(title: "ลงทุน", value: "ดูกองทุน", icon: Icons.trending_up),
    _FeatureItem(
      title: "1 บัญชี",
      value: "ดูข้อมูลบัญชี",
      icon: Icons.account_box_outlined,
    ),
    _FeatureItem(
      title: "เพิ่มบัตรเครดิต/เดบิต",
      value: "",
      icon: Icons.add,
      isCreditCard: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchLatestBalance();

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchLatestBalance();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchLatestBalance() async {
    final phone = UserDataStore.userData?['phone'];
    if (phone == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://172.20.10.14:3000/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          balance = data['balance']?.toDouble();
          loading = false;
        });
      } else {
        setState(() => loading = false);
        print("⚠️ ดึง balance ไม่ได้: ${response.body}");
      }
    } catch (e) {
      print("🚫 Error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = UserDataStore.userData;

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Me")),
        body: const Center(child: Text("⚠️ ยังไม่มีข้อมูลผู้ใช้")),
      );
    }

    // สร้าง list ของ item โดยเติมค่า balance ลงไป
    final items = defaultItems.map((item) {
      if (item.isWalletBalance) {
        return _FeatureItem(
          title: item.title,
          value: loading
              ? "กำลังโหลด..."
              : (balance?.toStringAsFixed(2) ?? "N/A"),
          icon: item.icon,
          isWalletBalance: item.isWalletBalance,
          isCreditCard: item.isCreditCard,
        );
      } else {
        return item;
      }
    }).toList();

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: item.isWalletBalance
                ? 250
                : item.isCreditCard
                ? 100
                : 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.isWalletBalance)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(item.icon, size: 22, color: Colors.black87),
                              const SizedBox(width: 6),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: MyColors.g,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: MyColors.bg,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // ใส่โค้ดเติมเงินตรงนี้ได้
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "เติมเงิน",
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                else ...[
                  Icon(item.icon, size: 22, color: Colors.black87),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.value.isNotEmpty)
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String value;
  final IconData icon;
  final bool isWalletBalance;
  final bool isCreditCard;

  _FeatureItem({
    required this.title,
    required this.value,
    required this.icon,
    this.isWalletBalance = false,
    this.isCreditCard = false,
  });
}
