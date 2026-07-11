import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/plan.dart';
import '../../domain/models/subscription.dart';
import '../../domain/models/invoice.dart';
import '../../domain/repositories/billing_repository_interface.dart';
import '../datasources/billing_remote_datasource.dart';

class BillingRepository implements BillingRepositoryInterface {
  final BillingRemoteDatasource _datasource;

  const BillingRepository(this._datasource);

  @override
  Future<ApiResult<List<Plan>>> getPlans() async {
    try {
      final response = await _datasource.getPlans();
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data! as List;
        final plans = list
            .map((e) => Plan.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(plans);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch plans'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Subscription>> getSubscription() async {
    try {
      final response = await _datasource.getSubscription();
      if (response.statusCode == 200 && response.data != null) {
        final sub = Subscription.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(sub);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch subscription'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Subscription>> createSubscription(String planId) async {
    try {
      final response = await _datasource.createSubscription(planId);
      if (response.statusCode == 200 && response.data != null) {
        final sub = Subscription.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(sub);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to create subscription'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> cancelSubscription() async {
    try {
      final response = await _datasource.cancelSubscription();
      if (response.statusCode == 200) {
        return const ApiSuccess(null);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to cancel subscription'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<Invoice>>> getInvoices() async {
    try {
      final response = await _datasource.getInvoices();
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data! as List;
        final invoices = list
            .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(invoices);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch invoices'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> getUsage() async {
    try {
      final response = await _datasource.getUsage();
      if (response.statusCode == 200 && response.data != null) {
        final usage = response.data! as Map<String, dynamic>;
        return ApiSuccess(usage);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch usage'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
