import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/screens/parking_zone_submit_complete_screen.dart';

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
    final naverApiId = dotenv.env['NAVER_Api_Id'];
    final naverApiKey = dotenv.env['NAVER_Api_KEY'];
    final url =
        'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=${widget.longitude},${widget.latitude}&output=json&orders=roadaddr';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-ncp-apigw-api-key-id': naverApiId!,
          'x-ncp-apigw-api-key': naverApiKey!,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data['results'][0]['land']);
        if (data["results"][0].isNotEmpty) {
          setState(() {
            address1 = data["results"][0]['region']['area1']['name'];
            address2 = data["results"][0]['region']['area2']['name'];
            address3 = data["results"][0]['region']['area3']['name'];
            address4 = data["results"][0]['land']['name'];
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

  Future<void> _submitAddress() async {
    final address = addressController.text;
    final detailedAddress = detailedAddressController.text;
    final data = jsonEncode({
      'address': address,
      'detailedAddress': detailedAddress,
    });
    print('미리 볼 JSON 데이터 :  $data');
    // final url = 'YOUR_API_ENDPOINT'; // 실제 API 엔드포인트로 변경하세요

    // try {
    //   final response = await http.post(
    //     Uri.parse(url),
    //     headers: {"Content-Type": "application/json"},
    //     body: jsonEncode({
    //       'address': address,
    //       'detailed_address': detailedAddress,
    //       'latitude': widget.latitude,
    //       'longitude': widget.longitude,
    //     }),
    //   );

    //   if (response.statusCode == 200) {
    //     print('주소 제출 성공');
    //   } else {
    //     print('주소 제출 실패: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   print('오류 발생: $e');
    // }
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
                ? const CircularProgressIndicator()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '현재 핀 위치: ${address1 ?? ''} ${address2 ?? ''} ${address3 ?? ''} ${address4 ?? ''}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: '주소',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () {
                          addressController.text =
                              '${address1 ?? ''} ${address2 ?? ''} ${address3 ?? ''} ${address4 ?? ''}';
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
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _submitAddress();
                          Get.to(() => ParkingZoneSubmitComplete());
                        },
                        child: const Text('주소 제출하기'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
