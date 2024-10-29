import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Obx(() => Text(
              'Current Page Index: ${controller.currentIndex.value}',
              style: const TextStyle(fontSize: 24),
            )),
      ),
    );
  }
}
