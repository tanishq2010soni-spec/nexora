import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan.freezed.dart';
part 'plan.g.dart';

@freezed
class Plan with _$Plan {
  const factory Plan({
    required String id,
    required String name,
    String? description,
    required double price,
    required String interval,
    @Default(<String>[]) List<String> features,
    @Default(false) bool isPopular,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
}
