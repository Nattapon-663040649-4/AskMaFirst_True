import 'package:flutter/material.dart';
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';

class NotiAddNum extends StatefulWidget {
  const NotiAddNum({super.key});

  @override
  State<NotiAddNum> createState() => _NotiAddNumState();
}

class _NotiAddNumState extends State<NotiAddNum> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('กรอกข้อมูลเพิ่มสมาชิก', style: FontStyle.p6),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            focusColor: MyColors.or1,
            labelText: 'เบอร์ทรูมันนี่',
            labelStyle: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'กรุณากรอกเบอร์ทรูมันนี่';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('ยกเลิก', style: FontStyle.p2),
        ),
        ElevatedButton(
          onPressed: _onSubmit,
          child: const Text('ตกลง', style: FontStyle.p2),
        ),
      ],
    );
  }
}
