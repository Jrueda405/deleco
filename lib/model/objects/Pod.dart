

import 'package:json_annotation/json_annotation.dart';

part 'pod.g.dart';

@JsonSerializable()

class Pod {
  
  String id;
  String type;
  String stage;
  int days;
  double indexRip;
  double diameter;
  double length;
  int beans;

  List<String> listPicturesId=new List();

  Pod.empty({this.stage,this.type});
  


  factory Pod.fromJson(Map<String, dynamic> json) => _$PodFromJson(json);

  Map<String, dynamic> toJson() => _$PodToJson(this);

  Pod(this.id, this.type, this.stage, this.days, this.indexRip,
      this.diameter, this.length, this.beans, this.listPicturesId);
}
