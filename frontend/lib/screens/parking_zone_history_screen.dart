import 'package:flutter/material.dart';
import 'package:frontend/components/common/bottom_navigation_bar.dart';
import 'package:frontend/components/common/top_bar.dart';
import 'package:get/get.dart';
import 'package:frontend/controller.dart';

class ParkingZoneHistoryScreen extends StatelessWidget {
  const ParkingZoneHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    // 예시용 데이터, 포인트는 + 값으로 설정
    final List<Map<String, dynamic>> dummyData = [
      {
        "date": "2024.07.15",
        "transactions": [
          {
            "location": "서울 홍대 주차장",
            "points": "+2000 P",
          },
        ]
      },
      {
        "date": "2024.07.10",
        "transactions": [
          {
            "location": "서울 신촌 주차장",
            "points": "+1500 P",
          },
        ]
      },
      {
        "date": "2024.06.28",
        "transactions": [
          {
            "location": "서울 용산 주차장",
            "points": "+3000 P",
          },
        ]
      }
    ];

    return Scaffold(
      appBar: TopBar(onNotificationTap: () {}),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: dummyData.length,
        itemBuilder: (context, index) {
          final dateSection = dummyData[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 헤더
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  dateSection["date"],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 해당 날짜의 트랜잭션들
              ...dateSection["transactions"].map<Widget>((transaction) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 아이콘 및 주차장 위치
                      Row(
                        children: [
                          Icon(
                            Icons.local_parking,
                            color: Theme.of(context)
                                .primaryColor, // primary color 적용
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            transaction["location"],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      // 포인트 표시
                      Text(
                        transaction["points"],
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context)
                              .primaryColor, // primary color 적용
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) {
          controller.changePage(index);
        },
      ),
    );
  }
}
