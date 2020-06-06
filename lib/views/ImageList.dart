

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:deleco/theme/color/LightColors.dart';
import 'package:deleco/views/DisplayPhoto.dart';

class ImageList extends StatefulWidget {

  final List<String> listImagePaths;

  final Directory dir;
  ImageList({
    Key key,
    this.listImagePaths,
    this.dir
  }) : super(key: key);

  @override
  ImageListState createState()=>ImageListState();
}

class ImageListState extends State<ImageList>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(backgroundColor: LightColor.violeta,title: Text('${widget.listImagePaths.length} fotos'),),
      body: ListView.separated(
        padding: const EdgeInsets.all(10.0),
        itemCount: widget.listImagePaths.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: IconButton(icon:Icon(Icons.image,color: Colors.black,), onPressed: (){},color: LightColor.darkyellow,),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayPhoto(imagePath: widget.listImagePaths[index],imageLabel: "Visualizar",paths: widget.listImagePaths,dir: widget.dir,),
                ),
              );
            },
            title:Text(widget.listImagePaths[index]),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}