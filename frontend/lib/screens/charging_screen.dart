import 'package:flutter/material.dart';
import 'package:frontend/components/common/bottom_navigationbar.dart';
import 'package:get/get.dart';
import 'package:frontend/controller.dart';

class ChargingScreen extends StatelessWidget {
  const ChargingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();

    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          "Charging",
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) {
          controller.changePage(index);
        },
      ),
    );
  }
}
