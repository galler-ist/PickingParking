import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  String? address1;
  String? address2;
  String? address3;
  String? address4;
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
    final naverApiId = dotenv.env['NAVER_Api_Id']; // 여기에 네이버 API 키 입력
    final naverApiKey = dotenv.env['NAVER_Api_KEY'];
    final url =
        'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=${widget.longitude},${widget.latitude}&output=json&orders=roadaddr';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-ncp-apigw-api-key-id': naverApiId!, // 클라이언트 ID
          'x-ncp-apigw-api-key': naverApiKey!, // 클라이언트 Secret
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data['results'][0]['land']);
        if (data["results"][0].isNotEmpty) {
          setState(() {
            address1 = data["results"][0]['region']['area1']['name']; // 도로명 주소
            address2 = data["results"][0]['region']['area2']['name']; // 도로명 주소
            address3 = data["results"][0]['region']['area3']['name']; // 도로명 주소
            address4 = data["results"][0]['land']['name']; // 도로명 주소
            loading = false;
          });
        } else {
          setState(() {
            address1 = '주소를 찾을 수 없습니다.';
            loading = false;
          });
        }
      } else {
        setState(() {
          address1 = '주소 가져오기 실패';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        address1 = '오류: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주차장 위치',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            loading
                ? const CircularProgressIndicator() // 로딩 중일 때 인디케이터 표시
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${address1} ${address2} ${address3} ${address4}', // 현재 핀 위치
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: '주소',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true, // 주소 필드를 읽기 전용으로 설정
                        onTap: () {
                          addressController.text =
                              '${address1} ${address2} ${address3} ${address4}'; // 가져온 주소 설정
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: detailedAddressController,
                        decoration: const InputDecoration(
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
