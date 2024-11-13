import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ParkingZoneReservation extends StatelessWidget {
  const ParkingZoneReservation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center, // 중앙 정렬
      children: [
        Align(
          alignment: Alignment.center, // 핀 이미지 중앙 정렬
          child: SvgPicture.asset(
            'assets/icons/pin_map.svg', // 핀 이미지
            height: 40,
            width: 40,
          ),
        ),
      ],
    );
  }
}
