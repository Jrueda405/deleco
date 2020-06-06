import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:deleco/helpers/SharedPrefHelper.dart';
import 'package:deleco/model/objects/Pod.dart';
import 'package:deleco/theme/color/LightColors.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:deleco/views/ImageList.dart';
import 'package:deleco/views/TakePictureTrainning.dart';

class AddResources extends StatefulWidget {
  static String pageName = "/addresources";
  final CameraDescription cam;
  final List<Pod> pods;
  final Directory dir;

  AddResources({Key key, this.pods, @required this.cam, @required this.dir})
      : super(key: key);
  @override
  AddResourcesState createState() => new AddResourcesState();
}

enum PopBox { proCamera, insideCamera }

class AddResourcesState extends State<AddResources> {
  final String name = 'deleco'; //firebase

  String barcode = "";
  bool enabled = false;
  bool isChecked = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  final _controllerBeans = TextEditingController();
  final _controllerBrix = TextEditingController();
  final _controllerLength = TextEditingController();
  final _controllerDiameter = TextEditingController();
  final _controllerDays = TextEditingController();

  //
  Pod podResource;
  String dropdownValue = "TCS-01";
  String dropdownValueStage = "Inmaduro";

  //Bluetooth

  @override
  void initState() {
    super.initState();
    podResource =
        new Pod.empty(type: dropdownValue, stage: this.dropdownValueStage);
    //WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  Future<String> scan() async {
    String barcode = "";
    try {
      barcode = await BarcodeScanner.scan();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _showSnackToast("Asegurate de garantizar los permisos");
      } else {
        _showSnackToast("Ocurrió un error");
      }
    } on FormatException {
      //setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      //setState(() => this.barcode = 'Unknown error: $e');
    }
    return barcode;
  }

  @override
  void dispose() {
    _controllerBeans.dispose();
    _controllerLength.dispose();
    _controllerDiameter.dispose();
    _controllerBrix.dispose();
    _controllerDays.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LightColor.violeta,
        title: Text(barcode),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              //add the podResource to the persist list
              //id

              podResource.stage=dropdownValueStage;
              podResource.type=dropdownValue;
              if(dropdownValueStage!='Inmaduro'){
                podResource.length= num.tryParse(_controllerLength.text).toDouble();
                podResource.diameter= num.tryParse(_controllerDiameter.text).toDouble();
                podResource.indexRip= num.tryParse(_controllerBrix.text).toDouble();
                podResource.beans= num.tryParse(_controllerBeans.text).toInt();
              }
              podResource.days = num.tryParse(_controllerDays.text).toInt();

              widget.pods.add(podResource);
              SharedPrefHelper.persistData(widget.pods);
              //clearPod
              podResource =
                  new Pod.empty(stage: dropdownValueStage, type: dropdownValue);
              clearControllers();
              setState(() {});
              _showSnackToast("Guardado");
            },
          ),
        ],
      ),
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    SpaceSelector(
                        child: new DropdownButton<String>(
                          isExpanded: true,
                          value: dropdownValue,
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValue = newValue;
                              podResource.type = newValue;
                            });
                          },
                          items: <String>['TCS-01', 'TCS-06']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        label: "¿Qué variedad de cacao es?"),
                    SizedBox(height: 10.0),
                    SpaceSelector(
                        child: new DropdownButton<String>(
                          isExpanded: true,
                          value: dropdownValueStage,
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValueStage = newValue;
                              podResource.stage = newValue;
                            });
                          },
                          items: <String>['Inmaduro', 'Maduro', 'Sobremaduro']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        label: "¿En que stage se encuentra?"),
                    SizedBox(height: 10.0),
                    Container(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        margin: EdgeInsets.only(left: 4),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text("Dias")),
                    Row(children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Container(
                              decoration: _getShadowDecoration(),
                              child: Card(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding:
                                          EdgeInsets.only(left: 22, right: 22),
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            controller: _controllerDays,
                                          ),
                                        ),
                                      )
                                    ],
                                  ))))
                    ]),
                    SizedBox(height: 10.0),
                    dropdownValueStage == "Inmaduro"
                        ? SizedBox()
                        : Container(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        margin: EdgeInsets.only(left: 4),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text("Indice de madurez")),
                    dropdownValueStage == "Inmaduro"
                        ? SizedBox()
                        : Row(children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Container(
                              decoration: _getShadowDecoration(),
                              child: Card(
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 22, right: 22),
                                          child: TextField(
                                            keyboardType:
                                            TextInputType.number,
                                            textAlign: TextAlign.center,
                                            controller: _controllerBrix,
                                          ),
                                        ),
                                      )
                                    ],
                                  ))))
                    ]),
                    SizedBox(height: 10.0),
                    dropdownValueStage == "Inmaduro"
                        ? SizedBox()
                        : Container(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        margin: EdgeInsets.only(left: 4),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text("Numero de granos")),
                    dropdownValueStage == "Inmaduro"
                        ? SizedBox()
                        : Row(children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Container(
                              decoration: _getShadowDecoration(),
                              child: Card(
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 22, right: 22),
                                          child: TextField(
                                            keyboardType:
                                            TextInputType.number,
                                            textAlign: TextAlign.center,
                                            controller: _controllerBeans,
                                          ),
                                        ),
                                      )
                                    ],
                                  ))))
                    ]),
                    SizedBox(height: 10.0),

                    dropdownValueStage == "Inmaduro"
                        ? SizedBox():Container(
                        padding:
                        const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        margin: EdgeInsets.only(left: 4),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text("Longitud")),


                    dropdownValueStage == "Inmaduro"
                        ? SizedBox()
                        :  Row(children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Container(
                              decoration: _getShadowDecoration(),
                              child: Card(
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 22, right: 22),
                                          child: TextField(
                                            keyboardType:
                                            TextInputType.number,
                                            textAlign: TextAlign.center,
                                            controller: _controllerLength,
                                          ),
                                        ),
                                      )
                                    ],
                                  ))))
                    ]),

                    SizedBox(height: 10.0),

                    dropdownValueStage == "Inmaduro"?SizedBox():Container(
                        padding:
                        const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        margin: EdgeInsets.only(left: 4),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text("Diametro")),

                    dropdownValueStage == "Inmaduro"
                        ? SizedBox()
                        : Row(children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Container(
                              decoration: _getShadowDecoration(),
                              child: Card(
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 22, right: 22),
                                          child: TextField(
                                            keyboardType:
                                            TextInputType.number,
                                            textAlign: TextAlign.center,
                                            controller:
                                            _controllerDiameter,
                                          ),
                                        ),
                                      )
                                    ],
                                  ))))
                    ]),

                    SizedBox(height: 10.0),


                    Container(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        margin: EdgeInsets.only(left: 4),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text("Capturas")),
                    Row(children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Container(
                              decoration: _getShadowDecoration(),
                              child: Card(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding:
                                          EdgeInsets.only(left: 22, right: 22),
                                          child: IconButton(
                                            icon: Icon(Icons.add_a_photo),
                                            onPressed: () {
                                              //Call new UI and pass the podResource instance to modify the string list of pathImages
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TakePictureTrainning(
                                                        camera: widget.cam,
                                                        podResource: podResource,
                                                        dir: widget.dir,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                          EdgeInsets.only(left: 22, right: 22),
                                          child: IconButton(
                                            icon: Icon(Icons.remove_red_eye),

                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ImageList(
                                                    listImagePaths: podResource.listPicturesId,
                                                    dir: widget.dir,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  ))))
                    ]),
                    SizedBox(
                      height: 10.0,
                    ),


                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Position> getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  void _showSnackToast(hint) {
    FlutterFlexibleToast.showToast(
        message: hint,
        toastLength: Toast.LENGTH_LONG,
        toastGravity: ToastGravity.BOTTOM,
        icon: ICON.INFO,
        radius: 100,
        elevation: 10,
        imageSize: 35,
        textColor: Colors.white,
        backgroundColor: Colors.black,
        timeInSeconds: 2);
  }

  BoxDecoration _getShadowDecoration() {
    return BoxDecoration(
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black.withOpacity(0.06),
          spreadRadius: 4,
          offset: new Offset(0.0, 0.0),
          blurRadius: 10.0,
        ),
      ],
    );
  }

  void clearControllers() {
    _controllerDiameter.clear();
    _controllerLength.clear();
    _controllerBrix.clear();
    _controllerDiameter.clear();
    _controllerDays.clear();
  }
}

class SpaceSelector extends StatelessWidget {
  final buttonPadding = const EdgeInsets.fromLTRB(0, 8, 0, 0);
  final String label;
  final Widget child;

  SpaceSelector({@required this.label, @required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            alignment: AlignmentDirectional.centerStart,
            margin: EdgeInsets.only(left: 4),
            child: Text(label)),
        Padding(
          padding: buttonPadding,
          child: Container(
            decoration: _getShadowDecoration(),
            child: Card(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    child: Padding(
                  child: child,
                  padding: EdgeInsets.all(10),
                )),
              ],
            )),
          ),
        ),
      ],
    );
  }

  BoxDecoration _getShadowDecoration() {
    return BoxDecoration(
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black.withOpacity(0.06),
          spreadRadius: 4,
          offset: new Offset(0.0, 0.0),
          blurRadius: 10.0,
        ),
      ],
    );
  }
}
