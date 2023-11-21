import 'package:flutter/material.dart';

Widget setTierImg({required int score}) {
  if (score < 1000) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(
        'lib/assets/icons/tierBronze.png',
        fit: BoxFit.cover,
      ),
    );
  } else if (1000 <= score && score < 1100) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(
        'lib/assets/icons/tierSilver.png',
        fit: BoxFit.cover,
      ),
    );
  } else if (1100 <= score && score < 1200) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(
        'lib/assets/icons/tierGold.png',
        fit: BoxFit.cover,
      ),
    );
  } else if (1200 <= score && score < 1300) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(
        'lib/assets/icons/tierPlatinum.png',
        fit: BoxFit.cover,
      ),
    );
  } else {
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(
        'lib/assets/icons/tierDiamond.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
