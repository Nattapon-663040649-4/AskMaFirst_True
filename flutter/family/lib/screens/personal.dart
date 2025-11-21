import 'package:flutter/material.dart';
import 'package:family/data/person.dart';

class PersonDetailPage extends StatefulWidget {
  final Person person;

  const PersonDetailPage({super.key, required this.person});

  @override
  State<PersonDetailPage> createState() => _PersonDetailPageState();
}

class _PersonDetailPageState extends State<PersonDetailPage> {
  final TextEditingController _controller = TextEditingController();
  double _sliderValue = 50;
  @override
  Widget build(BuildContext context) {
    final person = widget.person;
    return Scaffold(
      appBar: AppBar(title: Text("ข้อมูลของ ${person.name}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ชื่อ: ${person.name}", style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text("อายุ: ${person.age} ปี"),
            Text("อาชีพ: ${person.role.title}"),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 1000,
              divisions: 100,
              label: _sliderValue.round().toString(),
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                  _controller.text = value.toStringAsFixed(0);
                });
              },
            ),
            Text("จำนวนเงินที่จำกัด: ${_sliderValue.round()} บาท"),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null && parsed >= 0 && parsed <= 1000) {
                  setState(() {
                    _sliderValue = double.tryParse(value) ?? _sliderValue;
                  });
                }
              },
            ),
            SizedBox(height: 10),
            FilledButton(
              onPressed: () {
                final savedValue =
                    double.tryParse(_controller.text) ?? _sliderValue;
                person.limited_money = savedValue.round();
                print(person.limited_money);
              },
              child: Text("บันทึก"),
            ),

            // เพิ่มรูปภาพหรือข้อมูลอื่น ๆ ได้ที่นี่
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.person.limited_money
        .toDouble(); // โหลดค่าที่เคยบันทึกไว้
    _controller.text = _sliderValue.toStringAsFixed(0); // ใส่ค่าลง textfield
  }
}
