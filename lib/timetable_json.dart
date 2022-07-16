import 'package:json_annotation/json_annotation.dart';
part 'timetable_json.g.dart';

@JsonSerializable()
class SampleModel {
  SampleModel({
    required this.textTraffic,
    required this.iconTraffic,
    required this.iconDeparture,
    required this.iconDestination,
    required this.timetable
  });
  String textTraffic;
  String iconTraffic;
  String iconDeparture;
  String iconDestination;
  List<String> timetable;

  factory SampleModel.fromJson(Map<String, dynamic> json) =>
    _$SampleModelFromJson(json);

  Map<String, dynamic> toJson() => _$SampleModelToJson(this);
}