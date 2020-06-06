import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:deleco/views/HomePage.dart';



class RouteHelper {

  //main Routes
  static Map<String, WidgetBuilder> getApplicationRoutes(CameraDescription cam,Directory directory) {
    return <String, WidgetBuilder>{
      HomePage.pageName: (BuildContext context)=> HomePage(dir: directory,cameraDescription: cam,),
    };
  }
}
