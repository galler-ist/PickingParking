import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/controller.dart';

class BottomNavigation extends StatelessWidget {
  final Function(int) onTap;

  const BottomNavigation({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();

    return BottomNavigationBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      currentIndex: controller.currentIndex.value,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.local_parking,
            size: 30,
          ),
          label: "관리",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.access_time,
          ),
          label: "예약",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            size: 30,
          ),
          label: "홈",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.electric_car,
            size: 30,
          ),
          label: "충전",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            size: 30,
          ),
          label: "마이페이지",
        ),
      ],
    );
  }
}
