import 'package:flutter/material.dart';
import 'package:frontend/components/common/bottom_navigation_bar.dart';
import 'package:frontend/components/common/top_bar.dart';
import 'package:get/get.dart';
import 'package:frontend/controller.dart';

class ReservationManagementScreen extends StatelessWidget {
  const ReservationManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();
    double screenWidth = MediaQuery.of(context).size.width;

    // 반응형 아이콘 및 텍스트 크기
    double iconSize = screenWidth < 400 ? 50 : 60;
    double fontSize = screenWidth < 400 ? 12 : 14;

    return Scaffold(
      appBar: TopBar(onNotificationTap: () {}),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Reservation Section
              Container(
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
                      "내 예약",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "서울 역삼 멀티캠퍼스 주차장",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildReservationDetailRow("현재 주차중인 장소", "서울 역삼 멀티캠퍼스 주차장"),
                    _buildReservationDetailRow(
                        "예약 시간", "3월 12일 (수) 10:00 ~ 3월 13일 (목) 21:00"),
                    _buildReservationDetailRow(
                        "접수된 예약", "3월 12일 (수) 21:00 ~ 3월 13일 (목) 10:00"),
                    _buildReservationDetailRow("시간당 요금", "900 P/분"),
                    _buildReservationDetailRow("현재 요금", "2700 P"),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Icons Row (반응형 아이콘 크기 및 텍스트 크기 조정)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionIcon(
                      Icons.access_time, "예약 관리", iconSize, fontSize),
                  _buildActionIcon(
                      Icons.local_parking, "찜한 주차장", iconSize, fontSize),
                  _buildActionIcon(
                      Icons.receipt_long, "각종 내역", iconSize, fontSize),
                  _buildActionIcon(Icons.settings, "차량 설정", iconSize, fontSize),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Usage History Section
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

  // Helper method to build reservation detail row
  Widget _buildReservationDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper method to build action icon with label and white background
  Widget _buildActionIcon(
      IconData iconData, String label, double iconSize, double fontSize) {
    return Column(
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
    );
  }

  // Helper method to build section header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Helper method to build history item
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
          Text("$title: $vehicle",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("사용 시간: $duration", style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text("이용한 주차장: $location", style: const TextStyle(fontSize: 14)),
          if (amount != null) ...[
            const SizedBox(height: 4),
            Text("결제 금액: $amount", style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
    );
  }
}
