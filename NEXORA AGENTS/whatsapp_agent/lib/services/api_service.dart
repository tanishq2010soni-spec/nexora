import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_result.dart';
import '../models/user.dart';
import '../models/organization.dart';
import '../models/whatsapp_account.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/lead.dart';
import '../models/customer.dart';
import '../models/knowledge_document.dart';
import '../models/workflow.dart';
import '../models/campaign.dart';
import '../models/analytics.dart';
import '../models/audit_log.dart';
import '../models/prompt_template.dart';
import '../models/department.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:8100/api/v1';

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<ApiResult<Map<String, dynamic>>> _get(String path,
      {Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse('$_baseUrl$path');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return ApiResult.fail('Network error: ${e.toString()}');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> _post(String path,
      {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResult.fail('Network error: ${e.toString()}');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> _put(String path,
      {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$path'),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResult.fail('Network error: ${e.toString()}');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> _patch(String path,
      {Map<String, dynamic>? body}) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl$path'),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResult.fail('Network error: ${e.toString()}');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> _delete(String path) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$path'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResult.fail('Network error: ${e.toString()}');
    }
  }

  ApiResult<Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.ok(body, statusCode: response.statusCode);
      }
      final error = body['detail'] as String? ??
          body['message'] as String? ??
          'Unknown error';
      return ApiResult.fail(error, statusCode: response.statusCode);
    } catch (e) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.ok(<String, dynamic>{}, statusCode: response.statusCode);
      }
      return ApiResult.fail('Error: ${response.statusCode}', statusCode: response.statusCode);
    }
  }

  // Auth
  Future<ApiResult<Map<String, dynamic>>> login(
      String email, String password) async {
    return _post('/auth/login', body: {
      'email': email,
      'password': password,
    });
  }

  Future<ApiResult<Map<String, dynamic>>> refreshToken(String refreshToken) async {
    return _post('/auth/refresh', body: {
      'refresh_token': refreshToken,
    });
  }

  Future<ApiResult<User>> getMe() async {
    final result = await _get('/auth/me');
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(User.fromJson(result.data!['user'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to get user');
  }

  // Organizations
  Future<ApiResult<List<Organization>>> getOrganizations() async {
    final result = await _get('/organizations');
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['organizations'] as List<dynamic>)
          .map((e) => Organization.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get organizations');
  }

  Future<ApiResult<Organization>> getOrganization(int id) async {
    final result = await _get('/organizations/$id');
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(Organization.fromJson(result.data!['organization'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to get organization');
  }

  Future<ApiResult<Organization>> updateOrganization(
      int id, Map<String, dynamic> data) async {
    final result = await _put('/organizations/$id', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(Organization.fromJson(result.data!['organization'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to update organization');
  }

  // WhatsApp
  Future<ApiResult<List<WhatsAppAccount>>> getWhatsAppAccounts() async {
    final result = await _get('/whatsapp/accounts');
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['accounts'] as List<dynamic>)
          .map((e) => WhatsAppAccount.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get accounts');
  }

  Future<ApiResult<WhatsAppAccount>> connectWhatsApp(
      Map<String, dynamic> config) async {
    final result = await _post('/whatsapp/connect', body: config);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          WhatsAppAccount.fromJson(result.data!['account'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to connect');
  }

  Future<ApiResult<void>> disconnectWhatsApp(int accountId) async {
    final result = await _post('/whatsapp/disconnect/$accountId');
    if (result.isSuccess) return ApiResult.ok(null);
    return ApiResult.fail(result.error ?? 'Failed to disconnect');
  }

  Future<ApiResult<String>> getQRCode(int accountId) async {
    final result = await _get('/whatsapp/qr/$accountId');
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(result.data!['qr_code'] as String);
    }
    return ApiResult.fail(result.error ?? 'Failed to get QR');
  }

  Future<ApiResult<Map<String, dynamic>>> getWhatsAppHealth(int accountId) async {
    return _get('/whatsapp/health/$accountId');
  }

  // Conversations
  Future<ApiResult<List<Conversation>>> getConversations(
      {Map<String, String>? filters}) async {
    final result = await _get('/conversations', queryParams: filters);
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['conversations'] as List<dynamic>)
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get conversations');
  }

  Future<ApiResult<Conversation>> getConversation(int id) async {
    final result = await _get('/conversations/$id');
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          Conversation.fromJson(result.data!['conversation'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to get conversation');
  }

  Future<ApiResult<Conversation>> updateConversation(
      int id, Map<String, dynamic> data) async {
    final result = await _patch('/conversations/$id', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          Conversation.fromJson(result.data!['conversation'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to update conversation');
  }

  Future<ApiResult<void>> assignConversation(int id, String agentEmail) async {
    final result =
        await _post('/conversations/$id/assign', body: {'agent_email': agentEmail});
    if (result.isSuccess) return ApiResult.ok(null);
    return ApiResult.fail(result.error ?? 'Failed to assign');
  }

  Future<ApiResult<void>> archiveConversation(int id) async {
    final result = await _post('/conversations/$id/archive');
    if (result.isSuccess) return ApiResult.ok(null);
    return ApiResult.fail(result.error ?? 'Failed to archive');
  }

  Future<ApiResult<List<Message>>> getMessages(int conversationId) async {
    final result = await _get('/conversations/$conversationId/messages');
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get messages');
  }

  Future<ApiResult<Message>> sendMessage(
      int conversationId, String content) async {
    final result = await _post('/conversations/$conversationId/messages',
        body: {'content': content});
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          Message.fromJson(result.data!['message'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to send message');
  }

  Future<ApiResult<void>> requestHandoff(int conversationId) async {
    final result = await _post('/conversations/$conversationId/handoff');
    if (result.isSuccess) return ApiResult.ok(null);
    return ApiResult.fail(result.error ?? 'Failed to request handoff');
  }

  Future<ApiResult<void>> resumeAI(int conversationId) async {
    final result = await _post('/conversations/$conversationId/resume-ai');
    if (result.isSuccess) return ApiResult.ok(null);
    return ApiResult.fail(result.error ?? 'Failed to resume AI');
  }

  // CRM - Leads
  Future<ApiResult<List<Lead>>> getLeads({Map<String, String>? filters}) async {
    final result = await _get('/crm/leads', queryParams: filters);
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['leads'] as List<dynamic>)
          .map((e) => Lead.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get leads');
  }

  Future<ApiResult<Lead>> createLead(Map<String, dynamic> data) async {
    final result = await _post('/crm/leads', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          Lead.fromJson(result.data!['lead'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to create lead');
  }

  Future<ApiResult<Lead>> updateLead(int id, Map<String, dynamic> data) async {
    final result = await _put('/crm/leads/$id', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          Lead.fromJson(result.data!['lead'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to update lead');
  }

  Future<ApiResult<Customer>> convertLead(int id, Map<String, dynamic> data) async {
    final result = await _post('/crm/leads/$id/convert', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          Customer.fromJson(result.data!['customer'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to convert lead');
  }

  // CRM - Customers
  Future<ApiResult<List<Customer>>> getCustomers(
      {Map<String, String>? filters}) async {
    final result = await _get('/crm/customers', queryParams: filters);
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['customers'] as List<dynamic>)
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get customers');
  }

  // Knowledge
  Future<ApiResult<List<KnowledgeDocument>>> getKnowledgeDocuments(
      {Map<String, String>? filters}) async {
    final result = await _get('/knowledge', queryParams: filters);
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['documents'] as List<dynamic>)
          .map((e) => KnowledgeDocument.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get documents');
  }

  Future<ApiResult<KnowledgeDocument>> uploadKnowledge(
      Map<String, dynamic> data) async {
    final result = await _post('/knowledge/upload', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(KnowledgeDocument.fromJson(
          result.data!['document'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to upload document');
  }

  Future<ApiResult<void>> deleteKnowledge(int id) async {
    final result = await _delete('/knowledge/$id');
    if (result.isSuccess) return ApiResult.ok(null);
    return ApiResult.fail(result.error ?? 'Failed to delete document');
  }

  Future<ApiResult<String>> queryKnowledge(String query) async {
    final result = await _post('/knowledge/query', body: {'query': query});
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(result.data!['answer'] as String);
    }
    return ApiResult.fail(result.error ?? 'Failed to query knowledge');
  }

  // Workflows
  Future<ApiResult<List<Workflow>>> getWorkflows() async {
    final result = await _get('/workflows');
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['workflows'] as List<dynamic>)
          .map((e) => Workflow.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get workflows');
  }

  Future<ApiResult<Workflow>> createWorkflow(Map<String, dynamic> data) async {
    final result = await _post('/workflows', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          Workflow.fromJson(result.data!['workflow'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to create workflow');
  }

  Future<ApiResult<Workflow>> updateWorkflow(
      int id, Map<String, dynamic> data) async {
    final result = await _put('/workflows/$id', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          Workflow.fromJson(result.data!['workflow'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to update workflow');
  }

  Future<ApiResult<void>> deleteWorkflow(int id) async {
    final result = await _delete('/workflows/$id');
    if (result.isSuccess) return ApiResult.ok(null);
    return ApiResult.fail(result.error ?? 'Failed to delete workflow');
  }

  Future<ApiResult<Map<String, dynamic>>> testWorkflow(int id) async {
    return _post('/workflows/$id/test');
  }

  Future<ApiResult<List<WorkflowExecution>>> getWorkflowExecutions(
      int workflowId) async {
    final result = await _get('/workflows/$workflowId/executions');
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['executions'] as List<dynamic>)
          .map((e) => WorkflowExecution.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get executions');
  }

  // Campaigns
  Future<ApiResult<List<Campaign>>> getCampaigns() async {
    final result = await _get('/campaigns');
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['campaigns'] as List<dynamic>)
          .map((e) => Campaign.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get campaigns');
  }

  Future<ApiResult<Campaign>> createCampaign(Map<String, dynamic> data) async {
    final result = await _post('/campaigns', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          Campaign.fromJson(result.data!['campaign'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to create campaign');
  }

  Future<ApiResult<Campaign>> updateCampaign(
      int id, Map<String, dynamic> data) async {
    final result = await _put('/campaigns/$id', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          Campaign.fromJson(result.data!['campaign'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to update campaign');
  }

  Future<ApiResult<void>> sendCampaign(int id) async {
    final result = await _post('/campaigns/$id/send');
    if (result.isSuccess) return ApiResult.ok(null);
    return ApiResult.fail(result.error ?? 'Failed to send campaign');
  }

  Future<ApiResult<void>> pauseCampaign(int id) async {
    final result = await _post('/campaigns/$id/pause');
    if (result.isSuccess) return ApiResult.ok(null);
    return ApiResult.fail(result.error ?? 'Failed to pause campaign');
  }

  // Analytics
  Future<ApiResult<AnalyticsOverview>> getAnalyticsOverview(
      {String? startDate, String? endDate}) async {
    final params = <String, String>{};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    final result = await _get('/analytics/overview', queryParams: params);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          AnalyticsOverview.fromJson(result.data!['overview'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to get analytics');
  }

  Future<ApiResult<MetricsResponse>> getMetrics(
      {String? startDate, String? endDate}) async {
    final params = <String, String>{};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    final result = await _get('/analytics/metrics', queryParams: params);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          MetricsResponse.fromJson(result.data!['metrics'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to get metrics');
  }

  // Settings
  Future<ApiResult<Map<String, dynamic>>> getSettings(int orgId) async {
    return _get('/settings/$orgId');
  }

  Future<ApiResult<Map<String, dynamic>>> updateSettings(
      int orgId, Map<String, dynamic> data) async {
    return _put('/settings/$orgId', body: data);
  }

  Future<ApiResult<List<PromptTemplate>>> getPromptTemplates() async {
    final result = await _get('/settings/prompts');
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['prompts'] as List<dynamic>)
          .map((e) => PromptTemplate.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get prompts');
  }

  Future<ApiResult<PromptTemplate>> createPromptTemplate(
      Map<String, dynamic> data) async {
    final result = await _post('/settings/prompts', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(PromptTemplate.fromJson(
          result.data!['prompt'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to create prompt');
  }

  Future<ApiResult<PromptTemplate>> updatePromptTemplate(
      int id, Map<String, dynamic> data) async {
    final result = await _put('/settings/prompts/$id', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(PromptTemplate.fromJson(
          result.data!['prompt'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to update prompt');
  }

  Future<ApiResult<void>> deletePromptTemplate(int id) async {
    final result = await _delete('/settings/prompts/$id');
    if (result.isSuccess) return ApiResult.ok(null);
    return ApiResult.fail(result.error ?? 'Failed to delete prompt');
  }

  // Permissions
  Future<ApiResult<List<User>>> getUsers() async {
    final result = await _get('/permissions/users');
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['users'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get users');
  }

  Future<ApiResult<void>> updateUserPermissions(
      int userId, List<String> permissions) async {
    final result =
        await _put('/permissions/users/$userId', body: {'permissions': permissions});
    if (result.isSuccess) return ApiResult.ok(null);
    return ApiResult.fail(result.error ?? 'Failed to update permissions');
  }

  Future<ApiResult<List<String>>> getAvailablePermissions() async {
    final result = await _get('/permissions/available');
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get permissions');
  }

  // Logs
  Future<ApiResult<List<AuditLog>>> getLogs(
      {Map<String, String>? filters}) async {
    final result = await _get('/logs', queryParams: filters);
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['logs'] as List<dynamic>)
          .map((e) => AuditLog.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get logs');
  }

  Future<ApiResult<AuditLog>> createLogEntry(Map<String, dynamic> data) async {
    final result = await _post('/logs', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          AuditLog.fromJson(result.data!['log'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to create log');
  }

  // Inbox / Departments
  Future<ApiResult<Map<String, dynamic>>> getInboxOverview() async {
    return _get('/inbox/overview');
  }

  Future<ApiResult<List<Department>>> getDepartments() async {
    final result = await _get('/inbox/departments');
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['departments'] as List<dynamic>)
          .map((e) => Department.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get departments');
  }

  Future<ApiResult<Department>> createDepartment(Map<String, dynamic> data) async {
    final result = await _post('/inbox/departments', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          Department.fromJson(result.data!['department'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to create department');
  }

  Future<ApiResult<Department>> updateDepartment(
      int id, Map<String, dynamic> data) async {
    final result = await _put('/inbox/departments/$id', body: data);
    if (result.isSuccess && result.data != null) {
      return ApiResult.ok(
          Department.fromJson(result.data!['department'] as Map<String, dynamic>));
    }
    return ApiResult.fail(result.error ?? 'Failed to update department');
  }

  // Health
  Future<ApiResult<Map<String, dynamic>>> getHealth() async {
    return _get('/health');
  }

  // Plugins
  Future<ApiResult<List<Map<String, dynamic>>>> getPlugins() async {
    final result = await _get('/plugins');
    if (result.isSuccess && result.data != null) {
      final list = (result.data!['plugins'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      return ApiResult.ok(list);
    }
    return ApiResult.fail(result.error ?? 'Failed to get plugins');
  }

  Future<ApiResult<Map<String, dynamic>>> installPlugin(
      Map<String, dynamic> data) async {
    return _post('/plugins/install', body: data);
  }

  Future<ApiResult<void>> togglePlugin(int id, bool enabled) async {
    final result = await _post('/plugins/$id/toggle', body: {'enabled': enabled});
    if (result.isSuccess) return ApiResult.ok(null);
    return ApiResult.fail(result.error ?? 'Failed to toggle plugin');
  }

  Future<ApiResult<Map<String, dynamic>>> updatePluginConfig(
      int id, Map<String, dynamic> config) async {
    return _put('/plugins/$id/config', body: config);
  }
}
