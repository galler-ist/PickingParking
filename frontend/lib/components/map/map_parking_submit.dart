import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ParkingSubmit extends StatefulWidget {
  final double latitude;
  final double longitude;

  const ParkingSubmit({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _ParkingSubmitState createState() => _ParkingSubmitState();
}

class _ParkingSubmitState extends State<ParkingSubmit> {
  String? address;
  bool loading = true;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController detailedAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    final apiKey = 'YOUR_API_KEY'; // 여기에 본인의 API 키 입력
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${widget.latitude},${widget.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          setState(() {
            address = data['results'][0]['formatted_address'];
            loading = false;
          });
        } else {
          setState(() {
            address = '주소를 찾을 수 없습니다.';
            loading = false;
          });
        }
      } else {
        setState(() {
          address = '주소 가져오기 실패';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        address = '오류: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주차장 위치',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            loading
                ? CircularProgressIndicator() // 로딩 중일 때 인디케이터 표시
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '위도: ${widget.latitude}', // 위도 표시
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '경도: ${widget.longitude}', // 경도 표시
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: '주소',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: detailedAddressController,
                        decoration: InputDecoration(
                          labelText: '상세 주소',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
