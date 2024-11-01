import 'package:flutter/material.dart';
import 'package:frontend/components/common/button.dart';

class CompleteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("결제 완료")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "결제 완료!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "버튼을 누르시면 충전 화면으로 돌아갑니다.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Button(
              text: "홈으로 돌아가기",
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              horizontal: 16,
              vertical: 8,
              fontSize: 16,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
