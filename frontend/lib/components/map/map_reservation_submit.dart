import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend/screens/parking_zome_submit_complete_screen.dart';

class ReservationSubmit extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String parkingZoneName;
  final List<Map<String, String>> timeSlots;
  final int fee;

  const ReservationSubmit({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.parkingZoneName,
    required this.timeSlots,
    required this.fee,
  }) : super(key: key);

  @override
  _ReservationSubmitState createState() => _ReservationSubmitState();
}

class _ReservationSubmitState extends State<ReservationSubmit> {
  List<DateTime> selectedDates = [];
  int startHour = 0;
  int startMinute = 0;
  int endHour = 0;
  int endMinute = 0;

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      if (selectedDates.contains(day)) {
        selectedDates.remove(day);
      } else {
        selectedDates.add(day);
        selectedDates.sort();
      }
    });
  }

  int calculateFee() {
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    final duration = endMinutes - startMinutes;

    if (duration <= 0 || selectedDates.length < 2) return 0;
    final days = selectedDates.length;
    final hours = duration / 60;
    return (widget.fee * hours * days).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('예약 화면')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 400, // 일정한 높이 지정
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime(2030, 12, 31),
                focusedDay: DateTime.now(),
                selectedDayPredicate: (day) => selectedDates.contains(day),
                onDaySelected: _onDaySelected,
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text("시작 시간"),
                      Container(
                        height: 150, // Picker 높이 설정
                        child: Row(
                          children: [
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 40, // Picker 항목 높이 설정
                                magnification: 1.2,
                                squeeze: 1.2,
                                onSelectedItemChanged: (int value) {
                                  setState(() {
                                    startHour = value;
                                  });
                                },
                                children:
                                    List<Widget>.generate(24, (int index) {
                                  return Center(child: Text("$index 시"));
                                }),
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 40, // Picker 항목 높이 설정
                                magnification: 1.2,
                                squeeze: 1.2,
                                onSelectedItemChanged: (int value) {
                                  setState(() {
                                    startMinute = value * 10;
                                  });
                                },
                                children: List<Widget>.generate(6, (int index) {
                                  return Center(child: Text("${index * 10} 분"));
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text("종료 시간"),
                      Container(
                        height: 150, // Picker 높이 설정
                        child: Row(
                          children: [
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 40, // Picker 항목 높이 설정
                                magnification: 1.2,
                                squeeze: 1.2,
                                onSelectedItemChanged: (int value) {
                                  setState(() {
                                    endHour = value;
                                  });
                                },
                                children:
                                    List<Widget>.generate(24, (int index) {
                                  return Center(child: Text("$index 시"));
                                }),
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 40, // Picker 항목 높이 설정
                                magnification: 1.2,
                                squeeze: 1.2,
                                onSelectedItemChanged: (int value) {
                                  setState(() {
                                    endMinute = value * 10;
                                  });
                                },
                                children: List<Widget>.generate(6, (int index) {
                                  return Center(child: Text("${index * 10} 분"));
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${calculateFee()} 원',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: selectedDates.length >= 2
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('결제하시겠습니까?'),
                                  content: Text(
                                    '결제 금액: ${calculateFee()}원',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.to(
                                            () => ParkingZoneSubmitComplete());
                                      },
                                      child: const Text('결제하기'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      '결제하기',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
