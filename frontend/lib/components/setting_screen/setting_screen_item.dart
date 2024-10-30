import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingScreenItem extends StatelessWidget {
  final String title;
  final Widget screen;
  final Color? fontColor;
  const SettingScreenItem(
      {super.key, required this.title, required this.screen, this.fontColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {Get.to(() => screen)},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 30,
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
                    color: fontColor),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 40,
            )
          ],
        ),
      ),
    );
  }
}
