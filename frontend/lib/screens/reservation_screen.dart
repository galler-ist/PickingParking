import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:frontend/controller.dart';
import 'package:frontend/components/common/bottom_navigation_bar.dart';
import 'package:frontend/components/map/map_reservation_submit.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final MainController controller = Get.put(MainController());
  final MapController _mapController = MapController();
  LatLng? currentCenter;
  bool loading = true;
  int? selectedIndex;
  bool showReservationSubmit = false;
  String searchText = ''; // 검색어 상태 변수

  final List<Map<String, dynamic>> dummyData = [
    {
      "longitude": 127.039574,
      "latitude": 37.501257,
      "parking_zone_name": "Gangnam Parking Zone A",
      "fee": 500,
      "time": [
        {"start": "06:00", "end": "08:00"},
        {"start": "09:00", "end": "23:59"}
      ]
    },
    {
      "longitude": 127.040000,
      "latitude": 37.502000,
      "parking_zone_name": "Gangnam Parking Zone B",
      "fee": 417,
      "time": [
        {"start": "05:00", "end": "08:00"},
        {"start": "09:00", "end": "23:59"}
      ]
    },
    {
      "longitude": 127.041000,
      "latitude": 37.503000,
      "parking_zone_name": "Gangnam Parking Zone C",
      "fee": 583,
      "time": [
        {"start": "06:00", "end": "08:00"},
        {"start": "09:00", "end": "23:59"}
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    currentCenter = LatLng(37.501257, 127.039574);
    getPosition();
  }

  Future<void> getPosition() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentCenter = LatLng(position.latitude, position.longitude);
      loading = false;
    });
  }

  void _moveToLocation(double lat, double lng) {
    setState(() {
      currentCenter = LatLng(lat, lng);
      _mapController.move(currentCenter!, 15.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 검색어에 따라 주차 구역 필터링
    List<Map<String, dynamic>> filteredData = dummyData.where((data) {
      return data['parking_zone_name']
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // 검색창 및 연관 검색어 리스트
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: '주차 구역 검색',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          if (searchText.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  var item = filteredData[index];
                  return ListTile(
                    title: Text(item['parking_zone_name']),
                    onTap: () {
                      // 검색된 주차 구역 클릭 시 지도 위치 이동
                      _moveToLocation(item['latitude'], item['longitude']);
                      setState(() {
                        searchText = ''; // 검색어 초기화
                      });
                    },
                  );
                },
              ),
            ),
          Expanded(
            flex: showReservationSubmit ? 1 : 3,
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: currentCenter,
                          zoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: filteredData.map((data) {
                              LatLng location =
                                  LatLng(data['latitude'], data['longitude']);
                              int markerIndex =
                                  dummyData.indexOf(data); // 현재 마커의 인덱스 가져오기
                              return Marker(
                                point: location,
                                builder: (ctx) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // 이미 선택된 마커를 다시 클릭하면 예약 창을 닫음
                                      if (selectedIndex == markerIndex &&
                                          showReservationSubmit) {
                                        showReservationSubmit = false;
                                        selectedIndex = null;
                                      } else {
                                        selectedIndex = markerIndex;
                                        showReservationSubmit = true;
                                      }
                                    });
                                  },
                                  child: SvgPicture.asset(
                                    'assets/icons/pin_map.svg',
                                    height: 40,
                                    width: 40,
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ],
                  ),
          ),
          if (showReservationSubmit && selectedIndex != null)
            Expanded(
              child: ReservationSubmit(
                latitude: dummyData[selectedIndex!]['latitude'],
                longitude: dummyData[selectedIndex!]['longitude'],
                parkingZoneName: dummyData[selectedIndex!]['parking_zone_name'],
                timeSlots: dummyData[selectedIndex!]['time'],
                fee: dummyData[selectedIndex!]['fee'],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (index) {
          controller.changePage(index);
        },
      ),
    );
  }
}
