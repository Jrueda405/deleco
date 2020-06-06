import 'package:flutter/material.dart';

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final Icon icon;
}

const List<Choice> qrInfoChoices = const <Choice>[
  const Choice(title: 'Eliminar', icon: Icon(Icons.delete)),
];


