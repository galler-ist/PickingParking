import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class _ParkingMap extends StatefulWidget {
  @override
  _ParkingMapState createState() => _ParkingMapState();
}

class _ParkingMapState extends State<_ParkingMap> {
  final LatLng center = LatLng(37.5665, 126.9780); // 서울 좌표 예시
  List<Marker> parkingMarkers = [];

  Future<void> fetchParkingLocations() async {
    print(center.latitude);
    const String apiKey = "YOUR_API_KEY";
    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${center.latitude},${center.longitude}&radius=150&type=parking&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      setState(() {
        parkingMarkers = results.map((place) {
          final lat = place['geometry']['location']['lat'];
          final lng = place['geometry']['location']['lng'];
          return Marker(
            point: LatLng(lat, lng),
            builder: (ctx) => Icon(
              Icons.local_parking,
              color: Colors.blue,
              size: 30,
            ),
          );
        }).toList();
      });
    } else {
      print("Error fetching parking locations: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchParkingLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주변 주차장 보기')),
      body: FlutterMap(
        options: MapOptions(
          center: center,
          zoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: parkingMarkers,
          ),
        ],
      ),
    );
  }
}
