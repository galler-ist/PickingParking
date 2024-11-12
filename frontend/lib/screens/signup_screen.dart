import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:frontend/controller.dart';
import 'package:frontend/components/common/button.dart';
import 'package:frontend/components/common/input.dart';
import 'package:frontend/components/common/input_label.dart';
import 'package:frontend/components/common/validator_text.dart';
import 'package:frontend/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final MainController controller = Get.put(MainController());
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
  XFile? vehicleImage;

  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController carNumberController = TextEditingController();

  String? idError;
  String? passwordError;
  String? confirmPasswordError;
  String? phoneError;
  String? carNumberError;

  Future<void> pickVehicleImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      vehicleImage = pickedFile;
    });
  }

  void submitForm() async {
    setState(() {
      idError = null;
      passwordError = null;
      confirmPasswordError = null;
      phoneError = null;
      carNumberError = null;
    });

    bool isValid = true;

    // 아이디 입력 검사
    if (idController.text.isEmpty) {
      idError = "아이디를 입력하세요.";
      isValid = false;
    }

    // 비밀번호 검사
    if (passwordController.text.length < 6) {
      passwordError = "비밀번호는 6자 이상이어야 합니다.";
      isValid = false;
    }

    // 비밀번호 확인 검사
    if (confirmPasswordController.text != passwordController.text) {
      confirmPasswordError = "비밀번호가 일치하지 않습니다.";
      isValid = false;
    }

    // 전화번호 검사
    if (phoneController.text.isEmpty) {
      phoneError = "휴대폰 번호를 입력하세요.";
      isValid = false;
    }

    // 차량 번호 검사
    if (carNumberController.text.isEmpty) {
      carNumberError = "차량 번호를 입력하세요.";
      isValid = false;
    }

    if (isValid) {
      print("회원가입 성공");
      Get.to(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double inputWidth = screenWidth < 600 ? screenWidth * 0.9 : 500;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: inputWidth),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Image.asset(
                        'assets/icons/logo.png',
                        width: inputWidth * 0.6,
                        height: inputWidth * 0.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const InputLabel(name: "아이디"),
                    Input(
                      controller: idController,
                      inputType: TextInputType.text,
                    ),
                    if (idError != null) ValidatorText(text: idError!),
                    const SizedBox(height: 20),
                    const InputLabel(name: "비밀번호"),
                    Input(
                      controller: passwordController,
                      inputType: TextInputType.visiblePassword,
                      obscure: true,
                    ),
                    if (passwordError != null)
                      ValidatorText(text: passwordError!),
                    const SizedBox(height: 20),
                    const InputLabel(name: "비밀번호 확인"),
                    Input(
                      controller: confirmPasswordController,
                      inputType: TextInputType.visiblePassword,
                      obscure: true,
                    ),
                    if (confirmPasswordError != null)
                      ValidatorText(text: confirmPasswordError!),
                    const SizedBox(height: 20),
                    const InputLabel(name: "휴대폰 번호"),
                    Input(
                      controller: phoneController,
                      inputType: TextInputType.phone,
                    ),
                    if (phoneError != null) ValidatorText(text: phoneError!),
                    const SizedBox(height: 20),
                    const InputLabel(name: "차량 번호"),
                    Input(
                      controller: carNumberController,
                      inputType: TextInputType.text,
                    ),
                    if (carNumberError != null)
                      ValidatorText(text: carNumberError!),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: pickVehicleImage,
                        child:
                            Text(vehicleImage != null ? "이미지 선택됨" : "이미지 선택하기"),
                      ),
                    ),
                    if (vehicleImage != null)
                      Image.file(
                        File(vehicleImage!.path),
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(height: 30),
                    Center(
                      child: Button(
                        text: "회원가입",
                        onPressed: submitForm,
                        width: inputWidth,
                        horizontal: 5,
                        vertical: 15,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
