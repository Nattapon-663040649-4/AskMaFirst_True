import 'dart:convert';
import 'package:family/screens/notification-page.dart';
import 'package:family/widgets/addnum-text-field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';
import 'package:family/screens/parent-profile.dart';
import 'package:family/screens/child-profile.dart';
import '../data/user_data.dart';

class ListMem extends StatefulWidget {
  const ListMem({super.key});

  @override
  State<ListMem> createState() => _ListMemState();
}

class _ListMemState extends State<ListMem> {
  List<dynamic> parents = [];
  List<dynamic> children = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    final phone = UserDataStore.userData?['phone'];
    if (phone == null) {
      print("⚠️ ไม่มีหมายเลขโทรศัพท์ใน userData");
      setState(() => isLoading = false);
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('http://172.20.10.14:3000/family-members'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          parents = data['parents'] ?? [];
          children = data['children'] ?? [];
          isLoading = false;
        });
      } else {
        print("❌ Response error: ${res.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("🚨 API call failed: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (parents.isEmpty && children.isEmpty) {
      return const Center(child: Text("ไม่มีสมาชิกในครอบครัว"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parents.isNotEmpty)
          _buildSection("ผู้ปกครอง", parents, isParent: true),
        if (children.isNotEmpty)
          _buildSection("บุตรหลาน", children, isParent: false),
      ],
    );
  }

  Widget _buildSection(
    String title,
    List<dynamic> members, {
    required bool isParent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.group, color: MyColors.or1),
                  const SizedBox(width: 6),
                  Text(title, style: FontStyle.p7),
                ],
              ),

              IconButton(
                icon: const Icon(Icons.add, color: MyColors.or1),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const NotiAddNum(),
                  );
                },
              ),
            ],
          ),
        ),
        ...members.map((user) => _buildMemberTile(user, isParent)).toList(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> user, bool isParent) {
    final name = user['name'] ?? 'ไม่ระบุชื่อ';
    final phone = user['phone'];
    final Widget page = isParent
        ? ParentProfile(name: name, phone: phone)
        : ChildProfile(name: name, phone: phone);

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => page));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: MyColors.w,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: FontStyle.p7)),
            const Icon(Icons.arrow_forward_ios, size: 16, color: MyColors.bg),
          ],
        ),
      ),
    );
  }
}
