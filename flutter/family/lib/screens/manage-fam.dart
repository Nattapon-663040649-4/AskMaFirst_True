import 'package:family/widgets/statement-dialog.dart';
import 'package:family/widgets/list-member.dart';
import 'package:flutter/material.dart';
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';

import 'package:family/screens/parent-profile.dart';
import 'package:family/screens/child-profile.dart';

class ManageFamPage extends StatelessWidget {
  const ManageFamPage({super.key});

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.wg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MyColors.g),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("ครอบครัว", style: FontStyle.H1),
        backgroundColor: MyColors.w,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
            top: 20,
          ), // Added this to move content up
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Changed from center to start
            children: [
              Image.asset("assets/icons/askma.png", width: 150, height: 150),
              const SizedBox(height: 20),
              const Text(
                'เข้าถึงรายชื่อสมาชิกและการแชร์ได้ สามารถจัดการ ตรวจสอบหรือติดตามการใช้จ่ายโอนเงินของบัญชีบุตรหลานได้',
                style: FontStyle.p2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: MyColors.w,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListMem(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
