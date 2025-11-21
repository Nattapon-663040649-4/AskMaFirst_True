import 'dart:convert';
import 'package:family/data/user_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';
import 'package:family/widgets/save-button.dart';
import 'package:family/widgets/statement-dialog.dart';

class ChildProfile extends StatefulWidget {
  final String name;
  final String phone;

  const ChildProfile({super.key, required this.name, required this.phone});

  @override
  State<ChildProfile> createState() => _ChildProfileState();
}

class _ChildProfileState extends State<ChildProfile> {
  Future<void> updateLimitedMoney() async {
    try {
      final res = await http.post(
        Uri.parse('http://172.20.10.14:3000/update-user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': widget.phone,
          'limited_money': _sliderValue,
        }),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('อัปเดตวงเงินสำเร็จ ✅')));
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  final TextEditingController _controller = TextEditingController();
  double _sliderValue = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserLimitedMoney();
  }

  Future<void> fetchUserLimitedMoney() async {
    try {
      final res = await http.post(
        Uri.parse('http://172.20.10.14:3000/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': widget.phone}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final limitedMoney = (data['limited_money'] ?? 0).toDouble();

        setState(() {
          _sliderValue = limitedMoney;
          _controller.text = limitedMoney.toStringAsFixed(0);
          isLoading = false;
        });
      } else {
        print("❌ Error: ${res.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("🚨 Failed to fetch user: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = UserDataStore.userData?['role'];
    final isParent = role == 'parent';

    return Scaffold(
      backgroundColor: MyColors.wg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: MyColors.g),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("บุตรหลาน", style: FontStyle.H1),
        backgroundColor: MyColors.w,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text('โปรไฟล์', style: FontStyle.h1),
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        width: 400,
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
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isParent)
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => StatementDialog(
                                          phone: widget.phone,
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.my_library_books_outlined,
                                    ),
                                    color: MyColors.or1,
                                  ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: const AssetImage(
                                'assets/images/user_placeholder.png',
                              ),
                              child: Icon(
                                Icons.person,
                                size: 90,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(widget.name, style: FontStyle.p3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 20,
                                  color: MyColors.bg,
                                ),
                                const SizedBox(width: 5),
                                Text(widget.phone, style: FontStyle.p7),
                              ],
                            ),
                            const Divider(),

                            /// ✅ เงื่อนไขเฉพาะ parent เท่านั้น
                            if (isParent) ...[
                              const Text('จำกัดวงเงิน', style: FontStyle.p6),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: MyColors.or1,
                                  inactiveTrackColor: MyColors.or2,
                                  trackHeight: 6.0,
                                  thumbColor: MyColors.wg,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 10.0,
                                  ),
                                  overlayColor: MyColors.or1.withAlpha(32),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 20.0,
                                  ),
                                  valueIndicatorColor: MyColors.or1,
                                  valueIndicatorTextStyle: FontStyle.p8,
                                ),
                                child: Slider(
                                  value: _sliderValue,
                                  min: 0,
                                  max: 5000,
                                  divisions: 100,
                                  label: '${_sliderValue.round()} บาท',
                                  onChanged: (value) {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      _sliderValue = value;
                                      _controller.text = value.toStringAsFixed(
                                        0,
                                      );
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  style: FontStyle.p5,
                                  controller: _controller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'กำหนดวงเงินเอง',
                                    labelStyle: FontStyle.p4,
                                  ),
                                  onChanged: (value) {
                                    final parsed = double.tryParse(
                                      value.trim(),
                                    );
                                    if (parsed != null) {
                                      final clamped = parsed
                                          .clamp(0, 5000)
                                          .toDouble();
                                      setState(() {
                                        _sliderValue = clamped;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 30),
                              SaveButtonWidget(
                                onPressed: () async {
                                  await updateLimitedMoney();
                                },
                              ),
                            ] else ...[
                              const SizedBox(height: 20),
                              const Text(
                                "🔒 คุณไม่มีสิทธิ์ในการจัดการวงเงินของผู้ใช้นี้",
                                style: FontStyle.p4,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                            ],

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
