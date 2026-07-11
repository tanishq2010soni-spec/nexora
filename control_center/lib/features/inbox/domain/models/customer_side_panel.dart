import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_side_panel.freezed.dart';
part 'customer_side_panel.g.dart';

@freezed
class CustomerSidePanel with _$CustomerSidePanel {
  const factory CustomerSidePanel({
    required String customerId,
    required String name,
    String? phone,
    String? email,
    String? segment,
    String? notes,
    @Default(<String>[]) List<String> tags,
    @Default(0) int totalConversations,
    @Default(0) int totalMessages,
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
  }) = _CustomerSidePanel;

  factory CustomerSidePanel.fromJson(Map<String, dynamic> json) =>
      _$CustomerSidePanelFromJson(json);
}
