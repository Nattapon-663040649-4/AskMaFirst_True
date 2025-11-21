import 'package:family/widgets/list-notification.dart';
import 'package:flutter/material.dart';
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';
import 'package:family/notification/service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int selectedIndex = 0;
  bool hasNotification = true;
  bool hasPrivilege = true;
  bool hasNews = true;

  // แจ้งเตือน dot แดง สำหรับคำขอกับการโอนเงินเข้า เวลาที่กดเข้าดู ตุ่มแดงๆจะหายกลายเป็น false
  void handleTabChange(int index) {
    setState(() {
      selectedIndex = index;

      if (index == 1) hasNotification = false;
      if (index == 2) hasPrivilege = false;
      if (index == 3) hasNews = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // เซ็ต context ให้ NotificationService ใช้แสดง dialog / navigator ได้
    NotificationService.parentContext = context;
    // เรียก initialize ฟัง notification
  }

  @override
  void dispose() {
    // เคลียร์ context เมื่อหน้าไม่แสดงแล้ว
    NotificationService.parentContext = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> titles = [
      "ทั้งหมด",
      "แจ้งเตือน",
      "สิทธิพิเศษ",
      "ข่าวสาร",
    ];

    return Scaffold(
      backgroundColor: MyColors.w,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MyColors.g),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("ข้อความ", style: FontStyle.p6),
        backgroundColor: MyColors.w,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(titles.length, (index) {
                final bool isSelected = selectedIndex == index;
                final bool showDot = (index == 1 && hasNotification);

                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 0),
                                ),
                              ]
                            : [],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => handleTabChange(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            titles[index],
                            style: FontStyle.p5.copyWith(
                              color: isSelected ? MyColors.or1 : MyColors.g,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // แสดง dot สีแดงถ้ามีรายการใหม่
                    if (showDot)
                      const Positioned(
                        right: 4,
                        top: 4,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.red,
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            // <-- แก้ไขตรงนี้ เพิ่ม Expanded ห่อ ListNotification
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: MyColors.wg),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ส่วน ListNotification แสดงรายการแจ้งเตือนตาม selected tab
                  Expanded(child: ListNotification(filterIndex: selectedIndex)),
                  const SizedBox(height: 20),

                  // ปุ่มทดสอบแจ้งเตือน Popup จาก NotificationService
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
