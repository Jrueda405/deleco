import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:deleco/model/objects/Pod.dart';
import 'package:deleco/views/AddResources.dart';
import 'package:deleco/views/QrScanningInfo.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:connectivity/connectivity.dart';
import 'package:deleco/helpers/SharedPrefHelper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:deleco/model/HomeMenuOption.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';



class HomePage extends StatefulWidget {
  HomePage({Key key,@required this.cameraDescription, @required this.dir}) : super(key: key);
  static final String pageName="/";
  final CameraDescription cameraDescription;
  final Directory dir;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  ScrollController scrollController;


  List<Pod> listOfPods;
  final databaseReference = FirebaseDatabase.instance.reference();

  bool _isConnected;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Color backgroundColor;
  LinearGradient backgroundGradient;
  Tween<Color> colorTween;

  int page;
  @override
  void initState() {
    super.initState();
    colorTween = ColorTween(begin: option[0].color, end: option[1].color);
    backgroundColor = option[0].color;
    backgroundGradient = option[0].gradient;
    scrollController = ScrollController();
    scrollController.addListener(() {
      ScrollPosition position = scrollController.position;
//      ScrollDirection direction = position.userScrollDirection;
      page = position.pixels ~/ (position.maxScrollExtent / (option.length.toDouble() - 1));
      double pageDo = (position.pixels / (position.maxScrollExtent / (option.length.toDouble() - 1)));
      double percent = pageDo - page;
      if (option.length - 1 < page + 1) {
        return;
      }
      colorTween.begin = option[page].color;
      colorTween.end = option[page + 1].color;
      setState(() {
        backgroundColor = colorTween.transform(percent);
        backgroundGradient = option[page].gradient.lerpTo(option[page + 1].gradient, percent);
      });
    });

    listOfPods = new List();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => SharedPrefHelper.getData().then((val) {
      if (val != null) {
        json
            .decode(val)
            .forEach((map) => listOfPods.add(new Pod.fromJson(map)));
      }
    }));

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);


  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }


  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return Future.value(null);
    }
  }

  Future<String> scan() async {
    String barcode;
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

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(gradient: backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text("Deleco"),
          centerTitle: true,
          actions: <Widget>[],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            Spacer(),
            Expanded(
              flex: 20,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  HomeMenuOption op = option[index];
                  return Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 30.0),
                    child: InkWell(
                      enableFeedback: true,
                      onTap: () {
                        switch(index){
                          case 0:
                            scan().then((qr) {
                              if (qr != null) {
                                if (qr.contains("TCS")) {
                                  int index;
                                  index = listOfPods.indexWhere((pod) => pod.id == qr);
                                  if (index >= 0) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QrScanningInfo(
                                          currentPod: listOfPods[index],
                                          pods: listOfPods,
                                        ),
                                      ),
                                    );
                                  } else {
                                    _showSnackToast("Mazorca aun no registrada");
                                  }
                                  //Navigator.push(context, QrScanningInfo.pageName);
                                } else {
                                  _showSnackToast("No es un un QR de deleco");
                                }
                              }
                            });
                            break;
                          case 1:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddResources(
                                  pods: listOfPods,
                                  cam: widget.cameraDescription,
                                  dir: widget.dir,
                                ),
                              ),
                            );
                            break;
                          case 2:
                            if (_isConnected == true) {
                              //firebase
                              createRecord();
                            } else {
                              Clipboard.setData(
                                  new ClipboardData(text: jsonEncode(listOfPods)));
                              _showSnackToast("JSON copiado al portapapeles");
                            }
                            break;
                          default:
                            break;
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), boxShadow: [BoxShadow(color: Colors.black.withAlpha(70), offset: Offset(3.0, 10.0), blurRadius: 15.0)]),
                        height: height/3,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,//estaba en blanco
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column( //card content
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    flex: 10,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Stack(
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.grey.withAlpha(70), style: BorderStyle.solid, width: 1.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(op.icon, color: op.color),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  op.img,//Image Widget
                                  Spacer(),

                                  Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      op.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 30.0, color: Colors.black),
                                      softWrap: false,
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.only(left: 40.0, right: 40.0),
                scrollDirection: Axis.horizontal,
                physics: _CustomScrollPhysics(),
                controller: scrollController,
                itemExtent: _width - 80,
                itemCount: option.length,
              ),
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile) {
      setState(() {
        _isConnected = true;
      });
    } else {
      setState(() {
        _isConnected = false;
      });
    }
  }

  void createRecord() {
    if (listOfPods.length < 1) {
      _showSnackToast("No hay nada por subir");
    } else {
      for (int i = 0; i < listOfPods.length; i++) {
        Pod p = listOfPods[i];
        databaseReference.child('pods').child(p.stage).push().set(p.toJson());
      }
      listOfPods.clear();
      SharedPrefHelper.persistData(listOfPods);

      widget.dir.exists().then((exist) {
        widget.dir.deleteSync(recursive: true);
      });
    }
  }
}

class _CustomScrollPhysics extends ScrollPhysics {
  _CustomScrollPhysics({
    ScrollPhysics parent,
  }) : super(parent: parent);

  @override
  _CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return _CustomScrollPhysics(parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    return position.pixels / (position.maxScrollExtent / (option.length.toDouble() - 1));
    // return position.pixels / position.viewportDimension;
  }

  double _getPixels(ScrollPosition position, double page) {
    // return page * position.viewportDimension;
    return page * (position.maxScrollExtent / (option.length.toDouble() - 1));
  }

  double _getTargetPixels(ScrollPosition position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity)
      page -= 0.5;
    else if (velocity > tolerance.velocity) page += 0.5;
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) || (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) return ScrollSpringSimulation(spring, position.pixels, target, velocity, tolerance: tolerance);
    return null;
  }
}