import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _downwardController = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  );

  late final AnimationController _tiltController = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  );

  late final Animation<Offset> _pinAnimation = Tween<Offset>(
    begin: Offset(0, -8),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _downwardController, curve: Curves.fastOutSlowIn),
  );

  late final Animation<double> _tiltAnimation = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.075), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 0.075, end: -0.075), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -0.075, end: 0.075), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 0.075, end: 0.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _tiltController, curve: Curves.linear));

  @override
  void initState() {
    super.initState();

    // 핀이 내려온 후 흔들림 애니메이션 시작
    _downwardController.forward().then((_) {
      _tiltController.forward();
    });
  }

  @override
  void dispose() {
    _downwardController.dispose();
    _tiltController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 회전된 'P' 텍스트
            Transform.translate(
              offset: Offset(7, 34),
              child: Transform.rotate(
                angle: -0.395398, // -45도 회전
                child: Text(
                  'P',
                  style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // 핀 내려오고 고정 + 좌우 흔들림 애니메이션
            SlideTransition(
              position: _pinAnimation,
              child: RotationTransition(
                turns: _tiltAnimation,
                alignment: Alignment.bottomCenter, // 아래쪽을 축으로 고정
                child: Image.asset(
                  'assets/icons/pin.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
