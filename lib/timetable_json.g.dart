// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SampleModel _$SampleModelFromJson(Map<String, dynamic> json) => SampleModel(
      textTraffic: json['textTraffic'] as String,
      iconTraffic: json['iconTraffic'] as String,
      iconDeparture: json['iconDeparture'] as String,
      iconDestination: json['iconDestination'] as String,
      timetable:
          (json['timetable'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SampleModelToJson(SampleModel instance) =>
    <String, dynamic>{
      'textTraffic': instance.textTraffic,
      'iconTraffic': instance.iconTraffic,
      'iconDeparture': instance.iconDeparture,
      'iconDestination': instance.iconDestination,
      'timetable': instance.timetable,
    };
