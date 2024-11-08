import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/components/common/button.dart';
import 'package:frontend/components/common/input.dart';
import 'package:frontend/components/common/input_label.dart';
import 'package:frontend/components/common/validator_text.dart';
import 'package:frontend/controller.dart';
import 'package:frontend/screens/signup_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  final String? imagePath;
  final double? longitude;
  final double? latitude;
  const LoginScreen({super.key, this.imagePath, this.latitude, this.longitude});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final MainController controller = Get.put(MainController());
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = {};
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  void submitForm() async {
    setState(() {
      emailError = null;
      passwordError = null;
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
    }

    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      setState(() {
        passwordError = "비밀번호는 6자 이상이어야 합니다.";
      });
      isValid = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 350,
                ),
              ),
              const SizedBox(height: 50),
              const InputLabel(name: "이메일"),
              Input(
                controller: emailController,
                inputType: TextInputType.emailAddress,
                onSaved: (value) {
                  formData['email'] = value ?? '';
                },
              ),
              if (emailError != null) ValidatorText(text: emailError!),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.to(() => SignupScreen(
                          imagePath: widget.imagePath,
                          longitude: widget.longitude,
                          latitude: widget.latitude));
                    },
                    child: const Text(
                      "회원가입",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Text("ㅣ"),
                  TextButton(
                    onPressed: () {
                      Get.to(SignupScreen(
                          imagePath: widget.imagePath,
                          longitude: widget.longitude,
                          latitude: widget.latitude));
                    },
                    child: const Text(
                      "ID/PW 찾기",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Button(
                  text: "로그인",
                  onPressed: submitForm,
                  horizontal: 100,
                  vertical: 10,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
