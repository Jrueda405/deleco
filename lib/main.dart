import 'dart:io';

import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:deleco/routes/Routes.dart';
import 'package:deleco/views/HomePage.dart';
import 'package:flutter/services.dart';
import 'helpers/PathHelper.dart';


CameraDescription firstCamera;
Directory appDirectory;
var labels, colors;

void main()async{
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  firstCamera = cameras.first;

  appDirectory= await getPath();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);


  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deleco',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: HomePage.pageName,
      routes: RouteHelper.getApplicationRoutes(firstCamera,appDirectory),
    );
  }

}

