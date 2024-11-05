import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ParkingZoneMarker extends StatelessWidget {
  const ParkingZoneMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/pin_map.svg',
      height: 40,
      width: 40,
    );
  }
}
