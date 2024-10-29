import 'package:flutter/material.dart';
import 'package:frontend/components/common/bottom_navigationbar.dart';
import 'package:get/get.dart';
import 'package:frontend/controller.dart';

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservation"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          "Reservation",
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
