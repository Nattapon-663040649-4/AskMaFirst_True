import 'package:flutter/material.dart';

class notibutt extends StatefulWidget {
  const notibutt({super.key});

  @override
  State<notibutt> createState() => _notibuttState();
}

class _notibuttState extends State<notibutt> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [FilledButton(onPressed: () {}, child: Text("press"))],
    );
  }
}
