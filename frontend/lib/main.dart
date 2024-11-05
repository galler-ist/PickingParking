import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/reservation_screen.dart';
import 'package:frontend/screens/charging_screen.dart';
import 'package:frontend/screens/mypage_screen.dart';
import 'package:frontend/screens/management_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  // await Firebase.initializeApp();
  await checkPermissions();
  Get.put(MainController());

  runApp(const App());
}

Future<void> checkPermissions() async {
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
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/management', page: () => const ManagementScreen()),
        GetPage(name: '/reservation', page: () => ReservationScreen()),
        GetPage(name: '/myPage', page: () => const MyPageScreen()),
        GetPage(name: '/charging', page: () => const ChargingScreen()),
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/icons/logo.png',
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}
