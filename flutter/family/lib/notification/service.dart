import 'dart:convert';
import 'package:family/screens/Finalconfirm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import '../firebase_options.dart';
import '../data/user_data.dart';

typedef OnNewRequest = void Function(Map<String, dynamic> data);

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static BuildContext? parentContext;

  /// Callback ที่ UI จะ set เพื่อรับ event คำขอใหม่
  static OnNewRequest? onNewRequestCallback;

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await _initializeLocalNotification();
    await _showFlutterNotification(message);
  }

  static Future<void> InitializeNotification() async {
    await _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final data = message.data;
      final type = data['type'];

      if (type == 'transfer_request') {
        if (onNewRequestCallback != null) {
          onNewRequestCallback!(data);
        } else {
          _showTransferRequestPopup(data);
        }
      } else if (type == 'transfer_approved') {
        _navigateToFinalConfirmPage(data);
      } else if (type == 'family_invite') {
        _showFamilyInvitePopup(data);
      } else {
        await _showFlutterNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("App opened from background notification: ${message.data}");
    });

    await _getFcmToken();
    await _initializeLocalNotification();
    await _getInitialNotification();
  }

  static Future<void> _getFcmToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    final phone = UserDataStore.userData?['phone'];
    if (token != null && phone != null) {
      final url = Uri.parse('http://172.20.10.14:3000/token');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'token': token}),
      );
    }
  }

  static Future<void> _showFlutterNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    Map<String, dynamic> data = message.data;

    String title = notification?.title ?? data['title'] ?? 'No Title';
    String body = notification?.body ?? data['body'] ?? 'No Body';

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      channelDescription: 'Notification channel for basic tests',
      priority: Priority.max,
      importance: Importance.high,
      playSound: true,
      ticker: 'ticker',
    );

    DarwinNotificationDetails iOSDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> _initializeLocalNotification() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSInit = DarwinInitializationSettings();

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("User tapped notification: ${response.payload}");
      },
    );
  }

  static Future<void> _getInitialNotification() async {
    RemoteMessage? message = await FirebaseMessaging.instance
        .getInitialMessage();

    if (message != null) {
      print("App launch from terminated via notification: ${message.data}");
    }
  }

  // --------- API CALLS -----------

  /// เรียกส่งอนุมัติหรือปฏิเสธคำขอโอนเงินไป server
  static Future<void> sendTransferApproval({
    required String from,
    required String to,
    required bool approved,
    required String amount,
  }) async {
    final url = Uri.parse('http://172.20.10.14:3000/approve-transfer');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'from': from,
        'to': to,
        'approved': approved,
        'amount': amount,
      }),
    );

    print('📬 Approval sent: ${response.body}');
  }

  static Future<void> _respondFamilyInvite(
    bool accepted,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('http://172.20.10.14:3000/family-invite-response');

    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': UserDataStore.userData?['phone'],
        'family_id': data['family_id'],
        'accepted': accepted,
      }),
    );
  }

  // ----------- POPUPS แบบเก่า (อาจไม่ใช้) ----------

  static void _showTransferRequestPopup(Map<String, dynamic> data) {
    if (parentContext == null) return;

    final from = data['from_user'] ?? 'ไม่ทราบ';
    final to = data['to'] ?? 'ไม่ทราบ';
    final amount = data['amount'] ?? 'ไม่ระบุ';

    showDialog(
      context: parentContext!,
      builder: (context) => AlertDialog(
        title: const Text('คำขอโอนเงิน'),
        content: Text(
          'ลูกของคุณต้องการโอนเงิน $amount บาท\nจาก: $from → ไป: $to',
        ),
        actions: [
          TextButton(
            child: const Text('ปฏิเสธ'),
            onPressed: () {
              Navigator.pop(context);
              sendTransferApproval(
                from: from,
                to: to,
                approved: false,
                amount: amount.toString(),
              );
            },
          ),
          ElevatedButton(
            child: const Text('อนุมัติ'),
            onPressed: () {
              Navigator.pop(context);
              sendTransferApproval(
                from: from,
                to: to,
                approved: true,
                amount: amount.toString(),
              );
            },
          ),
        ],
      ),
    );
  }

  static void _showFamilyInvitePopup(Map<String, dynamic> data) {
    if (parentContext == null) return;

    final familyName = data['family_name'] ?? 'ครอบครัวของคุณ';
    final inviter = data['inviter'] ?? 'ไม่ทราบ';

    showDialog(
      context: parentContext!,
      builder: (context) => AlertDialog(
        title: const Text('คำเชิญเข้าร่วมครอบครัว'),
        content: Text('$inviter เชิญคุณเข้าร่วม "$familyName"'),
        actions: [
          TextButton(
            child: const Text('ปฏิเสธ'),
            onPressed: () {
              Navigator.pop(context);
              _respondFamilyInvite(false, data);
            },
          ),
          ElevatedButton(
            child: const Text('ยืนยัน'),
            onPressed: () {
              Navigator.pop(context);
              _respondFamilyInvite(true, data);
            },
          ),
        ],
      ),
    );
  }

  // ---------- Navigation ----------

  static void _navigateToFinalConfirmPage(Map<String, dynamic> data) {
    if (parentContext == null) return;

    final to = data['to'];
    final amount = data['amount'];
    final phone = data['phone'];

    Navigator.push(
      parentContext!,
      MaterialPageRoute(
        builder: (_) => FinalConfirmPage(
          to: to,
          amount: double.tryParse(amount ?? '0') ?? 0,
          phone: phone,
        ),
      ),
    );
  }

  // ------------ Test -------------

  static void showTestPopup() async {
    final body = {'from': '321', 'to': '456', 'amount': 999999};

    final url = Uri.parse('http://172.20.10.14:3000/transfer');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print("⚠️ ส่งคำขอโอนเงินแล้ว: ${response.body}");
  }
}
