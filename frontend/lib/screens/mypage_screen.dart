import 'package:flutter/material.dart';
import 'package:frontend/components/common/bottom_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/controller.dart';
import 'package:frontend/components/common/top_bar.dart';
import 'package:frontend/screens/login_screen.dart';

// Urecar 오류 해결 위한 임시 패키지
import 'package:frontend/components/common/bottom_navigationbar.dart';
import 'package:frontend/components/setting_screen/setting_item.dart';
import 'package:frontend/components/setting_screen/setting_screen_item.dart';
import 'package:frontend/screens/preparation_screen.dart';
import 'package:frontend/screens/notification_setting_screen.dart';
import 'package:frontend/screens/my_report_screen.dart';
import 'package:frontend/screens/member_withdraw_screen.dart';
import 'package:frontend/screens/gallery_screen.dart';
import 'package:frontend/screens/update_member_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<MyPageScreen> {
  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());
    void logout() async {
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'login');
      setState(() {
        controller.memberEmail.value = "";
        controller.accessToken.value = "";
        controller.memberId.value = 0;
        controller.memberName.value = "";
        controller.memberRole.value = "";
      });
    }

    return Scaffold(
      appBar: TopBar(
        onNotificationTap: () {},
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 30,
              ),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => controller.memberName.value != ""
                      ? const UpdateMemberScreen()
                      : const LoginScreen());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 20.0,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 35,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.memberName.value != ""
                                    ? controller.memberName.value
                                    : "로그인",
                                style: const TextStyle(
                                    fontSize: 28, color: Colors.black),
                              ),
                              controller.memberName.value != ""
                                  ? const Text("정보 수정")
                                  : Container()
                            ],
                          ),
                        )
                      ],
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                      size: 40,
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: 30,
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
            ),
            Column(
              children: [
                const SettingScreenItem(
                  title: "알림 설정",
                  screen: NotificationSettingScreen(),
                ),
                const SettingScreenItem(
                  title: "고객센터",
                  screen: PreparationScreen(),
                ),
                const SettingScreenItem(
                  title: "나의 신고",
                  screen: MyReportScreen(),
                ),
                const SettingScreenItem(
                  title: "내 저장소",
                  screen: GalleryScreen(),
                ),
                SettingItem(
                  title: "로그아웃",
                  onTap: logout,
                  fontColor: const Color(0xffe32222),
                ),
                const SettingScreenItem(
                  title: "회원 탈퇴",
                  screen: MemberWithdrawScreen(),
                  fontColor: Color(0xffe32222),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) {
          controller.changePage(index);
        },
      ),
    );
  }
}
