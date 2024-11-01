import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:frontend/controller.dart';
import 'package:frontend/components/common/button.dart';
import 'package:frontend/components/common/input.dart';
import 'package:frontend/components/common/input_label.dart';
import 'package:frontend/components/common/validator_text.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/components/common/top_bar.dart';

class SignupScreen extends StatefulWidget {
  final String? imagePath;
  final double? longitude;
  final double? latitude;
  const SignupScreen({
    super.key,
    this.imagePath,
    this.longitude,
    this.latitude,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final MainController controller = Get.put(MainController());
  final formKey = GlobalKey<FormState>();
  XFile? vehicleImage; // 차량 이미지를 저장할 변수
  Map<String, dynamic> formData = {};
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController carNumberController = TextEditingController();

  String? emailError;
  String? emailSuccess;
  String? passwordError;
  String? confirmPasswordError;
  String? nameError;
  String? telError;
  String? carNumberError;

  Future<void> pickVehicleImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      vehicleImage = pickedFile; // 선택한 이미지를 변수에 저장
    });
  }

  Future<void> checkEmailDuplicate() async {
    final apiService = ApiService();
    setState(() {
      emailError = null;
      emailSuccess = null;
    });

    try {
      final isAvailable =
          await apiService.userIdCheck({'email': emailController.text});

      if (!isAvailable) {
        setState(() {
          emailSuccess = "사용 가능한 이메일입니다.";
          emailError = null;
          formData["email"] = emailController.text;
        });
      } else {
        setState(() {
          emailError = "이미 사용 중인 이메일입니다.";
          emailSuccess = null;
        });
      }
    } catch (e) {
      setState(() {
        emailError = "이메일 중복 확인 중 오류가 발생했습니다.";
        emailSuccess = null;
      });
    }
  }

  void submitForm() async {
    setState(() {
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;
      nameError = null;
      telError = null;
      carNumberError = null;
    });

    bool isValid = true;

    if (emailController.text.isEmpty) {
      setState(() {
        emailError = "이메일을 입력하세요.";
      });
      isValid = false;
    } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
        .hasMatch(emailController.text)) {
      setState(() {
        emailError = "유효한 이메일 주소를 입력하세요.";
      });
      isValid = false;
    } else if (emailSuccess == null) {
      setState(() {
        emailError = "이메일 중복을 확인해주세요.";
      });
      isValid = false;
    }

    if (passwordController.text.length < 6) {
      setState(() {
        passwordError = "비밀번호는 6자 이상이어야 합니다.";
      });
      isValid = false;
    }

    if (confirmPasswordController.text != passwordController.text) {
      setState(() {
        confirmPasswordError = "비밀번호가 일치하지 않습니다.";
      });
      isValid = false;
    }
    if (phoneController.text.isEmpty) {
      setState(() {
        telError = "전화번호를 입력하세요.";
      });
      isValid = false;
    }
    if (carNumberController.text.isEmpty) {
      setState(() {
        carNumberError = "차량번호를 입력하세요";
      });
      isValid = false;
    }
    if (isValid) {
      formKey.currentState!.save();
      final apiService = ApiService();
      formData['address'] = {
        'address': formData.remove('address_base') ?? '',
        'addressDetail': formData.remove('address_detail') ?? '',
        'zipCode': formData.remove('zip_code') ?? ''
      };
      try {
        File? vehicleFile =
            vehicleImage != null ? File(vehicleImage!.path) : null;
        final res =
            await apiService.signUp(formData, vehicleFile); // vehicleImage 전달
        if (res == 200) {
          Get.offAll(LoginScreen(
            imagePath: widget.imagePath,
            longitude: widget.longitude,
            latitude: widget.latitude,
          ));
        } else {
          Get.snackbar('오류', '${res["message"]}',
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        Get.snackbar('오류', '로그인 중 오류가 발생했습니다. 잠시 후 다시 이용해주세요.',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(onNotificationTap: () {}),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 350,
                ),
              ),
              const SizedBox(height: 50),
              const InputLabel(name: "아이디"),
              Input(
                controller: emailController,
                inputType: TextInputType.emailAddress,
                buttonText: "중복 확인",
                onPressed: checkEmailDuplicate,
              ),
              if (emailError != null) ValidatorText(text: emailError!),
              if (emailSuccess != null)
                ValidatorText(
                  text: emailSuccess!,
                  color: Colors.blue,
                ),
              const InputLabel(name: "비밀번호"),
              Input(
                controller: passwordController,
                inputType: TextInputType.visiblePassword,
                obscure: true,
                onSaved: (value) {
                  formData['password'] = value ?? '';
                },
              ),
              if (passwordError != null) ValidatorText(text: passwordError!),
              const InputLabel(name: "비밀번호 확인"),
              Input(
                controller: confirmPasswordController,
                inputType: TextInputType.visiblePassword,
                obscure: true,
              ),
              if (nameError != null) ValidatorText(text: nameError!),
              const InputLabel(name: "휴대전화 번호"),
              Input(
                controller: phoneController,
                inputType: TextInputType.phone,
                onSaved: (value) {
                  formData['tel'] = value ?? '';
                },
              ),
              // 차량 번호 관련해서 controller 고쳐야함!
              if (nameError != null) ValidatorText(text: nameError!),
              const InputLabel(name: "차량 번호"),
              Input(
                controller: carNumberController,
                inputType: TextInputType.text,
                onSaved: (value) {
                  formData['car_number'] = value ?? '';
                },
              ),
              if (carNumberError != null) ValidatorText(text: carNumberError!),
              // 차량 이미지 선택 버튼
              const InputLabel(name: "차량 등록증"),
              Center(
                child: TextButton(
                  onPressed: pickVehicleImage,
                  child: Text(vehicleImage != null ? "이미지 선택됨" : "이미지 선택하기"),
                ),
              ),
              // 이미지 미리보기
              if (vehicleImage != null)
                Image.file(
                  File(vehicleImage!.path),
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),

              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: SizedBox(
                  width: double.infinity,
                  child: Button(
                    text: "회원가입",
                    onPressed: submitForm,
                    horizontal: 95,
                    vertical: 13,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
