import '../../../../core/network/api_result.dart';
import '../models/plan.dart';
import '../models/subscription.dart';
import '../models/invoice.dart';

abstract class BillingRepositoryInterface {
  Future<ApiResult<List<Plan>>> getPlans();

  Future<ApiResult<Subscription>> getSubscription();

  Future<ApiResult<Subscription>> createSubscription(String planId);

  Future<ApiResult<void>> cancelSubscription();

  Future<ApiResult<List<Invoice>>> getInvoices();

  Future<ApiResult<Map<String, dynamic>>> getUsage();
}
