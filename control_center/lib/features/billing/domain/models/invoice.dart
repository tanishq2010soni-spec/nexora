import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

@freezed
class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    required String orgId,
    required String subscriptionId,
    required double amount,
    required String currency,
    required String status,
    String? invoiceUrl,
    DateTime? paidAt,
    required DateTime createdAt,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
}
