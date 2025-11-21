import 'package:flutter/material.dart';
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';
import 'package:family/widgets/button-start.dart';

class ParentProfile extends StatefulWidget {
  final String name;
  final String phone;

  ParentProfile({super.key, required this.name, required this.phone});

  @override
  State<ParentProfile> createState() => _ParentProfileState();
}

class _ParentProfileState extends State<ParentProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.wg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: MyColors.g),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("ผู้ปกครอง", style: FontStyle.H1),
        backgroundColor: MyColors.w,
        centerTitle: true,
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            return Container(
              margin: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text('โปรไฟล์', style: FontStyle.h1),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(20),
                    width: 400,
                    decoration: BoxDecoration(
                      color: MyColors.w,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {});
                              },
                              icon: Icon(Icons.edit_square),
                              color: MyColors.or1,
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: AssetImage(
                            'assets/images/user_placeholder.png',
                          ),
                          child: Icon(
                            Icons.person,
                            size: 90,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(widget.name, style: FontStyle.p3), //ชื่อผู้ปกครอง
                        const Divider(),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 20,
                                    color: MyColors.bg,
                                  ),
                                ],
                              ),
                              Column(children: [SizedBox(width: 5)]),
                              Column(
                                children: [
                                  Text(
                                    widget.phone, //เบอร์ผู้ปกครอง
                                    style: FontStyle.p3,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
