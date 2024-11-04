import 'package:flutter/material.dart';
import 'package:frontend/components/common/bottom_navigation_bar.dart';
import 'package:frontend/components/common/top_bar.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/controller.dart';
import 'package:frontend/screens/reservation_management_screen.dart';
import 'package:frontend/screens/parking_zone_management_screen.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();
    double screenWidth = MediaQuery.of(context).size.width;

    bool isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: TopBar(onNotificationTap: () {}),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            alignment: WrapAlignment.center,
            children: [
              _buildManagementCard(
                icon: SvgPicture.asset('assets/icons/icon_reservation.svg',
                    width: 64),
                label: "예약 관리",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ReservationManagementScreen()),
                  );
                },
                cardWidth:
                    isWideScreen ? (screenWidth - 64) / 2 : screenWidth - 32,
              ),
              _buildManagementCard(
                icon: SvgPicture.asset('assets/icons/icon_management.svg',
                    width: 64),
                label: "주차장 관리",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ParkingZoneManagementScreen()),
                  );
                },
                cardWidth:
                    isWideScreen ? (screenWidth - 64) / 2 : screenWidth - 32,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) {
          controller.changePage(index);
        },
      ),
    );
  }

  Widget _buildManagementCard({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
    required double cardWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
