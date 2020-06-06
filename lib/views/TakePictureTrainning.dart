import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'package:deleco/model/objects/Pod.dart';
import 'package:deleco/theme/color/LightColors.dart';
import 'package:path/path.dart';


class TakePictureTrainning extends StatefulWidget {
  final CameraDescription camera;
  static String pageName="/cameratrainning";
  final Pod podResource;
  final Directory dir;
  TakePictureTrainning({
    Key key,
    @required this.camera,
    @required this.podResource
    ,this.dir
  }) : super(key: key);

  @override
  TakePictureTrainningState createState() => TakePictureTrainningState();
}

class TakePictureTrainningState extends State<TakePictureTrainning> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {

    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _controller.initialize();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Captura'),backgroundColor: LightColor.violeta,),

      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.camera_alt),

          onPressed: (){
            _takePicture(context).then((val){
              if(val!=null){//can take the pic
                _showSnackToast("Guardada: $val");
                setState(() {
                  widget.podResource.listPicturesId.add(val);
                });
              }
            });
          }
      ),
    );
  }
  Future<String> _takePicture(context) async {

    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      final DateTime now = new DateTime.now();


      String concat=now.day.toString()+now.hour.toString()+now.minute.toString()+now.second.toString();

      Directory tempDir= new Directory(join(widget.dir.path,widget.podResource.stage));

      if(await tempDir.exists()==false){//Lo creamos
        tempDir.createSync(recursive: true);
      }

      final path = join(
        tempDir.path,
        '$concat.png',
      );

      print(path);
      // Attempt to take a picture and log where it's been saved.
      await _controller.takePicture(path);

      // If the picture was taken, display it on a new screen.
      return concat;
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
      return null;
    }
  }
  void _showSnackToast(hint) {
    FlutterFlexibleToast.showToast(
        message: hint,
        toastLength: Toast.LENGTH_SHORT,
        toastGravity: ToastGravity.BOTTOM,
        icon: ICON.INFO,
        radius: 100,
        elevation: 10,
        imageSize: 35,
        textColor: Colors.white,
        backgroundColor: Colors.black,
        timeInSeconds: 2);
  }
}


