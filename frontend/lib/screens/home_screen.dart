import 'package:flutter/material.dart';
import 'package:frontend/components/common/bottom_navigationbar.dart';
import 'package:get/get.dart';
import 'package:frontend/controller.dart';
import 'package:frontend/components/common/top_bar.dart';
import 'package:frontend/screens/notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopBar(onNotificationTap: () {}),
      body: Center(
        child: Obx(() => Text(
              'Current Page Index: ${controller.currentIndex.value}',
              style: const TextStyle(fontSize: 24, color: Colors.black),
            )),
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) {
          controller.changePage(index);
        },
      ),
    );
  }
}
