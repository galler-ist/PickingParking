import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final MapController _mapController = MapController();
  LatLng? currentCenter;
  bool loading = true;

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
      setState(() {
        loading = false; // 위치 서비스가 비활성화일 경우 로딩 종료
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        setState(() {
          loading = false; // 권한이 거부된 경우 로딩 종료
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      setState(() {
        loading = false; // 권한이 영구적으로 거부된 경우 로딩 종료
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        currentCenter = LatLng(position.latitude, position.longitude);
        loading = false; // 위치를 가져온 후 로딩 종료
      });
    } catch (e) {
      print("Error fetching location: $e");
      setState(() {
        loading = false; // 위치 가져오기에 실패한 경우 로딩 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: '장소를 검색하세요',
            suffixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: EdgeInsets.all(8.0),
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
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
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: LatLng(37.50125721312779, 127.03957422312601),
                          minZoom: 10.0,
                          zoom: 15.0,
                          maxZoom: 19.0,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // 등록하기 버튼 동작 구현
                if (currentCenter != null) {
                  print(
                      '등록할 위치: ${currentCenter!.latitude}, ${currentCenter!.longitude}');
                }
              },
              child: Text('등록하기'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // 버튼 전체 폭 사용
              ),
            ),
          ),
        ],
      ),
    );
  }
}
