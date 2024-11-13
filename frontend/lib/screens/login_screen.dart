import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/components/common/button.dart';
import 'package:frontend/components/common/input.dart';
import 'package:frontend/components/common/input_label.dart';
import 'package:frontend/components/common/validator_text.dart';
import 'package:frontend/controller.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final MainController controller = Get.put(MainController());
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = {};
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? idError;
  String? passwordError;

  Future<void> submitForm() async {
    setState(() {
      idError = null;
      passwordError = null;
    });

    bool isValid = true;

    if (idController.text.isEmpty) {
      setState(() {
        idError = "아이디를 입력하세요.";
      });
      isValid = false;
    }

    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      setState(() {
        passwordError = "비밀번호는 6자 이상이어야 합니다.";
      });
      isValid = false;
    }

    if (isValid) {
      formKey.currentState!.save();
      final apiService = ApiService();
      formData = {
        'username': idController.text,
        'password': passwordController.text,
      };

      try {
        final res = await apiService.login(formData);
        if (res == 200) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            controller.changePage(0);
          });
        } else {
          Get.snackbar(
            '오류',
            '${res["message"]}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        Get.snackbar(
          '오류',
          '로그인 중 오류가 발생했습니다. 잠시 후 다시 이용해주세요.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
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
                      child: SvgPicture.asset(
                        'assets/icons/logo.svg',
                        width: inputWidth * 0.6,
                        height: inputWidth * 0.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const InputLabel(name: "아이디"),
                    Input(
                      controller: idController,
                      inputType: TextInputType.text,
                      onSaved: (value) {},
                    ),
                    if (idError != null) ValidatorText(text: idError!),
                    const SizedBox(height: 20),
                    const InputLabel(name: "비밀번호"),
                    Input(
                      controller: passwordController,
                      inputType: TextInputType.visiblePassword,
                      obscure: true,
                      onSaved: (value) {},
                    ),
                    if (passwordError != null)
                      ValidatorText(text: passwordError!),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.to(() => SignupScreen());
                          },
                          child: const Text(
                            "회원가입",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const Text("ㅣ"),
                        TextButton(
                          onPressed: () {
                            Get.to(SignupScreen());
                          },
                          child: const Text(
                            "ID/PW 찾기",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Button(
                        text: "로그인",
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
