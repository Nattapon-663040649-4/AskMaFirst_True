import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';

class StatementDialog extends StatefulWidget {
  final String phone;

  const StatementDialog({super.key, required this.phone});

  @override
  State<StatementDialog> createState() => _StatementDialogState();
}

class _StatementDialogState extends State<StatementDialog> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistoryFromApi(widget.phone);
  }

  Future<List<Map<String, dynamic>>> _fetchHistoryFromApi(String phone) async {
    try {
      final res = await http.post(
        Uri.parse('http://172.20.10.14:3000/history'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (res.statusCode == 200) {
        final List<dynamic> rawHistory = jsonDecode(res.body);

        return rawHistory.map<Map<String, dynamic>>((item) {
          final ts = item['timestamp'];
          DateTime timestamp;

          if (ts is String) {
            timestamp =
                DateTime.tryParse(ts)?.toLocal() ??
                DateTime.fromMillisecondsSinceEpoch(0);
          } else if (ts is Map && ts.containsKey('_seconds')) {
            timestamp = DateTime.fromMillisecondsSinceEpoch(
              ts['_seconds'] * 1000,
            ).toLocal();
          } else {
            timestamp = DateTime.fromMillisecondsSinceEpoch(0);
          }

          return {
            'amount': (item['amount'] as num).toDouble(),
            'from': item['from'],
            'to': item['to'],
            'type': item['type'],
            'timestamp': timestamp,
          };
        }).toList();
      } else {
        print("❌ Error: ${res.body}");
        return [];
      }
    } catch (e) {
      print("🚨 Failed to fetch history: $e");
      return [];
    }
  }

  String _formatDateTime(DateTime dt) {
    final formatter = DateFormat('d MMM - HH:mm น.', 'th');
    return formatter.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final historyList = snapshot.data ?? [];

        return Dialog(
          // ใช้ Dialog แทน AlertDialog เพื่อควบคุมขนาดได้ง่ายขึ้น
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 500, // ตั้ง maxHeight ตรงนี้
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 25, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('รายการเดินบัญชี', style: FontStyle.p6),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    padding: const EdgeInsets.all(12),
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
                    child: historyList.isEmpty
                        ? Center(
                            child: Text(
                              "ไม่มีประวัติการทำรายการ",
                              style: FontStyle.p2.copyWith(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: historyList.length,
                            itemBuilder: (context, index) {
                              final entry = historyList[index];
                              final isSend = entry['type'] == 'send';
                              final amount = entry['amount'];
                              final timestamp = entry['timestamp'] as DateTime;
                              final formattedTime = _formatDateTime(timestamp);
                              final detailText = isSend
                                  ? "โอนไปยัง ${entry['to']}"
                                  : "ได้รับจาก ${entry['from']}";

                              return Column(
                                children: [
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 0,
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            isSend ? 'ถอนเงิน' : 'ฝากเงิน',
                                            style: FontStyle.p2,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${isSend ? '-' : '+'}${amount.toStringAsFixed(2)}',
                                                style: isSend
                                                    ? FontStyle.draw
                                                    : FontStyle.tranfer,
                                              ),
                                              Text(
                                                formattedTime,
                                                style: FontStyle.p2,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 12,
                                          ),
                                          color: Colors.grey.shade100,
                                          child: Text(
                                            detailText,
                                            style: FontStyle.p2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
