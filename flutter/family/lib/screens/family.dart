import 'package:family/screens/Familydata.dart';
import 'package:family/screens/me.dart';
import 'package:family/screens/transferpage.dart';
import 'package:flutter/material.dart';

class MyFamily extends StatefulWidget {
  const MyFamily({super.key});

  @override
  State<MyFamily> createState() => _MyFamilyState();
}

class _MyFamilyState extends State<MyFamily> {
  int num = 5;

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("ครอบครัวของฉัน"),
    ),
    backgroundColor: Colors.white, // ✅ เพิ่มสีพื้นหลัง
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton(
            onPressed: () {
              navigateToPage(PersonData());
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset("assets/images/askma.png", width: 50, height: 50),
                Text(
                  "ครอบครัวของฉัน",
                  style: TextStyle(fontSize: 30, color: Colors.black),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              navigateToPage(Me());
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset("assets/images/askma.png", width: 50, height: 50),
                Text(
                  "ฉัน",
                  style: TextStyle(fontSize: 30, color: Colors.black),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              navigateToPage(TransferPage());
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset("assets/images/p3.png", width: 50, height: 50),
                Text(
                  "โอนเงิน",
                  style: TextStyle(fontSize: 30, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  void navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => page),
    );
  }
}
