import 'package:freezed_annotation/freezed_annotation.dart';

part 'available_model.freezed.dart';
part 'available_model.g.dart';

@freezed
class AvailableModel with _$AvailableModel {
  const factory AvailableModel({
    required String id,
    required String name,
    required String provider,
    String? description,
    String? size,
    @Default(true) bool isAvailable,
  }) = _AvailableModel;

  factory AvailableModel.fromJson(Map<String, dynamic> json) =>
      _$AvailableModelFromJson(json);
}
