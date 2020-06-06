import 'package:flutter/material.dart';
import 'package:deleco/theme/color/LightColors.dart';

class ColorChoice {
  ColorChoice({@required this.primary, @required this.gradient});

  final Color primary;
  final List<Color> gradient;
}
class ColorChoices {
  static List<ColorChoice> choices = [
    ColorChoice(
      primary: LightColor.darkGreen,
      gradient: [
        Color.fromRGBO(3, 84, 15, 1.0),
        Color.fromRGBO(3, 80, 15, 1.0),
      ],
    ),
    ColorChoice(
      primary: LightColor.darkyellow,
      gradient: [
        Color.fromRGBO(255, 140, 0, 1.0),
        Color.fromRGBO(255, 150, 0, 1.0),
      ],
    ),
    ColorChoice(
      primary: LightColor.darkVioleta,
      gradient: [
        Color.fromRGBO(94, 7, 114, 1.0),
        Color.fromRGBO(64, 4, 79, 1.0),
      ],
    ),
  ];
}