import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingItem extends StatelessWidget {
  final String title;
  final Widget? screen; // 화면 이동이 필요한 경우
  final VoidCallback? onTap; // 콜백 함수가 필요한 경우
  final Color? fontColor;

  const SettingItem({
    super.key,
    required this.title,
    this.screen,
    this.onTap,
    this.fontColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (screen != null) {
          Get.to(() => screen!);
        } else if (onTap != null) {
          onTap!();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: fontColor ?? Colors.black,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}
