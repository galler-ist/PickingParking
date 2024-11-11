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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 스크린 상단부 소개 문구
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Picking Parking",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const TextSpan(
                      text: "을 통해 간편하게 주차 문제를 해결보세요",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "다양한 기능이 있습니다.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // 관리 카드 영역
              Center(
                child: Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.center,
                  children: [
                    // 예약 관리 카드
                    _buildManagementCard(
                      icon: SvgPicture.asset(
                          'assets/icons/icon_reservation.svg',
                          width: 48),
                      label: "예약 관리",
                      description: "예약 관리에서는 현재 예약 관리, 차량 설정, 찜한 주차장 기능이 있습니다.",
                      onTap: () {
                        Get.to(() => const ReservationManagementScreen());
                      },
                      cardWidth: isWideScreen
                          ? (screenWidth - 64) / 2
                          : screenWidth - 32,
                    ),
                    // 주차장 관리 카드
                    _buildManagementCard(
                      icon: SvgPicture.asset('assets/icons/icon_management.svg',
                          width: 48),
                      label: "주차장 관리",
                      description: "주차장 관리에서는 주차장 등록 및 관리 기능을 제공합니다.",
                      onTap: () {
                        Get.to(() => const ParkingZoneManagementScreen());
                      },
                      cardWidth: isWideScreen
                          ? (screenWidth - 64) / 2
                          : screenWidth - 32,
                    ),
                  ],
                ),
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

  // 관리 카드 빌드 메서드
  Widget _buildManagementCard({
    required Widget icon,
    required String label,
    required String description,
    required VoidCallback onTap,
    required double cardWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: 140,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
