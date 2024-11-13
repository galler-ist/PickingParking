import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio_pkg;
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final MainController controller = Get.put(MainController());
  String? baseUrl = dotenv.env['BASE_URL'];
  String? googleApi = dotenv.env['GOOGLE_API_KEY'];

  Future<dynamic> signUp(
      Map<String, dynamic> formData, File? vehicleImage) async {
    final url = Uri.parse('$baseUrl/api/user/signup');
    try {
      var request = http.MultipartRequest('POST', url)
        ..headers['Content-Type'] = 'application/json';

      formData.forEach((key, value) {
        if (value is String) {
          request.fields[key] = value;
        }
      });

      if (vehicleImage != null) {
        final mimeType = lookupMimeType(vehicleImage.path);
        final fileStream =
            http.ByteStream(Stream.castFrom(vehicleImage.openRead()));
        final length = await vehicleImage.length();

        request.files.add(http.MultipartFile(
          'car_image',
          fileStream,
          length,
          filename: vehicleImage.path.split('/').last,
          contentType: MediaType.parse(mimeType ?? 'application/octet-stream'),
        ));
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        final responseData = await response.stream.bytesToString();
        return jsonDecode(responseData);
      }
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> searchMap(String query) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApi');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['predictions'];
      } else {
        return {'error': 'Failed to fetch data', 'status': response.statusCode};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<dynamic> userIdCheck(Map<String, dynamic> formData) async {
    final url = Uri.parse('$baseUrl/members/emailCheck');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(formData),
      );
      if (response.statusCode == 200) {
        if (response.body == "true") {
          return true;
        } else {
          return false;
        }
      } else {
        final responseData = jsonDecode(response.body);
        return responseData;
      }
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> login(Map<String, dynamic> formData) async {
    const storage = FlutterSecureStorage();
    final url = Uri.parse('$baseUrl/api/user/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(formData),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        controller.accessToken.value = responseData['accessToken'];
        return response.statusCode;
      } else {
        final responseData = jsonDecode(response.body);
        print(response.statusCode);
        print('$baseUrl/api/user/login');
        return responseData;
      }
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> withdraw(Map<String, dynamic> formData) async {
    final url = Uri.parse('$baseUrl/members');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(formData),
      );
      if (response.statusCode == 200) {
        controller.accessToken.value = "";
        controller.memberId.value = 0;
        controller.memberName.value = "";

        return response.statusCode;
      } else {
        final responseData = jsonDecode(response.body);
        return responseData;
      }
    } catch (e) {
      return e;
    }
  }
}
