import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/customer_activity.dart';
import '../../domain/models/customer_analytics.dart';
import '../../domain/models/customer_note.dart';
import '../../domain/repositories/customer_repository_interface.dart';
import '../datasources/customer_remote_datasource.dart';
import '../mappers/customer_mapper.dart';

class CustomerRepository implements CustomerRepositoryInterface {
  final CustomerRemoteDatasource _datasource;

  const CustomerRepository(this._datasource);

  @override
  Future<ApiResult<List<Customer>>> getCustomers({
    CustomerSegment? segment,
    String? search,
    String? assignedTo,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _datasource.getCustomers(
        segment: segment?.name,
        search: search,
        assignedTo: assignedTo,
        page: page,
        limit: limit,
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data! as List;
        final customers = list
            .map(
              (e) =>
                  CustomerMapper.fromBackendResponse(e as Map<String, dynamic>),
            )
            .toList();
        return ApiSuccess(customers);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch customers'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Customer>> getCustomer(String id) async {
    try {
      final response = await _datasource.getCustomer(id);
      if (response.statusCode == 200 && response.data != null) {
        final customer = CustomerMapper.fromBackendResponse(response.data!);
        return ApiSuccess(customer);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch customer'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Customer>> createCustomer(Customer customer) async {
    try {
      return ApiError(
        ServerException('Create customer endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Customer>> updateCustomer(
    String id,
    Customer customer,
  ) async {
    try {
      final data = <String, dynamic>{};
      if (customer.name.isNotEmpty) data['name'] = customer.name;

      final response = await _datasource.updateCustomer(id, data);
      if (response.statusCode == 200 && response.data != null) {
        final updated = CustomerMapper.fromBackendResponse(response.data!);
        return ApiSuccess(updated);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to update customer'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteCustomer(String id) async {
    try {
      return ApiError(
        ServerException('Delete customer endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteCustomers(List<String> ids) async {
    try {
      return ApiError(
        ServerException('Bulk delete endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Customer>> updateSegment(
    String id,
    CustomerSegment segment,
  ) async {
    try {
      return ApiError(
        ServerException('Update segment endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Customer>> assignCustomer(String id, String userId) async {
    try {
      return ApiError(
        ServerException('Assign customer endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<CustomerActivity>>> getActivities(
    String customerId,
  ) async {
    try {
      return ApiError(
        ServerException('Activities endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<CustomerNote>> addNote(
    String customerId,
    String content,
  ) async {
    try {
      return ApiError(
        ServerException('Add note endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<CustomerAnalytics>> getAnalytics() async {
    try {
      return ApiError(
        ServerException('Analytics endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<Customer>>> searchCustomers(
    String query, {
    CustomerSegment? segment,
  }) async {
    try {
      return ApiError(
        ServerException('Search endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<String>> exportCsv({CustomerSegment? segment}) async {
    try {
      return ApiError(
        ServerException('Export CSV endpoint not available in backend'),
      );
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
