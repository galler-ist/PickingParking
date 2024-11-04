import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/components/map/map_parking_submit.dart';
import 'package:frontend/components/common/bottom_navigation_bar.dart';
import 'package:frontend/controller.dart';
import 'package:get/get.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final MapController _mapController = MapController();
  LatLng? currentCenter;
  bool loading = true;
  bool showParkingSubmit = false; // ParkingSubmit 위젯 표시 여부

  @override
  void initState() {
    super.initState();
    currentCenter = LatLng(37.50125721312779, 127.03957422312601); // 초기 위치 설정
    getPosition();
  }

  void _onMapMove(MapPosition position, bool hasGesture) {
    setState(() {
      currentCenter = position.center;
    });
  }

  Future<void> getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
      setState(() {
        currentCenter = LatLng(position.latitude, position.longitude);
        loading = false;
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  void _toggleParkingSubmit() {
    setState(() {
      showParkingSubmit = !showParkingSubmit; // 상태 토글
    });
  }

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: '장소를 검색하세요',
            suffixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.all(8.0),
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (currentCenter != null) {
                _mapController.move(currentCenter!, 15.0);
                print(
                    'Current center: ${currentCenter!.latitude}, ${currentCenter!.longitude}');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: showParkingSubmit ? 1 : 2, // ParkingSubmit 표시 여부에 따라 비율 조정
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: currentCenter,
                          minZoom: 10.0,
                          zoom: 15.0,
                          maxZoom: 18.0,
                          onPositionChanged: _onMapMove,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: ['a', 'b', 'c'],
                          ),
                        ],
                      ),
                      // 고정된 핀 아이콘
                      Center(
                        child: SvgPicture.asset(
                          'assets/icons/pin_map.svg',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
          ),
          if (showParkingSubmit) // ParkingSubmit 위젯을 조건부로 표시
            Expanded(
              flex: 1, // ParkingSubmit 위젯의 비율을 1로 설정
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ParkingSubmit(
                  latitude: currentCenter!.latitude,
                  longitude: currentCenter!.longitude,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _toggleParkingSubmit, // 버튼 클릭 시 상태 토글
              child: Text(showParkingSubmit ? '닫기' : '등록하기'), // 버튼 텍스트 변경
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // 버튼 전체 폭 사용
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) {
          controller.changePage(index);
        },
      ),
    );
  }
}
