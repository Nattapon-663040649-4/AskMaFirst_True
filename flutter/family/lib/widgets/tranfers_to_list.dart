import 'package:flutter/material.dart';
import '../screens/true_money_transfer_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class TransferToSection extends StatelessWidget {
  const TransferToSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'โอนไปยัง',
            style: GoogleFonts.prompt(
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.wallet),
          title: Text(
            'ทรูมันนี่',
            style: GoogleFonts.prompt(textStyle: TextStyle(fontSize: 20)),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TrueMoneyTransferScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_balance),
          title: Text(
            'บัญชีธนาคาร',
            style: GoogleFonts.prompt(textStyle: const TextStyle(fontSize: 20)),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        ),
      ],
    );
  }
}
