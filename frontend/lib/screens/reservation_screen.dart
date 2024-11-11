import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/components/map/map_parking_submit.dart';
import 'package:frontend/components/common/bottom_navigation_bar.dart';
import 'package:frontend/controller.dart';
import 'package:get/get.dart';
import 'package:frontend/components/map/parking_zone_reservation.dart';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'dart:math' as math;
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
  bool showReservationSubmit = false; // ParkingSubmit 위젯 표시 여부
  List<LatLng> parkingLocations = [];
  final List<Map<String, dynamic>> dummyData = [
    {
      "longitude": 127.039574,
      "latitude": 37.501257,
      "parking_zone_name": "Gangnam Parking Zone A",
      "fee": 500,
      "time": [
        {"start": "2024-11-06T06:00:00", "end": "2024-11-06T08:00:00"},
        {"start": "2024-11-06T09:00:00", "end": "2024-11-06T23:59:59"},
        {"start": "2024-11-07T00:00:00", "end": "2024-11-07T23:59:59"},
        {"start": "2024-11-08T00:00:00", "end": "2024-11-08T22:00:00"},
        {"start": "2024-11-08T23:00:00", "end": "2024-11-08T23:59:59"},
      ]
    },
    {
      "longitude": 127.040000,
      "latitude": 37.502000,
      "parking_zone_name": "Gangnam Parking Zone B",
      "fee": 417,
      "time": [
        {"start": "2024-11-06T05:00:00", "end": "2024-11-06T08:00:00"},
        {"start": "2024-11-06T09:00:00", "end": "2024-11-06T23:59:59"},
      ]
    },
    {
      "longitude": 127.041000,
      "latitude": 37.503000,
      "parking_zone_name": "Gangnam Parking Zone C",
      "fee": 583,
      "time": [
        {"start": "2024-11-06T06:00:00", "end": "2024-11-06T08:00:00"},
        {"start": "2024-11-06T09:00:00", "end": "2024-11-06T23:59:59"},
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    currentCenter = LatLng(37.50125721312779, 127.03957422312601);

    getPosition();

    parkingLocations = [
      LatLng(37.5012, 127.0395),
      LatLng(37.5020, 127.0400),
      LatLng(37.5030, 127.0410),
    ];
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
      showReservationSubmit = !showReservationSubmit; // 상태 토글
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: showReservationSubmit ? 1 : 2,
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
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
                          MarkerLayer(
                            markers: parkingLocations
                                .asMap()
                                .map((index, location) {
                                  return MapEntry(
                                    index,
                                    Marker(
                                      point: location,
                                      builder: (ctx) => GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedIndex = index; // 클릭된 인덱스 저장
                                            showReservationSubmit =
                                                !showReservationSubmit;
                                          });
                                        },
                                        child: SvgPicture.asset(
                                          'assets/icons/pin_map.svg',
                                          height: 40,
                                          width: 40,
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .values
                                .toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          if (showReservationSubmit && selectedIndex != null)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ReservationSubmit(
                  latitude: dummyData[selectedIndex!]['latitude'],
                  longitude: dummyData[selectedIndex!]['longitude'],
                  parkingZoneName: dummyData[selectedIndex!]
                      ['parking_zone_name'],
                  timeSlots: dummyData[selectedIndex!]
                      ['time'], // time 필드를 그대로 전달
                  fee: dummyData[selectedIndex!]['fee'],
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
