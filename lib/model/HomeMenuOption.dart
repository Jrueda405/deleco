import 'package:flutter/material.dart';
import 'package:deleco/theme/color/ColorChoice.dart';

class HomeMenuOption {
  HomeMenuOption(String title, IconData icon,ColorChoice choice, Image img) {
    this.title = title;
    this.icon = icon;
    this.img=img;
    this.color = choice.primary;
    this.gradient = LinearGradient(colors: choice.gradient, begin: Alignment.bottomCenter, end: Alignment.topCenter);
  }
  
  String title;
  Color color;
  LinearGradient gradient;
  IconData icon;
  Image img;
}

List<HomeMenuOption> option = [
  HomeMenuOption("Escanear QR", Icons.remove_red_eye,ColorChoices.choices[0],Image.asset('assets/images/qrimage.png')),
  HomeMenuOption("Agregar recursos", Icons.add,ColorChoices.choices[1],Image.asset('assets/images/cocoaimage.png')),
  HomeMenuOption("Exportar datos", Icons.import_export,ColorChoices.choices[2],Image.asset('assets/images/firebaselogo.png')),
];