import 'dart:io';
import 'package:flutter/material.dart';
import 'package:deleco/model/Choices.dart';
import 'package:deleco/theme/color/LightColors.dart';
import 'package:path/path.dart';

class DisplayPhoto extends StatefulWidget {
  final String imagePath;

  final List<String> paths;
  final String imageLabel;
  final Directory dir;

  const DisplayPhoto(
      {Key key,
      @required this.imagePath,
      @required this.imageLabel,
      this.paths,
      this.dir})
      : super(key: key);

  @override
  DisplayPhotoState createState() => DisplayPhotoState();
}

class DisplayPhotoState extends State<DisplayPhoto> {
  Choice _selectedChoice = qrInfoChoices[0]; // The app's "state".

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.imageLabel),
          backgroundColor: LightColor.violeta,
          actions: <Widget>[
            PopupMenuButton<Choice>(
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return qrInfoChoices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                      value: choice, child: Text(choice.title));
                }).toList();
              },
            ),
          ],
        ),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: new Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: Center(
                child: Image.file(File(join(
                  widget.dir.path,
                  '${widget.imagePath}.png',
                ))),
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _select(Choice choice) {
    if (choice == qrInfoChoices[0]) {
      _showDialog();
    }
    setState(() {
      _selectedChoice = choice;
    });
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Advertencia"),
          content: new Text("Se eliminara la foto"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Aceptar"),
              onPressed: () {
                setState(() {
                  widget.paths.removeWhere((p) => p == widget.imagePath);
                });
                final dir = Directory(join(
                  widget.dir.path,
                  '${widget.imagePath}.png',
                ));
                dir.deleteSync(recursive: true);
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
            new FlatButton(
              child: new Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

/*

join(
// Store the picture in the temp directory.
// Find the temp directory using the `path_provider` plugin.
dir.path,
'${widget.imagePath}.png',
)
*/
