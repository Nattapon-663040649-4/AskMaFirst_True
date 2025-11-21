import 'package:flutter/material.dart';
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';

//klk;
class ButtonStartWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const ButtonStartWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.or1,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(300, 55),
          backgroundColor: MyColors.or1,
          shadowColor: Colors.transparent,
        ),
        child: Text('เริ่มต้นการใช้งาน', style: FontStyle.btn1),
      ),
    );
  }
}
