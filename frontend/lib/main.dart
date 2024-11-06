import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/reservation_screen.dart';
import 'package:frontend/screens/charging_screen.dart';
import 'package:frontend/screens/mypage_screen.dart';
import 'package:frontend/screens/management_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(
      fileName: 'assets/config/.env'); // await Firebase.initializeApp();

  runApp(const LoadingApp());
  void checkPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
    if (await Permission.camera.isDenied) {
      await Permission.camera.request();
    }
  }

  checkPermissions();

  final MainController controller = Get.put(MainController());

  runApp(const App());
}

class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF4C99F3),
        primaryColorLight: const Color(0xFFE3F7F7),
        cardColor: const Color(0xFFF2F3F5),
      ),
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/management', page: () => const ManagementScreen()),
        GetPage(name: '/reservation', page: () => ReservationScreen()),
        GetPage(name: '/myPage', page: () => const MyPageScreen()),
        GetPage(name: '/charging', page: () => const ChargingScreen()),
      ],
    );
  }
}
