// lib/screens/me.dart
import 'dart:async';
import 'dart:convert';
import 'package:family/notification/service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/user_data.dart';
import 'alert.dart';
import 'start.dart';
import 'transferpage.dart';

class Me extends StatefulWidget {
  const Me({super.key});

  @override
  State<Me> createState() => _MeState();
}

class _MeState extends State<Me> {
  double? balance;
  bool loading = true;
  Timer? _timer;

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
  void initState() {
    super.initState();
    fetchLatestBalance();

    // ตั้งค่า context ให้ NotificationService ใช้
    NotificationService.parentContext = context;

    // ตั้ง timer ให้ fetch ทุก 10 วินาที
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchLatestBalance();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = UserDataStore.userData;

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Me")),
        body: Center(child: Text("⚠️ ยังไม่มีข้อมูลผู้ใช้")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Me")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("👤 Name: ${userData['name']}"),
                  Text("📞 Phone: ${userData['phone']}"),
                  SizedBox(height: 20),
                  Text("💰 Balance (Live): ${balance ?? 'N/A'}"),
                  SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StartUsingPage(),
                        ),
                      );
                    },
                    child: Text("Family"),
                  ),
                  SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TransferPage()),
                      );
                    },
                    child: Text("โอนเงิน"),
                  ),
                  SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Alertpage()),
                      );
                    },
                    child: Text("test"),
                  ),
                ],
              ),
      ),
    );
  }
}
