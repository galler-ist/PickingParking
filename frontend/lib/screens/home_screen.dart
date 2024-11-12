import 'package:flutter/material.dart';
import 'package:frontend/components/common/bottom_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:frontend/controller.dart';
import 'package:frontend/components/common/top_bar.dart';
import 'package:frontend/components/common/button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/screens/charging_screen.dart';
import 'package:frontend/screens/car_setting_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    return Scaffold(
      appBar: TopBar(onNotificationTap: () {}),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointContainer(context),
            const SizedBox(height: 20),
            _buildSectionHeaderWithIcon(
              SvgPicture.asset('assets/icons/icon_management.svg',
                  width: 24, height: 24),
              "내 주차장",
            ),
            const SizedBox(height: 4),
            _buildParkingCard(
              context,
              date: "00월 00일 요일",
              location: "서울 역삼 멀티캠퍼스 주차장",
              status: "예약중",
              carNumber: "30하 1234",
              width: MediaQuery.of(context).size.width,
            ),
            const SizedBox(height: 20),
            _buildSectionHeaderWithIcon(
              SvgPicture.asset('assets/icons/icon_reservation.svg',
                  width: 24, height: 24),
              "내 예약",
            ),
            const SizedBox(height: 4),
            _buildParkingCard(
              context,
              date: "00월 00일 요일",
              location: "서울 선릉 멀티캠퍼스 주차장",
              status: "예약중",
              carNumber: "19:00 ~ 21:00",
              width: MediaQuery.of(context).size.width,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: [
                _buildVehicleCard(width: _getCardWidth(context)),
                _buildSearchParkingCard(width: _getCardWidth(context)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) {
          controller.changePage(index);
        },
      ),
    );
  }

  double _getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 800) {
      return screenWidth / 3 - 32;
    } else if (screenWidth > 600) {
      return screenWidth / 2 - 32;
    } else {
      return screenWidth - 32;
    }
  }

  Widget _buildSectionHeaderWithIcon(Widget icon, String title) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // 포인트 컨테이너
  Widget _buildPointContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "내 포인트",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              const Text(
                "100000 P",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C99F3),
                ),
              ),
              const SizedBox(width: 8),
              Button(
                text: "충전",
                onPressed: () {
                  Get.to(() => ChargingScreen());
                },
                horizontal: 1.0,
                vertical: 8.0,
                fontSize: 13.0,
                backgroundColor: Theme.of(context).primaryColor,
                contentColor: Colors.white,
                radius: 8.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParkingCard(
    BuildContext context, {
    required String date,
    required String location,
    required String status,
    required String carNumber,
    required double width,
  }) {
    return Container(
      width: width,
      child: Card(
        elevation: 2,
        color: const Color(0xFFF6F6F6),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(location, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        status,
                        style: const TextStyle(color: Color(0xFF4C99F3)),
                      ),
                      Text(
                        carNumber,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard({required double width}) {
    return Container(
      width: width,
      child: Card(
        elevation: 2,
        color: const Color(0xFFF6F6F6),
        child: ListTile(
          title: const Text("내 차량"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("11가 1234", style: TextStyle(color: Color(0xFF4C99F3))),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
          onTap: () {
            Get.to(() => const CarSettingScreen());
          },
        ),
      ),
    );
  }

  Widget _buildSearchParkingCard({required double width}) {
    return Container(
      width: width,
      child: Card(
        elevation: 2,
        color: const Color(0xFFF6F6F6),
        child: const ListTile(
          title: Text("주변 주차장 검색하기"),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        ),
      ),
    );
  }
}
