part of 'Pod.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pod _$PodFromJson(Map<String, dynamic> json) {
  return Pod(
      json['id'] as String,
      json['type'] as String,
      json['stage'] as String,
      json['days'] as int,
      json['indexrip'] as double,
      json['diameter'] as double,
      json['length'] as double,
      json['beans'] as int,
      (json['enumpics'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$PodToJson(Pod instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'stage': instance.stage,
      'days': instance.days,
      'indexrip': instance.indexRip,
      'diameter': instance.diameter,
      'length': instance.length,
      'beans': instance.beans,
      'enumpics': instance.listPicturesId
    };
