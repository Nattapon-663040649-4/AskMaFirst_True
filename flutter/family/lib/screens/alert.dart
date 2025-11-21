import 'package:flutter/material.dart';
import 'package:family/notification/service.dart';

class Alertpage extends StatefulWidget {
  const Alertpage({super.key});

  @override
  State<Alertpage> createState() => _AlertpageState();
}

class _AlertpageState extends State<Alertpage> {
  @override
  void initState() {
    super.initState();
    NotificationService.parentContext = context;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Popup')),
      body: Center(
        child: ElevatedButton(
          child: const Text("ทดสอบแจ้งเตือน Pop-up"),
          onPressed: () {
            NotificationService.showTestPopup(); // ✅ เรียกใช้งานได้แล้ว
          },
        ),
      ),
    );
  }
}
