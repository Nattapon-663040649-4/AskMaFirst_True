import 'package:family/screens/personal.dart';
import 'package:flutter/material.dart';
import 'package:family/data/person.dart';

class PersonData extends StatefulWidget {
  const PersonData({super.key});

  @override
  State<PersonData> createState() => _PersonDataState();
}

class _PersonDataState extends State<PersonData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("สมาชิคครอบครัว")),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final person = data[index];

          final content = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person.name, style: const TextStyle(fontSize: 30)),
                  Text("อายุ ${person.age} ปี , อาชีพ ${person.role.title}"),
                ],
              ),
              Image.asset("assets/images/p3.png", width: 70, height: 70),
            ],
          );

          // ถ้าเป็นผู้ปกครอง (parent) ไม่ให้กด
          if (person.role == Role.parent) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: content,
            );
          }

          // ถ้าไม่ใช่ (เช่น child) ให้กดเข้าได้
          return TextButton(
            onPressed: () {
              personalpage(person);
            },
            child: content,
          );
        },
      ),
    );
  }

  void personalpage(Person person) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PersonDetailPage(person: person)),
    );
  }
}
