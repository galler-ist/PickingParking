import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/components/common/bottom_navigation_bar.dart';
import 'package:frontend/components/common/top_bar.dart';
import 'package:frontend/controller.dart';
import 'package:frontend/screens/reservation_history_screen.dart';
import 'package:frontend/screens/reservation_detail_screen.dart';
import 'package:frontend/screens/car_setting_screen.dart';

class ReservationManagementScreen extends StatelessWidget {
  const ReservationManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();
    double screenWidth = MediaQuery.of(context).size.width;

    double iconSize = screenWidth < 400 ? 50 : 60;
    double fontSize = screenWidth < 400 ? 10 : 13;

    return Scaffold(
      appBar: TopBar(onNotificationTap: () {}),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("내 예약"),
              const SizedBox(height: 8),
              _buildReservationInfo(context),
              const SizedBox(height: 16),
              _buildActionButtons(context, iconSize, fontSize),
              const SizedBox(height: 24),
              _buildSectionHeader("최근 이용 내역"),
              const SizedBox(height: 8),
              _buildHistoryItem(
                title: "이용 차량",
                vehicle: "24차 1231",
                duration: "3월 10일 (일) 12:00 ~ 3월 10일 (일) 21:00",
                location: "서울 역삼 멀티캠퍼스 주차장",
                amount: "4500 P",
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

  Widget _buildReservationInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "서울 역삼 멀티캠퍼스 주차장",
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          _buildReservationDetailRow(context, "현재 주차장 상태", "다른 차량 주차중"),
          _buildReservationDetailRow(
              context, "예약 시간", "3월 11일 (수) 10:00 ~ 3월 13일 (목) 21:00"),
          _buildReservationDetailRow(
              context, "접수된 예약", "3월 11일 (수) 10:00 ~ 3월 13일 (목) 10:00"),
          _buildReservationDetailRow(context, "시간당 요금", "900 P/분"),
          _buildReservationDetailRow(context, "현재 요금", "2700 P"),
        ],
      ),
    );
  }

  Widget _buildReservationDetailRow(
      BuildContext context, String label, String value) {
    Color getStatusColor(String status) {
      if (status == '내 차 주차중') {
        return Theme.of(context).primaryColor;
      } else if (status == '다른 차량 주차중') {
        return Colors.red;
      } else {
        return Colors.black;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                color:
                    label == '현재 주차장 상태' ? getStatusColor(value) : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, double iconSize, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionIcon(
          Icons.access_time,
          "예약 관리",
          iconSize,
          fontSize,
          onTap: () => Get.to(() => const ReservationDetailScreen()),
        ),
        _buildActionIcon(
          Icons.local_parking,
          "찜한 주차장",
          iconSize,
          fontSize,
        ),
        _buildActionIcon(
          Icons.receipt_long,
          "각종 내역",
          iconSize,
          fontSize,
          onTap: () => Get.to(() => const ReservationHistoryScreen()),
        ),
        _buildActionIcon(
          Icons.settings,
          "차량 설정",
          iconSize,
          fontSize,
          onTap: () => Get.to(() => const CarSettingScreen()),
        ),
      ],
    );
  }

  Widget _buildActionIcon(
    IconData iconData,
    String label,
    double iconSize,
    double fontSize, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(iconData, size: iconSize * 0.5, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: fontSize)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String vehicle,
    required String duration,
    required String location,
    String? amount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(title, vehicle),
          const SizedBox(height: 8),
          _buildDetailRow("사용 시간", duration),
          _buildDetailRow("이용한 주차장", location),
          if (amount != null) _buildDetailRow("결제 금액", amount),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
