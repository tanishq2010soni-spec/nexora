import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_manager.dart';
import '../auth/token_manager.dart';
import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';
import '../constants/api_constants.dart';

// Feature providers
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/dashboard/providers/dashboard_provider.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/analytics/providers/analytics_provider.dart';
import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/leads/providers/lead_provider.dart';
import '../../features/leads/data/datasources/lead_remote_datasource.dart';
import '../../features/customers/providers/customer_provider.dart';
import '../../features/customers/data/datasources/customer_remote_datasource.dart';
import '../../features/conversations/providers/conversation_provider.dart';
import '../../features/conversations/data/datasources/conversation_remote_datasource.dart';
import '../../features/inbox/providers/inbox_provider.dart';
import '../../features/inbox/data/datasources/inbox_remote_datasource.dart';
import '../../features/tasks/providers/tasks_provider.dart';
import '../../features/tasks/data/datasources/tasks_remote_datasource.dart';
import '../../features/calls/providers/calls_provider.dart';
import '../../features/calls/data/datasources/calls_remote_datasource.dart';
import '../../features/billing/providers/billing_provider.dart';
import '../../features/billing/data/datasources/billing_remote_datasource.dart';
import '../../features/team/providers/team_provider.dart';
import '../../features/team/data/datasources/team_remote_datasource.dart';
import '../../features/notifications/providers/notifications_provider.dart';
import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../features/audit_logs/providers/audit_logs_provider.dart';
import '../../features/audit_logs/data/datasources/audit_logs_remote_datasource.dart';
import '../../features/knowledge_base/providers/knowledge_base_provider.dart';
import '../../features/knowledge_base/data/datasources/knowledge_base_remote_datasource.dart';
import '../../features/workflows/providers/workflows_provider.dart';
import '../../features/workflows/data/datasources/workflows_remote_datasource.dart';
import '../../features/agent_center/whatsapp_agents/providers/whatsapp_agent_provider.dart';
import '../../features/agent_center/whatsapp_agents/data/datasources/whatsapp_agent_remote_datasource.dart';
import '../../features/agent_center/calling_agents/providers/calling_agent_provider.dart';
import '../../features/agent_center/calling_agents/data/datasources/calling_agent_remote_datasource.dart';
import '../../features/agent_center/calling_agents/data/repositories/calling_agent_repository.dart';
import '../../features/agent_center/agent_templates/providers/template_provider.dart';
import '../../features/agent_center/agent_templates/data/datasources/template_remote_datasource.dart';
import '../../features/agent_center/agent_analytics/providers/analytics_provider.dart'
    as agent_analytics;
import '../../features/agent_center/agent_analytics/data/datasources/analytics_remote_datasource.dart'
    as agent_analytics_ds;
import '../../features/agent_center/agent_settings/providers/settings_provider.dart'
    as agent_settings;
import '../../features/agent_center/agent_settings/data/datasources/settings_remote_datasource.dart'
    as agent_settings_ds;
import '../../features/agent_center/agent_settings/data/repositories/settings_repository.dart'
    as agent_settings_repo;

// Phase 2 features — datasources and repositories
import '../../features/agent_management/agent_management_provider.dart';
import '../../features/agent_management/data/datasources/agent_management_remote_datasource.dart';
import '../../features/agent_management/data/repositories/agent_management_repository.dart';
import '../../features/model_registry/model_registry_provider.dart';
import '../../features/model_registry/data/datasources/model_registry_remote_datasource.dart';
import '../../features/model_registry/data/repositories/model_registry_repository.dart';
import '../../features/provider_management/provider_provider.dart';
import '../../features/provider_management/data/datasources/provider_remote_datasource.dart';
import '../../features/provider_management/data/repositories/provider_repository.dart';
import '../../features/knowledge_sources/knowledge_source_provider.dart';
import '../../features/knowledge_sources/data/datasources/knowledge_source_remote_datasource.dart';
import '../../features/knowledge_sources/data/repositories/knowledge_source_repository.dart';
import '../../features/workflow_engine/workflow_engine_provider.dart';
import '../../features/workflow_engine/data/datasources/workflow_engine_remote_datasource.dart';
import '../../features/workflow_engine/data/repositories/workflow_engine_repository.dart';
import '../../features/licensing/license_provider.dart';
import '../../features/licensing/data/datasources/license_remote_datasource.dart';
import '../../features/licensing/data/repositories/license_repository.dart';
import '../../features/plugin_sdk/plugin_provider.dart';
import '../../features/plugin_sdk/data/datasources/plugin_remote_datasource.dart';
import '../../features/plugin_sdk/data/repositories/plugin_repository.dart';
import '../../features/tool_registry/tool_registry_provider.dart';
import '../../features/tool_registry/data/datasources/tool_registry_remote_datasource.dart';
import '../../features/tool_registry/data/repositories/tool_registry_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenManager = ref.watch(tokenManagerProvider);
  return ApiClient(
    baseUrl: ApiConstants.fullBaseUrl,
    tokenProvider: () => tokenManager.getAccessToken(),
  );
});

List<Override> get providerOverrides => [
  // Core
  tokenManagerProvider.overrideWithValue(
    TokenManager(SecureStorageService.instance),
  ),

  // Auth
  authDatasourceProvider.overrideWith((ref) {
    return AuthRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Dashboard
  dashboardDatasourceProvider.overrideWith((ref) {
    return DashboardRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Audit Logs
  auditLogsDatasourceProvider.overrideWith((ref) {
    return AuditLogsRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Analytics
  analyticsDatasourceProvider.overrideWith((ref) {
    return AnalyticsRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Leads
  leadDatasourceProvider.overrideWith((ref) {
    return LeadRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Customers
  customerDatasourceProvider.overrideWith((ref) {
    return CustomerRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Conversations
  conversationDatasourceProvider.overrideWith((ref) {
    return ConversationRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Inbox
  inboxDatasourceProvider.overrideWith((ref) {
    return InboxRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Tasks
  tasksDatasourceProvider.overrideWith((ref) {
    return TasksRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Calls
  callsDatasourceProvider.overrideWith((ref) {
    return CallsRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Billing
  billingDatasourceProvider.overrideWith((ref) {
    return BillingRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Team
  teamDatasourceProvider.overrideWith((ref) {
    return TeamRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Notifications
  notificationsDatasourceProvider.overrideWith((ref) {
    return NotificationsRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Settings
  settingsDatasourceProvider.overrideWith((ref) {
    return SettingsRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Knowledge Base
  kbDatasourceProvider.overrideWith((ref) {
    return KnowledgeBaseRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Workflows
  workflowsDatasourceProvider.overrideWith((ref) {
    return WorkflowsRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Agent Center - WhatsApp
  whatsappAgentDatasourceProvider.overrideWith((ref) {
    return WhatsAppAgentRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Agent Center - Calling
  callingAgentDatasourceProvider.overrideWith((ref) {
    return CallingAgentRemoteDatasource(ref.read(apiClientProvider));
  }),
  callingAgentRepositoryProvider.overrideWith((ref) {
    return CallingAgentRepository(ref.read(callingAgentDatasourceProvider));
  }),

  // Agent Center - Templates
  templateDatasourceProvider.overrideWith((ref) {
    return TemplateRemoteDatasource(ref.read(apiClientProvider));
  }),

  // Agent Center - Analytics
  agent_analytics.agentAnalyticsDatasourceProvider.overrideWith((ref) {
    return agent_analytics_ds.AnalyticsRemoteDatasource(
      ref.read(apiClientProvider),
    );
  }),

  // Agent Center - Settings
  agent_settings.agentCenterSettingsDatasourceProvider.overrideWith((ref) {
    return agent_settings_ds.AgentCenterSettingsRemoteDatasource(
      ref.read(apiClientProvider),
    );
  }),
  agent_settings.agentCenterSettingsRepositoryProvider.overrideWith((ref) {
    return agent_settings_repo.AgentCenterSettingsRepository(
      ref.read(agent_settings.agentCenterSettingsDatasourceProvider),
    );
  }),

  // Phase 2 — Agent Management
  agentManagementDatasourceProvider.overrideWith((ref) {
    return AgentManagementRemoteDatasource(ref.read(apiClientProvider));
  }),
  agentManagementRepositoryProvider.overrideWith((ref) {
    return AgentManagementRepository(ref.read(agentManagementDatasourceProvider));
  }),

  // Phase 2 — Model Registry
  modelRegistryDatasourceProvider.overrideWith((ref) {
    return ModelRegistryRemoteDatasource(ref.read(apiClientProvider));
  }),
  modelRegistryRepositoryProvider.overrideWith((ref) {
    return ModelRegistryRepository(ref.read(modelRegistryDatasourceProvider));
  }),

  // Phase 2 — Provider Management
  providerDatasourceProvider.overrideWith((ref) {
    return ProviderRemoteDatasource(ref.read(apiClientProvider));
  }),
  providerRepositoryProvider.overrideWith((ref) {
    return ProviderRepository(ref.read(providerDatasourceProvider));
  }),

  // Phase 2 — Knowledge Sources
  knowledgeSourceDatasourceProvider.overrideWith((ref) {
    return KnowledgeSourceRemoteDatasource(ref.read(apiClientProvider));
  }),
  knowledgeSourceRepositoryProvider.overrideWith((ref) {
    return KnowledgeSourceRepository(ref.read(knowledgeSourceDatasourceProvider));
  }),

  // Phase 2 — Workflow Engine
  workflowEngineDatasourceProvider.overrideWith((ref) {
    return WorkflowEngineRemoteDatasource(ref.read(apiClientProvider));
  }),
  workflowEngineRepositoryProvider.overrideWith((ref) {
    return WorkflowEngineRepository(ref.read(workflowEngineDatasourceProvider));
  }),

  // Phase 2 — Licensing
  licenseDatasourceProvider.overrideWith((ref) {
    return LicenseRemoteDatasource(ref.read(apiClientProvider));
  }),
  licenseRepositoryProvider.overrideWith((ref) {
    return LicenseRepository(ref.read(licenseDatasourceProvider));
  }),

  // Phase 2 — Plugin SDK
  pluginDatasourceProvider.overrideWith((ref) {
    return PluginRemoteDatasource(ref.read(apiClientProvider));
  }),
  pluginRepositoryProvider.overrideWith((ref) {
    return PluginRepository(ref.read(pluginDatasourceProvider));
  }),

  // Phase 2 — Tool Registry
  toolRegistryDatasourceProvider.overrideWith((ref) {
    return ToolRegistryRemoteDatasource(ref.read(apiClientProvider));
  }),
  toolRegistryRepositoryProvider.overrideWith((ref) {
    return ToolRegistryRepository(ref.read(toolRegistryDatasourceProvider));
  }),
];
