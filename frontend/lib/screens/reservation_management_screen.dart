import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/components/common/bottom_navigation_bar.dart';
import 'package:frontend/components/common/top_bar.dart';
import 'package:frontend/controller.dart';
import 'package:frontend/screens/reservation_history_screen.dart';
import 'package:frontend/screens/reservation_detail_screen.dart';
import 'package:frontend/screens/car_setting_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:async';

class ReservationManagementScreen extends StatefulWidget {
  const ReservationManagementScreen({Key? key}) : super(key: key);

  @override
  _ReservationManagementScreenState createState() =>
      _ReservationManagementScreenState();
}

class _ReservationManagementScreenState
    extends State<ReservationManagementScreen> {
  final MainController controller = Get.find<MainController>();
  final ApiService apiService = ApiService();
  List<dynamic> myReservations = [];
  List<dynamic> jsonNano = [];
  Timer? _timer;

  String hourlyPrice = "정보 없음";

  @override
  void initState() {
    super.initState();
    _fetchReservations();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchJsonNano();
    });
  }

  Future<void> _fetchReservations() async {
    final data = await apiService.searchMyReservation();
    if (mounted && data is List) {
      setState(() {
        myReservations = data;
      });
      print("예약 데이터 가져오기 성공: $data");

      if (myReservations.isNotEmpty) {
        final lastReservationSeq = myReservations.last['seq'];
        await _fetchReservationPrice(lastReservationSeq);
      }
    } else if (data is Map && data.containsKey('error')) {
      print("예약 데이터 가져오기 실패: ${data['error']}");
    } else {
      print("알 수 없는 오류 발생");
    }
  }

  Future<void> _fetchReservationPrice(int zoneSeq) async {
    final data = await apiService.searchMyParkingZoneReservations(zoneSeq);
    print(data);
    if (mounted && data is List && data.isNotEmpty) {
      setState(() {
        hourlyPrice = "${data[0]['price']} P/분";
      });
      print("가격 정보 가져오기 성공: $hourlyPrice");
    } else if (data is Map && data.containsKey('error')) {
      print("가격 정보 가져오기 실패: ${data['error']}");
    }
  }

  Future<void> _fetchJsonNano() async {
    final data = await apiService.connectJsonNano();
    if (mounted && data is List) {
      setState(() {
        jsonNano = data;
      });
      print("주차 구역 데이터 갱신: $data");
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // _buildSectionHeader("최근 이용 내역"),
              const SizedBox(height: 8),
              // _buildHistoryItem(
              //   title: "이용 차량",
              //   vehicle: "24차 1231",
              //   duration: "3월 10일 (일) 12:00 ~ 3월 10일 (일) 21:00",
              //   location: "서울 역삼 멀티캠퍼스 주차장",
              //   amount: "4500 P",
              // ),
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
    String reservationTime = "예약 정보 없음";

    if (myReservations.isNotEmpty) {
      final latestReservation = myReservations.last;
      reservationTime = _formatReservationTime(
        latestReservation['startTime'],
        latestReservation['endTime'],
      );
    }

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
          _buildReservationDetailRow(context, "예약 시간", reservationTime),
          _buildReservationDetailRow(context, "시간당 요금", hourlyPrice),
        ],
      ),
    );
  }

  String _formatReservationTime(String startTime, String endTime) {
    final startDateTime = DateTime.parse(startTime);
    final endDateTime = DateTime.parse(endTime);

    final startFormatted =
        "${startDateTime.month}월 ${startDateTime.day}일 (${_getWeekday(startDateTime.weekday)}) ${startDateTime.hour}:${startDateTime.minute.toString().padLeft(2, '0')}";
    final endFormatted =
        "${endDateTime.month}월 ${endDateTime.day}일 (${_getWeekday(endDateTime.weekday)}) ${endDateTime.hour}:${endDateTime.minute.toString().padLeft(2, '0')}";

    return "$startFormatted ~ $endFormatted";
  }

  String _getWeekday(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  Widget _buildReservationDetailRow(
      BuildContext context, String label, String value) {
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
              style: const TextStyle(fontSize: 10),
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
