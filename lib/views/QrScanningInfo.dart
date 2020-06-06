import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deleco/helpers/SharedPrefHelper.dart';
import 'package:deleco/model/Choices.dart';
import 'package:deleco/model/objects/Pod.dart';
import 'dart:ui' as ui;

import 'package:deleco/theme/color/LightColors.dart';



class QrScanningInfo extends StatefulWidget{
  QrScanningInfo({Key key, @required this.currentPod,@required this.pods}) : super(key: key);
  static String pageName = "/qrinfo";
  static String appBar="QR Scanning";
  final Pod currentPod;
  final List<Pod> pods;
  @override
  QrScanningInfoState createState() => QrScanningInfoState();

}
class QrScanningInfoState extends State<QrScanningInfo>{

  Choice _selectedChoice = qrInfoChoices[0]; // The app's "state".
  bool allowEdit=false;
  String dropdownValueType;
  String dropdownValueStage;

  final _controllerTemp = TextEditingController();
  final _controllerHum = TextEditingController();
  final _controllerLumi = TextEditingController();

  @override
  void initState() {
    super.initState();
    dropdownValueType=widget.currentPod.type;
    dropdownValueStage=widget.currentPod.stage;

  }

  void _select(Choice choice) {

    if(choice==qrInfoChoices[0]){
      _showDialog();
    }
    setState(() {
      _selectedChoice = choice;
    });

  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Advertencia"),
          content: new Text("Se eliminara la mazorca"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Aceptar"),
              onPressed: () {
                widget.pods.remove(widget.currentPod);
                Navigator.of(context).pop();
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
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return new Stack(children: <Widget>[
      new Container(color: Colors.white,),
      new BackdropFilter(
          filter: new ui.ImageFilter.blur(
            sigmaX: 6.0,
            sigmaY: 6.0,
          ),
          child: new Container(
            decoration: BoxDecoration(
              color:  Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),)),
      new Scaffold(
          floatingActionButton:  FloatingActionButton.extended(onPressed: () {
            setState(() {
              allowEdit=!allowEdit;
              if(allowEdit==false){//user have finished edit

                SharedPrefHelper.persistData(widget.pods);
              }
            });
          },icon: allowEdit==false?Icon(Icons.edit):Icon(Icons.save),backgroundColor: LightColor.darkVioleta, label: Text(allowEdit==false?"Editar":"Guardar"),),
          appBar: new AppBar(
            title: new Text("Mazorca"),
            centerTitle: false,
            elevation: 0.0,
            backgroundColor: LightColor.violeta,
            actions: <Widget>[
            PopupMenuButton<Choice>(
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return qrInfoChoices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Text(choice.title)
                  );
                }).toList();
              },
            ),

          ],
          ),
          backgroundColor: Colors.transparent,
          body: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                new SizedBox(height: _height/12,),
                new CircleAvatar(radius:_width<_height? _width/4:_height/4,child: Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.photo,size: _width/22,color: Colors.white,),Text('TCS-01-001', style: new TextStyle(fontWeight: FontWeight.bold, fontSize: _width/22, color: Colors.white),)],),backgroundColor: LightColor.darkGreen,),
                new SizedBox(height: _height/25.0,),
                new Text(widget.currentPod.id, style: new TextStyle(fontWeight: FontWeight.bold, fontSize: _width/15, color: Colors.black),),
                /*new Padding(padding: new EdgeInsets.only(top: _height/30, left: _width/8, right: _width/8),
                  child:new Text('Snowboarder, Superhero and writer.\nSometime I work at google as Executive Chairman ',
                    style: new TextStyle(fontWeight: FontWeight.normal, fontSize: _width/25,color: Colors.white),textAlign: TextAlign.center,) ,),*/
                new Divider(height: _height/30,color: Colors.black,),
                new Row(
                  children: <Widget>[
                    allowEdit==false?rowCell(label: 'Variedad',inputText: widget.currentPod.type,controller: null):Expanded(child: new Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: dropdownValueType,
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValueType = newValue;
                              widget.currentPod.type=newValue;
                            });
                          },
                          items: <String>['TCS-01', 'TCS-06']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          })
                              .toList(),
                        ),
                      ),
                      new Text('Variedad',style: new TextStyle(color: Colors.black, fontWeight: FontWeight.normal))
                    ],)),
                    //Separator
                    allowEdit==false?rowCell(label: 'Estado',inputText: widget.currentPod.stage,controller: null):Expanded(child: new Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: DropdownButton<String>(
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
                              widget.currentPod.stage=newValue;
                            });
                          },
                          items: <String>['Inmaduro', 'Medio-maduro','Maduro']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          })
                              .toList(),
                        ),
                      ),
                      new Text('Estado',style: new TextStyle(color: Colors.black, fontWeight: FontWeight.normal))
                    ],)),

                  ],),
                new Divider(height: _height/30,color: Colors.black),
                new Row(
                  children: <Widget>[

                  ],),
                new Divider(height: _height/30,color: Colors.black),
                new Row(
                  children: <Widget>[
                    rowCell(label: 'Humedad',inputText: widget.currentPod.stage,controller: _controllerHum),
                    rowCell(label: 'Luz',inputText: widget.currentPod.stage,controller: _controllerLumi),
                  ],),
                new Divider(height: _height/30,color: Colors.black),
              ],
            ),
          )
      )
    ],);
  }

  Widget rowCellLocked(String info, String description) => new Expanded(child: new Column(children: <Widget>[
    new Text('$info',style: new TextStyle(color: Colors.black),),
    new Text(description,style: new TextStyle(color: Colors.black, fontWeight: FontWeight.normal))
  ],));

  Widget rowCellUnlocked(String description, TextEditingController _controller) => new Expanded(child: new Column(children: <Widget>[
    Padding(child: new TextField(controller: _controller,), padding: EdgeInsets.all(10),),
    new Text(description,style: new TextStyle(color: Colors.black, fontWeight: FontWeight.normal))
  ],));



  Widget rowCell ({String inputText,String label, TextEditingController controller}){
    if(allowEdit==false){
      return rowCellLocked(inputText, label);
    }else{
      return rowCellUnlocked(label, controller);
    }
  }
@override
  void dispose() {
    super.dispose();
  }


}

