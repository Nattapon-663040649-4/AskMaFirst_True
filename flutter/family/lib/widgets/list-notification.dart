import 'dart:async';
import 'package:family/notification/service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:family/widgets/noti-icon.dart';
import 'package:family/styles/colors.dart';
import 'package:family/styles/font.dart';

String formatPhoneNumber(String phone) {
  if (phone.length != 10) return phone;
  return '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
}

class ListNotification extends StatefulWidget {
  final int filterIndex;

  const ListNotification({super.key, required this.filterIndex});

  @override
  State<ListNotification> createState() => _ListNotificationState();
}

class _ListNotificationState extends State<ListNotification> {
  late Map<int, int> _remainingTime;
  Timer? _timer;
  final Map<int, bool> _handledRequests = {};

  final List<_NotificationItem> allNotis = [
    _NotificationItem(
      type: 'money',
      icon: const Icon(
        Icons.currency_exchange_outlined,
        size: 40,
        color: Colors.red,
      ),
      title: "นรสิงห์ - โอนเงินออก",
      message:
          "โอนเงินจำนวน ฿300\nโอนไปยังเบอร์ ${formatPhoneNumber('0912345678')}",
      date: "09/08/2568",
      time: "19:12",
    ),
    _NotificationItem(
      type: 'money',
      icon: const Icon(
        Icons.currency_exchange_outlined,
        size: 40,
        color: Colors.green,
      ),
      title: "นรสิงห์ - ได้รับเงิน",
      message:
          "ได้รับเงินจำนวน ฿200\nโอนจากเบอร์ ${formatPhoneNumber('0987654321')}",
      date: "09/08/2568",
      time: "12:54",
    ),
    _NotificationItem(
      type: 'money',
      icon: const Icon(
        Icons.currency_exchange_outlined,
        size: 40,
        color: Colors.green,
      ),
      title: "นรสิงห์ - ได้รับเงิน",
      message:
          "ได้รับเงินจำนวน ฿200\nโอนจากเบอร์ ${formatPhoneNumber('0987654321')}",
      date: "09/08/2568",
      time: "12:54",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _remainingTime = {};

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime.updateAll((key, value) => value > 0 ? value - 1 : 0);
      });
    });

    NotificationService.onNewRequestCallback = (data) {
      final now = DateTime.now();
      final fromUserName = 'นรสิงห์'; // ปรับชื่อผู้ใช้ได้ตามจริง

      // ฟอร์แมตเบอร์โทรศัพท์
      final toFormatted = data['to'] != null
          ? formatPhoneNumber(data['to'].toString())
          : 'ไม่ทราบ';

      final amountStr = data['amount']?.toString() ?? '0';

      final newRequest = _NotificationItem(
        type: 'request',
        icon: const TrueMoneyIcon(size: 40),
        title: "$fromUserName - รายการเสี่ยง",
        message:
            "ได้รับเงินเป็นจำนวน $amountStr บาท\nจาก: $toFormatted\nบัญชีต้นทางนี้อาจมีความเสี่ยง\nกรุณาตรวจสอบข้อมูลหรือติดต่อเจ้าหน้าที่",
        date: DateFormat('dd/MM/yyyy').format(now),
        time: DateFormat('HH:mm').format(now),
        duration: 1, // 5 นาที
        fromUser: data['from_user'] ?? '',
        toUser: data['to'] ?? '',
        amount: int.tryParse(amountStr) ?? 0,
      );

      // final newRequest = _NotificationItem(
      //   type: 'request',
      //   icon: const TrueMoneyIcon(size: 40),
      //   title: "$fromUserName - รายการเสี่ยง",
      //   message:
      //       "ต้องการโอนเงินเกินที่กำหนด\nจำนวน $amountStr บาท\nไปยัง: $toFormatted\nบัญชีปลายทางนี้อาจมีความเสี่ยง\nกรุณาตรวจสอบข้อมูลให้ถูกต้องก่อนโอน",
      //   date: DateFormat('dd/MM/yyyy').format(now),
      //   time: DateFormat('HH:mm').format(now),
      //   duration: 300, // 5 นาที
      //   fromUser: data['from_user'] ?? '',
      //   toUser: data['to'] ?? '',
      //   amount: int.tryParse(amountStr) ?? 0,
      // );

      setState(() {
        allNotis.insert(0, newRequest);
        final newRemaining = <int, int>{0: newRequest.duration!};
        _remainingTime.forEach((key, value) {
          newRemaining[key + 1] = value;
        });
        _remainingTime = newRemaining;
      });
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    NotificationService.onNewRequestCallback = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<_NotificationItem> filteredNotis;

    if (widget.filterIndex == 0) {
      filteredNotis = allNotis;
    } else if (widget.filterIndex == 1) {
      filteredNotis = allNotis
          .where((n) => n.type == 'request' || n.type == 'money')
          .toList();
    } else {
      filteredNotis = [];
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: filteredNotis.length,
      separatorBuilder: (_, __) => _divider(),
      itemBuilder: (context, index) {
        final noti = filteredNotis[index];
        final globalIndex = allNotis.indexOf(noti);
        final remaining = _remainingTime[globalIndex] ?? 0;
        return _buildNotification(noti, remaining, globalIndex);
      },
    );
  }

  Widget _buildNotification(
    _NotificationItem noti,
    int remainingTime,
    int index,
  ) {
    final isRequest = noti.type == 'request';
    final handled = _handledRequests.containsKey(index);
    final showButtons = isRequest && remainingTime > 0 && !handled;
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    final formattedTime =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final textColor = isRequest ? Colors.white : Colors.black;

    // ฟอร์แมตเบอร์โทรศัพท์ในข้อความถ้าเป็น request
    String displayedMessage = noti.message;
    if (isRequest && noti.toUser != null) {
      final formattedPhone = formatPhoneNumber(noti.toUser!);
      displayedMessage = noti.message.replaceAll(noti.toUser!, formattedPhone);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isRequest ? null : Colors.transparent,
        gradient: isRequest
            ? const LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              noti.icon,
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(noti.title, textColor),
                    const SizedBox(height: 6),
                    Text(
                      displayedMessage,
                      style: FontStyle.p7.copyWith(
                        color: isRequest ? Colors.white : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${noti.date} ${noti.time}',
                          style: FontStyle.p2.copyWith(
                            color: isRequest ? Colors.white : Colors.black45,
                          ),
                        ),
                        if (showButtons)
                          Text(
                            'เหลือเวลา: $formattedTime',
                            style: FontStyle.p2.copyWith(color: Colors.white70),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showButtons) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _button(
                  text: 'อนุมัติ',
                  isApprove: true,
                  onPressed: () {
                    _handleApproveReject(true, index);
                  },
                ),
                const SizedBox(width: 10),
                _button(
                  text: 'ปฏิเสธ',
                  isApprove: false,
                  onPressed: () {
                    _handleApproveReject(false, index);
                  },
                ),
              ],
            ),
          ],
          if (handled) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _handledRequests[index]!
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _handledRequests[index]!
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _handledRequests[index]! ? 'อนุมัติแล้ว' : 'ปฏิเสธแล้ว',
                        style: FontStyle.btn2.copyWith(
                          color: _handledRequests[index]!
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _handleApproveReject(bool approved, int index) {
    final noti = allNotis[index];
    if (noti.type == 'request') {
      NotificationService.sendTransferApproval(
        from: noti.fromUser ?? '',
        to: noti.toUser ?? '',
        approved: approved,
        amount: noti.amount?.toString() ?? '0',
      );
    }
    setState(() {
      _handledRequests[index] = approved;
    });
  }

  Widget _buildTitle(String title, Color fallbackColor) {
    final hasIn = title.contains('ได้รับเงิน');
    final hasOut = title.contains('โอนเงินออก');
    final hasRisk = title.contains('รายการเสี่ยง');

    if (!hasIn && !hasOut) {
      return Text(
        title,
        style: FontStyle.p6.copyWith(
          color: fallbackColor,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final parts = title.split(' - ');
    final name = parts.first;
    final action = parts.length > 1 ? parts[1] : '';

    return RichText(
      text: TextSpan(
        style: FontStyle.p6.copyWith(fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: '$name ',
            style: TextStyle(color: fallbackColor),
          ),
          TextSpan(
            text: action,
            style: TextStyle(color: hasRisk ? Colors.red : Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _button({
    required String text,
    required bool isApprove,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isApprove ? Colors.white : MyColors.or1,
        foregroundColor: isApprove ? MyColors.or1 : Colors.white,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 0,
      ),
      child: Text(
        text,
        style: FontStyle.btn2.copyWith(
          color: isApprove ? MyColors.or1 : Colors.white,
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: Colors.grey);
  }
}

class _NotificationItem {
  final String type;
  final Widget icon;
  final String title;
  final String message;
  final String date;
  final String time;
  final int? duration;
  final String? fromUser;
  final String? toUser;
  final int? amount;

  _NotificationItem({
    required this.type,
    required this.icon,
    required this.title,
    required this.message,
    required this.date,
    required this.time,
    this.duration,
    this.fromUser,
    this.toUser,
    this.amount,
  });
}
