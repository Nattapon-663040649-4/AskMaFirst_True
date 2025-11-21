import 'package:flutter/material.dart';
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';

class SaveButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const SaveButtonWidget({super.key, required this.onPressed});

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
          backgroundColor: MyColors.or1,
          shadowColor: Colors.transparent,
        ),
        child: Text('บันทึก', style: FontStyle.btn2),
      ),
    );
  }
}
