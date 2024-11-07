import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  void _showDatePicker(bool isStartDate) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Container(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (DateTime dateTime) {
                    setState(() {
                      if (isStartDate) {
                        selectedStartDate = dateTime;
                      } else {
                        selectedEndDate = dateTime;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTimePicker(bool isStartTime) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Container(
                height: 200,
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: isStartTime
                      ? Duration(
                          hours: selectedStartTime?.hour ?? 0,
                          minutes: selectedStartTime?.minute ?? 0,
                        )
                      : (selectedStartTime != null
                          ? Duration(
                              hours: selectedStartTime!.hour,
                              minutes: selectedStartTime!.minute,
                            )
                          : Duration(hours: 0, minutes: 0)),
                  onTimerDurationChanged: (Duration duration) {
                    setState(() {
                      TimeOfDay pickedTime = TimeOfDay(
                        hour: duration.inHours,
                        minute: duration.inMinutes % 60,
                      );
                      if (isStartTime) {
                        selectedStartTime = pickedTime;
                        selectedEndTime = null; // 시작 시간 변경 시 종료 시간 초기화
                      } else {
                        selectedEndTime = pickedTime;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int calculateFee() {
    if (selectedStartTime == null || selectedEndTime == null) return 0;

    final startMinutes =
        selectedStartTime!.hour * 60 + selectedStartTime!.minute;
    final endMinutes = selectedEndTime!.hour * 60 + selectedEndTime!.minute;
    final duration = endMinutes - startMinutes;

    final hours = duration / 60;
    return (widget.fee * hours).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('예약 화면')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text("시작 날짜"),
                  CupertinoButton(
                    onPressed: () => _showDatePicker(true),
                    child: Text(
                      selectedStartDate != null
                          ? DateFormat('yyyy/MM/dd').format(selectedStartDate!)
                          : '날짜 선택',
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text("종료 날짜"),
                  CupertinoButton(
                    onPressed: () => _showDatePicker(false),
                    child: Text(
                      selectedEndDate != null
                          ? DateFormat('yyyy/MM/dd').format(selectedEndDate!)
                          : '날짜 선택',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text("시작 시간"),
                  CupertinoButton(
                    onPressed: () => _showTimePicker(true),
                    child: Text(
                      selectedStartTime != null
                          ? selectedStartTime!.format(context)
                          : '시간 선택',
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text("종료 시간"),
                  CupertinoButton(
                    onPressed: () => _showTimePicker(false),
                    child: Text(
                      selectedEndTime != null
                          ? selectedEndTime!.format(context)
                          : '시간 선택',
                    ),
                  ),
                ],
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
                  onPressed: (selectedStartTime != null &&
                          selectedEndTime != null)
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
                                      Get.to(() => ParkingZoneSubmitComplete());
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    );
  }
}
