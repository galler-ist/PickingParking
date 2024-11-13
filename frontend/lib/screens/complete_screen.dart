import 'package:flutter/material.dart';
import 'package:frontend/components/common/button.dart';

class CompleteScreen extends StatefulWidget {
  @override
  _CompleteScreenState createState() => _CompleteScreenState();
}

class _CompleteScreenState extends State<CompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 스케일 애니메이션 초기화 (원 크기 확대)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // 체크 마크 그리기 애니메이션 초기화
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward(); // 애니메이션 시작
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("결제 완료")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _checkAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: CheckPainter(_checkAnimation.value),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                        ),
                      );
                    },
                  ),
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

// 체크 마크 애니메이션을 그리기 위한 CustomPainter
class CheckPainter extends CustomPainter {
  final double progress;

  CheckPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 체크 마크 경로 설정
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.5); // 시작 지점
    path.lineTo(size.width * 0.4, size.height * 0.8); // 중간 지점
    path.lineTo(size.width * 0.9, size.height * 0.2); // 끝 지점

    // 애니메이션 진행에 따라 체크 마크를 부분적으로 그리기
    final pathMetrics = path.computeMetrics();
    for (var metric in pathMetrics) {
      final extractPath = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(CheckPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
