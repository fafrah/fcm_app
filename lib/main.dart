import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

import 'fcm_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FCMService _fcmService = FCMService();

  String title = "Waiting for message...";
  String body = "No data yet..";
  String token = "";

  @override
  void initState() {
    super.initState();

    _initFCM();
  }

  Future<void> _initFCM() async {
    token = await _fcmService.getToken() ?? "";

    debugPrint("FCM TOKEN: $token");

    _fcmService.initialize(
      onData: (message) {
        setState(() {
          title = message.notification?.title ?? "No title";
          body = message.notification?.body ?? "No body";
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FCM Demo")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Latest Message:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Title: $title"),
            Text("Body: $body"),
            const SizedBox(height: 20),
            const Text("Your Device Token:"),
            SelectableText(token),
          ],
        ),
      ),
    );
  }
}
