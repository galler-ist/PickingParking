import 'package:flutter/material.dart';
import 'package:frontend/components/common/bottom_navigation_bar.dart';
import 'package:frontend/components/common/top_bar.dart';
import 'package:get/get.dart';
import 'package:frontend/controller.dart';

class ParkingZoneManagementScreen extends StatelessWidget {
  const ParkingZoneManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    return Scaffold(
      appBar: TopBar(onNotificationTap: () {}),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity, // Full width for consistency
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "내 주차장",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "서울 역삼 멀티캠퍼스 주차장",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    _buildParkingDetailRow("현재 주차중인 차량", "없음"),
                    _buildParkingDetailRow(
                        "개방 예정 시간", "3월 12일 (수) 10:00 ~ 3월 13일 (목) 10:"),
                    _buildParkingDetailRow(
                        "접수된 예약", "3월 12일 (수) 21:00 ~ 3월 13일 (목) 10:00"),
                    _buildParkingDetailRow("예약 차량", "12가 1234"),
                    _buildParkingDetailRow("시간당 요금", "900 P/분"),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Icons Row (4 items in one row with white background)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionIcon(Icons.share, "공유 개방"),
                  _buildActionIcon(Icons.report, "간편 신고"),
                  _buildActionIcon(Icons.receipt, "각종 내역"),
                  _buildActionIcon(Icons.settings, "주차장 설정"),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Parking History Section with full width
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("최근 주차 내역"),
                    const SizedBox(height: 8),
                    _buildHistoryItem(
                      title: "주차 차량",
                      vehicle: "04수 1234",
                      duration: "3월 10일 (일) 12:00 ~ 3월 10일 (일) 21:00",
                      amount: "4500 P",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Recent Report History Section with full width
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("최근 신고 내역"),
                    const SizedBox(height: 8),
                    _buildHistoryItem(
                      title: "신고 차량",
                      vehicle: "95서 0718",
                      duration: "3월 10일 (일) 11:52",
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

  // Helper method to build parking detail row
  Widget _buildParkingDetailRow(String label, String value) {
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
  Widget _buildActionIcon(IconData iconData, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white, // White background for the icon
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(iconData, size: 30, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
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
    String? amount,
  }) {
    return Container(
      width: double.infinity, // Set full width to match other sections
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
          if (amount != null) ...[
            const SizedBox(height: 4),
            Text("결제 금액: $amount", style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
    );
  }
}
