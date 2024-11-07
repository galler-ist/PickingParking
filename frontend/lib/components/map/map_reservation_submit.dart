import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:frontend/screens/parking_zome_submit_complete_screen.dart';
import 'package:table_calendar/table_calendar.dart';

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
  DateTime selectedDate = DateTime.now();
  int? startHourIndex, startMinuteIndex, endHourIndex, endMinuteIndex;
  List<Map<String, String>> filteredTimeSlots = [];

  @override
  void initState() {
    super.initState();
    filterTimeSlotsByDate(selectedDate);
  }

  void filterTimeSlotsByDate(DateTime date) {
    setState(() {
      filteredTimeSlots = [];
      for (var slot in widget.timeSlots) {
        DateTime slotStart = DateTime.parse(slot['start']!);
        DateTime slotEnd = DateTime.parse(slot['end']!);

        if (slotStart.year == date.year &&
            slotStart.month == date.month &&
            slotStart.day == date.day) {
          DateTime currentTime = slotStart;
          while (currentTime.isBefore(slotEnd)) {
            DateTime nextHour = currentTime.add(Duration(hours: 1));
            filteredTimeSlots.add({
              'start': currentTime.toIso8601String(),
              'end': nextHour.isBefore(slotEnd)
                  ? nextHour.toIso8601String()
                  : slotEnd.toIso8601String(),
            });
            currentTime = nextHour;
          }
        }
      }
    });
  }

  List<DateTime> generateMinuteSlots(DateTime start) {
    List<DateTime> minuteSlots = [];
    DateTime currentTime = start;
    DateTime end = currentTime.add(Duration(hours: 1));
    while (currentTime.isBefore(end)) {
      minuteSlots.add(currentTime);
      currentTime = currentTime.add(Duration(minutes: 10));
    }
    return minuteSlots;
  }

  void updateSelection(int hourIndex, int minuteIndex) {
    setState(() {
      // 클릭 시 선택된 hourIndex와 minuteIndex 출력
      print('Clicked hourIndex: $hourIndex, minuteIndex: $minuteIndex');

      if (startHourIndex == null ||
          (startHourIndex != null && endHourIndex != null)) {
        // 첫 번째 클릭 또는 세 번째 클릭 시 초기화 및 시작 설정
        startHourIndex = hourIndex;
        startMinuteIndex = minuteIndex;
        endHourIndex = null;
        endMinuteIndex = null;
      } else if (startHourIndex != null && endHourIndex == null) {
        // 두 번째 클릭으로 범위 설정
        if (hourIndex > startHourIndex! ||
            (hourIndex == startHourIndex! && minuteIndex > startMinuteIndex!)) {
          endHourIndex = hourIndex;
          endMinuteIndex = minuteIndex;
        } else {
          endHourIndex = startHourIndex;
          endMinuteIndex = startMinuteIndex;
          startHourIndex = hourIndex;
          startMinuteIndex = minuteIndex;
        }
        // 두 번째 클릭 시, 선택 범위가 설정되면 범위 확인을 위해 출력
        print(
            'Selected Range -> Start: ($startHourIndex, $startMinuteIndex), End: ($endHourIndex, $endMinuteIndex)');
      }
    });
  }

  bool isWithinSelectedRange(int hourIndex, int minuteIndex) {
    if (startHourIndex == null || endHourIndex == null) return false;

    // 시작 시간과 끝 시간 사이에 있는지 확인
    if ((hourIndex > startHourIndex! ||
            (hourIndex == startHourIndex! &&
                minuteIndex >= startMinuteIndex!)) &&
        (hourIndex < endHourIndex! ||
            (hourIndex == endHourIndex! && minuteIndex <= endMinuteIndex!))) {
      return true;
    }

    return false;
  }

  int calculateFee() {
    return 0; // 요금 계산 로직 추가 가능
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('예약 화면')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedDate,
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                  startHourIndex = null;
                  startMinuteIndex = null;
                  endHourIndex = null;
                  endMinuteIndex = null;
                });
                filterTimeSlotsByDate(selectedDay);
              },
            ),
            const SizedBox(height: 16),
            filteredTimeSlots.isEmpty
                ? Center(child: Text('해당 날짜에 예약 가능한 시간이 없습니다.'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredTimeSlots.length,
                    itemBuilder: (context, hourIndex) {
                      DateTime start = DateTime.parse(
                          filteredTimeSlots[hourIndex]['start']!);
                      DateTime end =
                          DateTime.parse(filteredTimeSlots[hourIndex]['end']!);
                      List<DateTime> minuteSlots = generateMinuteSlots(start);

                      return Row(
                        children: [
                          Container(
                            height: 80,
                            width: 100,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${DateFormat.Hm().format(start)} - ${DateFormat.Hm().format(end)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: 80 / 3,
                              ),
                              itemCount: minuteSlots.length,
                              itemBuilder: (context, minuteIndex) {
                                bool isSelected = isWithinSelectedRange(
                                    hourIndex, minuteIndex);
                                return GestureDetector(
                                  onTap: () {
                                    updateSelection(hourIndex, minuteIndex);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.orange
                                          : Colors.blue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        DateFormat.Hm()
                                            .format(minuteSlots[minuteIndex]),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
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
                    onPressed: (startHourIndex != null && endHourIndex != null)
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
