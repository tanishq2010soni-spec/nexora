import '../../../../core/network/api_result.dart';
import '../models/customer.dart';
import '../models/customer_activity.dart';
import '../models/customer_analytics.dart';
import '../models/customer_note.dart';

abstract class CustomerRepositoryInterface {
  Future<ApiResult<List<Customer>>> getCustomers({
    CustomerSegment? segment,
    String? search,
    String? assignedTo,
    int page = 1,
    int limit = 20,
  });

  Future<ApiResult<Customer>> getCustomer(String id);

  Future<ApiResult<Customer>> createCustomer(Customer customer);

  Future<ApiResult<Customer>> updateCustomer(String id, Customer customer);

  Future<ApiResult<void>> deleteCustomer(String id);

  Future<ApiResult<void>> deleteCustomers(List<String> ids);

  Future<ApiResult<Customer>> updateSegment(String id, CustomerSegment segment);

  Future<ApiResult<Customer>> assignCustomer(String id, String userId);

  Future<ApiResult<List<CustomerActivity>>> getActivities(String customerId);

  Future<ApiResult<CustomerNote>> addNote(String customerId, String content);

  Future<ApiResult<CustomerAnalytics>> getAnalytics();

  Future<ApiResult<List<Customer>>> searchCustomers(
    String query, {
    CustomerSegment? segment,
  });

  Future<ApiResult<String>> exportCsv({CustomerSegment? segment});
}
