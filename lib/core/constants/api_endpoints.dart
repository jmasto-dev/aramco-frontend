/// Configuration des endpoints API pour l'application Aramco
/// Pointe vers le backend Laravel situé dans le dossier devM/aramco-backend
class ApiEndpoints {
  // Configuration de base
  static const String _baseUrl = 'http://localhost:8000';
  static const String _apiVersion = 'api/v1';
  
  // URL complète de base
  static String get baseUrl => '$_baseUrl/$_apiVersion';
  
  // Endpoints d'authentification
  static String get login => '$baseUrl/auth/login';
  static String get logout => '$baseUrl/auth/logout';
  static String get register => '$baseUrl/auth/register';
  static String get refresh => '$baseUrl/auth/refresh';
  static String get profile => '$baseUrl/auth/profile';
  static String get changePassword => '$baseUrl/auth/change-password';
  
  // Endpoints des employés
  static String get employees => '$baseUrl/employees';
  static String employeeById(String id) => '$baseUrl/employees/$id';
  static String updateEmployee(String id) => '$baseUrl/employees/$id';
  static String deleteEmployee(String id) => '$baseUrl/employees/$id';
  static String get employeesSearch => '$baseUrl/employees/search';
  static String get employeesExport => '$baseUrl/employees/export';
  
  // Endpoints des congés
  static String get leaveRequests => '$baseUrl/leave-requests';
  static String leaveRequestById(String id) => '$baseUrl/leave-requests/$id';
  static String updateLeaveRequest(String id) => '$baseUrl/leave-requests/$id';
  static String approveLeaveRequest(String id) => '$baseUrl/leave-requests/$id/approve';
  static String rejectLeaveRequest(String id) => '$baseUrl/leave-requests/$id/reject';
  static String get myLeaveRequests => '$baseUrl/leave-requests/my';
  static String get leaveBalance => '$baseUrl/leave-requests/balance';
  
  // Endpoints des évaluations de performance
  static String get performanceReviews => '$baseUrl/performance-reviews';
  static String performanceReviewById(String id) => '$baseUrl/performance-reviews/$id';
  static String updatePerformanceReview(String id) => '$baseUrl/performance-reviews/$id';
  static String get myPerformanceReviews => '$baseUrl/performance-reviews/my';
  static String get performanceReviewsByEmployee => '$baseUrl/performance-reviews/employee';
  
  // Endpoints des commandes
  static String get orders => '$baseUrl/orders';
  static String orderById(String id) => '$baseUrl/orders/$id';
  static String updateOrder(String id) => '$baseUrl/orders/$id';
  static String updateOrderStatus(String id) => '$baseUrl/orders/$id/status';
  static String get myOrders => '$baseUrl/orders/my';
  static String get ordersSearch => '$baseUrl/orders/search';
  static String get ordersExport => '$baseUrl/orders/export';
  
  // Endpoints des produits
  static String get products => '$baseUrl/products';
  static String productById(String id) => '$baseUrl/products/$id';
  static String updateProduct(String id) => '$baseUrl/products/$id';
  static String get productsSearch => '$baseUrl/products/search';
  static String get productsByCategory => '$baseUrl/products/category';
  
  // Endpoints des fournisseurs
  static String get suppliers => '$baseUrl/suppliers';
  static String supplierById(String id) => '$baseUrl/suppliers/$id';
  static String updateSupplier(String id) => '$baseUrl/suppliers/$id';
  static String get suppliersSearch => '$baseUrl/suppliers/search';
  
  // Endpoints des demandes d'achat
  static String get purchaseRequests => '$baseUrl/purchase-requests';
  static String purchaseRequestById(String id) => '$baseUrl/purchase-requests/$id';
  static String updatePurchaseRequest(String id) => '$baseUrl/purchase-requests/$id';
  static String approvePurchaseRequest(String id) => '$baseUrl/purchase-requests/$id/approve';
  static String get myPurchaseRequests => '$baseUrl/purchase-requests/my';
  
  // Endpoints des bulletins de paie
  static String get payslips => '$baseUrl/payslips';
  static String payslipById(String id) => '$baseUrl/payslips/$id';
  static String get myPayslips => '$baseUrl/payslips/my';
  static String payslipDownload(String id) => '$baseUrl/payslips/$id/download';
  
  // Endpoints des stocks
  static String get stocks => '$baseUrl/stocks';
  static String stockById(String id) => '$baseUrl/stocks/$id';
  static String updateStock(String id) => '$baseUrl/stocks/$id';
  static String get stocksSearch => '$baseUrl/stocks/search';
  static String get stocksLowStock => '$baseUrl/stocks/low-stock';
  
  // Endpoints des déclarations fiscales
  static String get taxDeclarations => '$baseUrl/tax-declarations';
  static String taxDeclarationById(String id) => '$baseUrl/tax-declarations/$id';
  static String updateTaxDeclaration(String id) => '$baseUrl/tax-declarations/$id';
  static String get myTaxDeclarations => '$baseUrl/tax-declarations/my';
  static String taxDeclarationDownload(String id) => '$baseUrl/tax-declarations/$id/download';
  
  // Endpoints des entrepôts
  static String get warehouses => '$baseUrl/warehouses';
  static String warehouseById(String id) => '$baseUrl/warehouses/$id';
  static String updateWarehouse(String id) => '$baseUrl/warehouses/$id';
  
  // Endpoints des permissions
  static String get permissions => '$baseUrl/permissions';
  static String permissionById(String id) => '$baseUrl/permissions/$id';
  static String updatePermission(String id) => '$baseUrl/permissions/$id';
  static String get userPermissions => '$baseUrl/permissions/user';
  
  // Endpoints des rapports
  static String get reports => '$baseUrl/reports';
  static String reportById(String id) => '$baseUrl/reports/$id';
  static String get reportsGenerate => '$baseUrl/reports/generate';
  static String reportDownload(String id) => '$baseUrl/reports/$id/download';
  static String get reportTemplates => '$baseUrl/reports/templates';
  
  // Endpoints des notifications
  static String get notifications => '$baseUrl/notifications';
  static String notificationById(String id) => '$baseUrl/notifications/$id';
  static String markNotificationRead(String id) => '$baseUrl/notifications/$id/read';
  static String get notificationsUnread => '$baseUrl/notifications/unread';
  static String get notificationsMarkAllRead => '$baseUrl/notifications/mark-all-read';
  
  // Endpoints des messages
  static String get messages => '$baseUrl/messages';
  static String messageById(String id) => '$baseUrl/messages/$id';
  static String get sendMessage => '$baseUrl/messages/send';
  static String get messagesInbox => '$baseUrl/messages/inbox';
  static String get messagesSent => '$baseUrl/messages/sent';
  static String get messagesUnread => '$baseUrl/messages/unread';
  
  // Endpoints des tâches
  static String get tasks => '$baseUrl/tasks';
  static String taskById(String id) => '$baseUrl/tasks/$id';
  static String updateTask(String id) => '$baseUrl/tasks/$id';
  static String assignTask(String id) => '$baseUrl/tasks/$id/assign';
  static String completeTask(String id) => '$baseUrl/tasks/$id/complete';
  static String get myTasks => '$baseUrl/tasks/my';
  static String get tasksByProject => '$baseUrl/tasks/project';
  
  // Endpoints du dashboard
  static String get dashboard => '$baseUrl/dashboard';
  static String get dashboardStats => '$baseUrl/dashboard/stats';
  static String get dashboardCharts => '$baseUrl/dashboard/charts';
  static String get dashboardAlerts => '$baseUrl/dashboard/alerts';
  
  // Endpoints de recherche globale
  static String get globalSearch => '$baseUrl/search';
  static String get searchSuggestions => '$baseUrl/search/suggestions';
  
  // Endpoints d'administration
  static String get adminUsers => '$baseUrl/admin/users';
  static String get adminRoles => '$baseUrl/admin/roles';
  static String get adminSettings => '$baseUrl/admin/settings';
  static String get adminLogs => '$baseUrl/admin/logs';
  static String get adminBackup => '$baseUrl/admin/backup';
  
  // Endpoints de système
  static String get health => '$baseUrl/health';
  static String get version => '$baseUrl/version';
  static String get config => '$baseUrl/config';
  
  // Endpoints de fichiers
  static String get upload => '$baseUrl/upload';
  static String fileDownload(String id) => '$baseUrl/files/$id/download';
  static String fileDelete(String id) => '$baseUrl/files/$id';
  
  // Configuration WebSocket (si nécessaire)
  static const String websocketUrl = 'ws://localhost:8000/ws';
  
  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Headers par défaut
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  };
  
  // Headers avec authentification
  static Map<String, String> authenticatedHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
