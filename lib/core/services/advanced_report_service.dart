import '../models/api_response.dart';
import 'package:logger/logger.dart';
import '../models/report_template.dart';
import 'api_service.dart';

class AdvancedReportService {
 final ApiService _apiService = ApiService();
 static const String _baseUrl = '/advanced-reports';

 // Report Templates Management
 Future<ApiResponse<List<ReportTemplate>>> getReportTemplates({
 String? category,
 ReportType? type,
 bool? isPublic,
 bool? isActive,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 if (category != null) q{ueryParams['category'] = category;
 if (type != null) q{ueryParams['type'] = type.name;
 if (isPublic != null) q{ueryParams['is_public'] = isPublic.toString();
 if (isActive != null) q{ueryParams['is_active'] = isActive.toString();

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/templates',
 queryParameters: queryParams,
 );
 
 if (response.success) {
 final List<String> data = response.data!['templates'];
 final templates = data.map((json) => ReportTemplate.fromJson(json)).toList();
 return ApiResponse.success(
 data: templates,
 message: response.message ?? 'Report templates retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve report templates',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving report templates: $e');
}
 }

 Future<ApiResponse<ReportTemplate>> getReportTemplateById(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/templates/$id',
 );
 
 if (response.success) {
 final template = ReportTemplate.fromJson(response.data!);
 return ApiResponse.success(
 data: template,
 message: response.message ?? 'Report template retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve report template',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving report template: $e');
}
 }

 Future<ApiResponse<ReportTemplate>> createReportTemplate(Map<String, dynamic> data) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/templates',
 data: data,
 );
 
 if (response.success) {
 final template = ReportTemplate.fromJson(response.data!);
 return ApiResponse.success(
 data: template,
 message: response.message ?? 'Report template created successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to create report template',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error creating report template: $e');
}
 }

 Future<ApiResponse<ReportTemplate>> updateReportTemplate(String id, Map<String, dynamic> data) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put<Map<String, dynamic>>(
 '$_baseUrl/templates/$id',
 data: data,
 );
 
 if (response.success) {
 final template = ReportTemplate.fromJson(response.data!);
 return ApiResponse.success(
 data: template,
 message: response.message ?? 'Report template updated successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to update report template',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error updating report template: $e');
}
 }

 Future<ApiResponse<bool>> deleteReportTemplate(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.delete<Map<String, dynamic>>(
 '$_baseUrl/templates/$id',
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: true,
 message: response.message ?? 'Report template deleted successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to delete report template',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error deleting report template: $e');
}
 }

 // Scheduled Reports Management
 Future<ApiResponse<List<ScheduledReport>>> getScheduledReports({
 String? templateId,
 ScheduleType? scheduleType,
 bool? isActive,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 if (templateId != null) q{ueryParams['template_id'] = templateId;
 if (scheduleType != null) q{ueryParams['schedule_type'] = scheduleType.name;
 if (isActive != null) q{ueryParams['is_active'] = isActive.toString();

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/scheduled-reports',
 queryParameters: queryParams,
 );
 
 if (response.success) {
 final List<String> data = response.data!['scheduled_reports'];
 final scheduledReports = data.map((json) => ScheduledReport.fromJson(json)).toList();
 return ApiResponse.success(
 data: scheduledReports,
 message: response.message ?? 'Scheduled reports retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve scheduled reports',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving scheduled reports: $e');
}
 }

 Future<ApiResponse<ScheduledReport>> createScheduledReport(Map<String, dynamic> data) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/scheduled-reports',
 data: data,
 );
 
 if (response.success) {
 final scheduledReport = ScheduledReport.fromJson(response.data!);
 return ApiResponse.success(
 data: scheduledReport,
 message: response.message ?? 'Scheduled report created successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to create scheduled report',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error creating scheduled report: $e');
}
 }

 Future<ApiResponse<ScheduledReport>> updateScheduledReport(String id, Map<String, dynamic> data) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.put<Map<String, dynamic>>(
 '$_baseUrl/scheduled-reports/$id',
 data: data,
 );
 
 if (response.success) {
 final scheduledReport = ScheduledReport.fromJson(response.data!);
 return ApiResponse.success(
 data: scheduledReport,
 message: response.message ?? 'Scheduled report updated successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to update scheduled report',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error updating scheduled report: $e');
}
 }

 Future<ApiResponse<bool>> toggleScheduledReport(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/scheduled-reports/$id/toggle',
 data: {},
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: true,
 message: response.message ?? 'Scheduled report toggled successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to toggle scheduled report',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error toggling scheduled report: $e');
}
 }

 // Report Execution
 Future<ApiResponse<ReportExecution>> executeReport(String templateId, Map<String, dynamic> parameters) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/execute',
 data: {
 'template_id': templateId,
 'parameters': parameters,
 },
 );
 
 if (response.success) {
 final execution = ReportExecution.fromJson(response.data!);
 return ApiResponse.success(
 data: execution,
 message: response.message ?? 'Report execution started successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to execute report',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error executing report: $e');
}
 }

 Future<ApiResponse<List<ReportExecution>>> getReportExecutions({
 String? templateId,
 ExecutionStatus? status,
 DateTime? startDate,
 DateTime? endDate,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 if (templateId != null) q{ueryParams['template_id'] = templateId;
 if (status != null) q{ueryParams['status'] = status.name;
 if (startDate != null) q{ueryParams['start_date'] = startDate.toIso8601String();
 if (endDate != null) q{ueryParams['end_date'] = endDate.toIso8601String();

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/executions',
 queryParameters: queryParams,
 );
 
 if (response.success) {
 final List<String> data = response.data!['executions'];
 final executions = data.map((json) => ReportExecution.fromJson(json)).toList();
 return ApiResponse.success(
 data: executions,
 message: response.message ?? 'Report executions retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve report executions',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving report executions: $e');
}
 }

 Future<ApiResponse<ReportExecution>> getExecutionById(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/executions/$id',
 );
 
 if (response.success) {
 final execution = ReportExecution.fromJson(response.data!);
 return ApiResponse.success(
 data: execution,
 message: response.message ?? 'Report execution retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve report execution',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving report execution: $e');
}
 }

 Future<ApiResponse<String>> downloadReport(String executionId, ExportFormat format) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/executions/$executionId/download',
 queryParameters: {'format': format.name},
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: response.data!['download_url'],
 message: response.message ?? 'Report download URL generated successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to generate download URL',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error generating download URL: $e');
}
 }

 // Data Sources Management
 Future<ApiResponse<List<ReportDataSource>>> getDataSources({
 DataSourceType? type,
 bool? isActive,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 if (type != null) q{ueryParams['type'] = type.name;
 if (isActive != null) q{ueryParams['is_active'] = isActive.toString();

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/data-sources',
 queryParameters: queryParams,
 );
 
 if (response.success) {
 final List<String> data = response.data!['data_sources'];
 final dataSources = data.map((json) => ReportDataSource.fromJson(json)).toList();
 return ApiResponse.success(
 data: dataSources,
 message: response.message ?? 'Data sources retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve data sources',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving data sources: $e');
}
 }

 Future<ApiResponse<ReportDataSource>> createDataSource(Map<String, dynamic> data) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/data-sources',
 data: data,
 );
 
 if (response.success) {
 final dataSource = ReportDataSource.fromJson(response.data!);
 return ApiResponse.success(
 data: dataSource,
 message: response.message ?? 'Data source created successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to create data source',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error creating data source: $e');
}
 }

 Future<ApiResponse<Map<String, dynamic>>> testDataSource(String id) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/data-sources/$id/test',
 data: {},
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: response.data!,
 message: response.message ?? 'Data source test completed successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to test data source',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error testing data source: $e');
}
 }

 // Report Subscriptions
 Future<ApiResponse<List<ReportSubscription>>> getReportSubscriptions({
 String? userId,
 String? reportId,
 SubscriptionType? type,
 bool? isActive,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 if (userId != null) q{ueryParams['user_id'] = userId;
 if (reportId != null) q{ueryParams['report_id'] = reportId;
 if (type != null) q{ueryParams['type'] = type.name;
 if (isActive != null) q{ueryParams['is_active'] = isActive.toString();

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/subscriptions',
 queryParameters: queryParams,
 );
 
 if (response.success) {
 final List<String> data = response.data!['subscriptions'];
 final subscriptions = data.map((json) => ReportSubscription.fromJson(json)).toList();
 return ApiResponse.success(
 data: subscriptions,
 message: response.message ?? 'Report subscriptions retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve report subscriptions',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving report subscriptions: $e');
}
 }

 Future<ApiResponse<ReportSubscription>> createReportSubscription(Map<String, dynamic> data) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/subscriptions',
 data: data,
 );
 
 if (response.success) {
 final subscription = ReportSubscription.fromJson(response.data!);
 return ApiResponse.success(
 data: subscription,
 message: response.message ?? 'Report subscription created successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to create report subscription',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error creating report subscription: $e');
}
 }

 // Report Analytics
 Future<ApiResponse<Map<String, dynamic>>> getReportAnalytics({
 String? templateId,
 DateTime? startDate,
 DateTime? endDate,
 }) async {
 try {
 final queryParams = <String, String>{};
 
 if (templateId != null) q{ueryParams['template_id'] = templateId;
 if (startDate != null) q{ueryParams['start_date'] = startDate.toIso8601String();
 if (endDate != null) q{ueryParams['end_date'] = endDate.toIso8601String();

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/analytics',
 queryParameters: queryParams,
 );
 
 if (response.success) {
 return ApiResponse.success(
 data: response.data!,
 message: response.message ?? 'Report analytics retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve report analytics',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving report analytics: $e');
}
 }

 // Report Templates Library
 Future<ApiResponse<List<ReportTemplate>>> getTemplateLibrary({
 String? category,
 String? search,
 int page = 1,
 int limit = 20,
 }) async {
 try {
 final queryParams = <String, String>{
 'page': page.toString(),
 'limit': limit.toString(),
 };

 if (category != null) q{ueryParams['category'] = category;
 if (search != null) q{ueryParams['search'] = search;

 final ApiResponse<dynamic> response = await _apiService.get<Map<String, dynamic>>(
 '$_baseUrl/templates/library',
 queryParameters: queryParams,
 );
 
 if (response.success) {
 final List<String> data = response.data!['templates'];
 final templates = data.map((json) => ReportTemplate.fromJson(json)).toList();
 return ApiResponse.success(
 data: templates,
 message: response.message ?? 'Template library retrieved successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to retrieve template library',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error retrieving template library: $e');
}
 }

 Future<ApiResponse<ReportTemplate>> importTemplateFromLibrary(String templateId) async {
 try {
 final ApiResponse<dynamic> response = await _apiService.post<Map<String, dynamic>>(
 '$_baseUrl/templates/library/$templateId/import',
 data: {},
 );
 
 if (response.success) {
 final template = ReportTemplate.fromJson(response.data!);
 return ApiResponse.success(
 data: template,
 message: response.message ?? 'Template imported successfully',
 );
 } else {
 return ApiResponse.error(
 message: response.message ?? 'Failed to import template',
 );
 }
} catch (e) {
 return ApiResponse.error(message: 'Error importing template: $e');
}
 }
}
