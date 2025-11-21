import 'package:family/screens/manage-fam.dart';
import 'package:flutter/material.dart';
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';
import 'package:family/widgets/button-start.dart';

class StartUsingPage extends StatelessWidget {
  const StartUsingPage({super.key});

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
      body: Center(
        child: Builder(
          builder: (context) {
            return Container(
              margin: const EdgeInsets.all(25),
              child: Column(
                children: [
                  Container(
                    child: Image.asset(
                      "assets/icons/askma.png",
                      width: 230,
                      height: 230,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ยินดีต้อนรับสู่ AskMaFirst',
                          style: FontStyle.p1,
                        ),
                        const Text(
                          'ฟีเจอร์เพิ่มความปลอดภัยการใช้จ่าย',
                          style: FontStyle.p2,
                        ),
                        const Text(
                          'แอพ TrueMoney ในครอบครัว',
                          style: FontStyle.p2,
                        ),
                        const SizedBox(height: 10),
                        const Text('วิธีการใช้งาน', style: FontStyle.p1),
                        const Text(
                          '1.เพิ่มบัญชีผู้ปกครอง',
                          style: FontStyle.p2,
                        ),
                        const Text('2.เพิ่มบัญชีลูก', style: FontStyle.p2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ButtonStartWidget(
                    onPressed: () {
                      navigateToPage(context, const ManageFamPage());
                    },
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

void navigateToPage(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (ctx) => page));
}
