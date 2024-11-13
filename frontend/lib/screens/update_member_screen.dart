import 'package:flutter/material.dart';
import 'package:frontend/components/common/button.dart';
import 'package:frontend/components/common/input.dart';
import 'package:frontend/components/common/input_label.dart';
import 'package:frontend/components/common/validator_text.dart';
import 'package:frontend/screens/mypage_screen.dart';
import 'package:frontend/controller.dart';
import 'package:frontend/services/api_service.dart';
import 'package:get/get.dart';

class UpdateMemberScreen extends StatefulWidget {
  const UpdateMemberScreen({super.key});

  @override
  State<UpdateMemberScreen> createState() => _UpdateMemberScreenState();
}

class _UpdateMemberScreenState extends State<UpdateMemberScreen> {
  final MainController controller = Get.put(MainController());
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = {};
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? passwordError;
  String? confirmPasswordError;
  String? telError;

  void submitForm() async {
    setState(() {
      passwordError = null;
      confirmPasswordError = null;
      telError = null;
    });

    bool isValid = true;

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

    if (isValid) {
      formKey.currentState!.save();
      final apiService = ApiService();
      formData['email'] = controller.memberEmail.value;
      formData['tel'] = phoneController.text;
      formData['password'] = passwordController.text;

      try {
        final res = await apiService.updateMember(formData);
        if (res == 200) {
          Get.snackbar('성공', '회원 정보가 업데이트되었습니다.',
              snackPosition: SnackPosition.BOTTOM);
          Get.offAll(() => const MyPageScreen());
        } else {
          Get.snackbar('오류', '${res["message"]}',
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        Get.snackbar('오류', '$e', snackPosition: SnackPosition.BOTTOM);
      }
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
                child: Image.asset(
                  'assets/icons/logo.png',
                  width: 350,
                ),
              ),
              const SizedBox(height: 50),
              const InputLabel(name: "비밀번호"),
              Input(
                controller: passwordController,
                inputType: TextInputType.visiblePassword,
                obscure: true,
              ),
              if (passwordError != null) ValidatorText(text: passwordError!),
              const InputLabel(name: "비밀번호 확인"),
              Input(
                controller: confirmPasswordController,
                inputType: TextInputType.visiblePassword,
                obscure: true,
              ),
              if (confirmPasswordError != null)
                ValidatorText(text: confirmPasswordError!),
              const InputLabel(name: "휴대전화 번호"),
              Input(
                controller: phoneController,
                inputType: TextInputType.phone,
              ),
              if (telError != null) ValidatorText(text: telError!),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: SizedBox(
                  width: double.infinity,
                  child: Button(
                    text: '수정',
                    onPressed: submitForm,
                    horizontal: 95,
                    vertical: 13,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
