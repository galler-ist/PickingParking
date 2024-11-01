import 'package:flutter/material.dart';

class SettingItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? fontColor;
  const SettingItem(
      {super.key, required this.title, required this.onTap, this.fontColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
