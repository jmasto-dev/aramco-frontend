import 'package:flutter/foundation.dart';
import '../../core/models/api_response.dart';
import '../../core/models/stock_item.dart';
import '../../core/models/warehouse.dart';
import '../../core/services/stock_service.dart';

class StockProvider extends ChangeNotifier {
 final StockService _stockService = StockService();

 // State variables
 List<StockItem> _stockItems = [];
 List<StockMovement> _stockMovements = [];
 List<StockAlert> _stockAlerts = [];
 List<Warehouse> _warehouses = [];
 List<StockTransfer> _stockTransfers = [];
 Map<String, dynamic> _statistics = {};
 List<StockItem> _lowStockItems = [];
 List<StockItem> _expiringItems = [];

 // Loading states
 bool _isLoadingStockItems = false;
 bool _isLoadingMovements = false;
 bool _isLoadingAlerts = false;
 bool _isLoadingWarehouses = false;
 bool _isLoadingTransfers = false;
 bool _isLoadingStatistics = false;
 bool _isLoadingLowStock = false;
 bool _isLoadingExpiring = false;

 // Error states
 String? _stockItemsError;
 String? _movementsError;
 String? _alertsError;
 String? _warehousesError;
 String? _transfersError;
 String? _statisticsError;
 String? _lowStockError;
 String? _expiringError;

 // Pagination
 int _currentPage = 1;
 int _totalPages = 1;
 bool _hasNextPage = false;

 // Filters
 String? _selectedWarehouseId;
 String? _selectedProductId;
 StockStatus? _selectedStatus;
 MovementType? _selectedMovementType;
 AlertType? _selectedAlertType;
 AlertSeverity? _selectedAlertSeverity;
 TransferStatus? _selectedTransferStatus;

 // Getters
 List<StockItem> get stockItems => _stockItems;
 List<StockMovement> get stockMovements => _stockMovements;
 List<StockAlert> get stockAlerts => _stockAlerts;
 List<Warehouse> get warehouses => _warehouses;
 List<StockTransfer> get stockTransfers => _stockTransfers;
 Map<String, dynamic> get statistics => _statistics;
 List<StockItem> get lowStockItems => _lowStockItems;
 List<StockItem> get expiringItems => _expiringItems;

 bool get isLoadingStockItems => _isLoadingStockItems;
 bool get isLoadingMovements => _isLoadingMovements;
 bool get isLoadingAlerts => _isLoadingAlerts;
 bool get isLoadingWarehouses => _isLoadingWarehouses;
 bool get isLoadingTransfers => _isLoadingTransfers;
 bool get isLoadingStatistics => _isLoadingStatistics;
 bool get isLoadingLowStock => _isLoadingLowStock;
 bool get isLoadingExpiring => _isLoadingExpiring;

 String? get stockItemsError => _stockItemsError;
 String? get movementsError => _movementsError;
 String? get alertsError => _alertsError;
 String? get warehousesError => _warehousesError;
 String? get transfersError => _transfersError;
 String? get statisticsError => _statisticsError;
 String? get lowStockError => _lowStockError;
 String? get expiringError => _expiringError;

 int get currentPage => _currentPage;
 int get totalPages => _totalPages;
 bool get hasNextPage => _hasNextPage;

 String? get selectedWarehouseId => _selectedWarehouseId;
 String? get selectedProductId => _selectedProductId;
 StockStatus? get selectedStatus => _selectedStatus;
 MovementType? get selectedMovementType => _selectedMovementType;
 AlertType? get selectedAlertType => _selectedAlertType;
 AlertSeverity? get selectedAlertSeverity => _selectedAlertSeverity;
 TransferStatus? get selectedTransferStatus => _selectedTransferStatus;

 // Stock Items Methods
 Future<void> loadStockItems({bool refresh = false}) {async {
 if (refresh) {{
 _currentPage = 1;
 _stockItems.clear();
}

 _isLoadingStockItems = true;
 _stockItemsError = null;
 notifyListeners();

 try {
 final response = await _stockService.getStockItems(
 warehouseId: _selectedWarehouseId,
 productId: _selectedProductId,
 status: _selectedStatus,
 page: _currentPage,
 );

 if (response.success) {{
 if (refresh) {{
 _stockItems = response.data!;
 } else {
 _stockItems.addAll(response.data!);
 }
 
 // Update pagination info if available
 if (response.data!.isNotEmpty) {{
 _currentPage++;
 _hasNextPage = response.data!.length == 20; // Assuming limit is 20
 ;
 } else {
 _stockItemsError = response.message;
 }
} catch (e) {
 _stockItemsError = 'Failed to load stock items: $e';
}

 _isLoadingStockItems = false;
 notifyListeners();
 }

 Future<void> refreshStockItems() {async {
 await loadStockItems(refresh: true);
 }

 Future<void> createStockItem(Map<String, dynamic> data) {async {
 try {
 final response = await _stockService.createStockItem(data);
 
 if (response.success) {{
 _stockItems.insert(0, response.data!);
 notifyListeners();
 return;
 } else {
 throw Exception(response.message);
 }
} catch (e) {
 throw Exception('Failed to create stock item: $e');
}
 }

 Future<void> updateStockItem(String id, Map<String, dynamic> data) {async {
 try {
 final response = await _stockService.updateStockItem(id, data);
 
 if (response.success) {{
 final index = _stockItems.indexWhere((item) => item.id == id);
 if (index != -1) {{
 _stockItems[index] = response.data!;
 notifyListeners();
 }
 return;
 } else {
 throw Exception(response.message);
 }
} catch (e) {
 throw Exception('Failed to update stock item: $e');
}
 }

 // Stock Movements Methods
 Future<void> loadStockMovements({bool refresh = false}) {async {
 _isLoadingMovements = true;
 _movementsError = null;
 notifyListeners();

 try {
 final response = await _stockService.getStockMovements(
 stockItemId: _selectedProductId,
 type: _selectedMovementType,
 page: refresh ? 1 : _currentPage,
 );

 if (response.success) {{
 if (refresh) {{
 _stockMovements = response.data!;
 } else {
 _stockMovements.addAll(response.data!);
 }
 } else {
 _movementsError = response.message;
 }
} catch (e) {
 _movementsError = 'Failed to load stock movements: $e';
}

 _isLoadingMovements = false;
 notifyListeners();
 }

 Future<void> createStockMovement(Map<String, dynamic> data) {async {
 try {
 final response = await _stockService.createStockMovement(data);
 
 if (response.success) {{
 _stockMovements.insert(0, response.data!);
 notifyListeners();
 return;
 } else {
 throw Exception(response.message);
 }
} catch (e) {
 throw Exception('Failed to create stock movement: $e');
}
 }

 // Stock Alerts Methods
 Future<void> loadStockAlerts({bool refresh = false}) {async {
 _isLoadingAlerts = true;
 _alertsError = null;
 notifyListeners();

 try {
 final response = await _stockService.getStockAlerts(
 type: _selectedAlertType,
 severity: _selectedAlertSeverity,
 page: refresh ? 1 : _currentPage,
 );

 if (response.success) {{
 if (refresh) {{
 _stockAlerts = response.data!;
 } else {
 _stockAlerts.addAll(response.data!);
 }
 } else {
 _alertsError = response.message;
 }
} catch (e) {
 _alertsError = 'Failed to load stock alerts: $e';
}

 _isLoadingAlerts = false;
 notifyListeners();
 }

 Future<void> acknowledgeAlert(String alertId) {async {
 try {
 final response = await _stockService.acknowledgeAlert(alertId);
 
 if (response.success) {{
 final index = _stockAlerts.indexWhere((alert) => alert.id == alertId);
 if (index != -1) {{
 // Create a copy with acknowledged status
 final updatedAlert = StockAlert(
 id: _stockAlerts[index].id,
 stockItemId: _stockAlerts[index].stockItemId,
 type: _stockAlerts[index].type,
 message: _stockAlerts[index].message,
 severity: _stockAlerts[index].severity,
 createdAt: _stockAlerts[index].createdAt,
 isAcknowledged: true,
 acknowledgedBy: 'current_user', // This should come from auth provider
 acknowledgedAt: DateTime.now(),
 );
 _stockAlerts[index] = updatedAlert;
 notifyListeners();
 }
 return;
 } else {
 throw Exception(response.message);
 }
} catch (e) {
 throw Exception('Failed to acknowledge alert: $e');
}
 }

 // Warehouse Methods
 Future<void> loadWarehouses({bool refresh = false}) {async {
 _isLoadingWarehouses = true;
 _warehousesError = null;
 notifyListeners();

 try {
 final response = await _stockService.getWarehouses();

 if (response.success) {{
 _warehouses = response.data!;
 } else {
 _warehousesError = response.message;
 }
} catch (e) {
 _warehousesError = 'Failed to load warehouses: $e';
}

 _isLoadingWarehouses = false;
 notifyListeners();
 }

 // Stock Transfers Methods
 Future<void> loadStockTransfers({bool refresh = false}) {async {
 _isLoadingTransfers = true;
 _transfersError = null;
 notifyListeners();

 try {
 final response = await _stockService.getStockTransfers(
 status: _selectedTransferStatus,
 page: refresh ? 1 : _currentPage,
 );

 if (response.success) {{
 if (refresh) {{
 _stockTransfers = response.data!;
 } else {
 _stockTransfers.addAll(response.data!);
 }
 } else {
 _transfersError = response.message;
 }
} catch (e) {
 _transfersError = 'Failed to load stock transfers: $e';
}

 _isLoadingTransfers = false;
 notifyListeners();
 }

 Future<void> createStockTransfer(Map<String, dynamic> data) {async {
 try {
 final response = await _stockService.createStockTransfer(data);
 
 if (response.success) {{
 _stockTransfers.insert(0, response.data!);
 notifyListeners();
 return;
 } else {
 throw Exception(response.message);
 }
} catch (e) {
 throw Exception('Failed to create stock transfer: $e');
}
 }

 Future<void> updateTransferStatus(String transferId, TransferStatus status) {async {
 try {
 final response = await _stockService.updateTransferStatus(transferId, status);
 
 if (response.success) {{
 final index = _stockTransfers.indexWhere((transfer) => transfer.id == transferId);
 if (index != -1) {{
 _stockTransfers[index] = response.data!;
 notifyListeners();
 }
 return;
 } else {
 throw Exception(response.message);
 }
} catch (e) {
 throw Exception('Failed to update transfer status: $e');
}
 }

 // Statistics Methods
 Future<void> loadStatistics() {async {
 _isLoadingStatistics = true;
 _statisticsError = null;
 notifyListeners();

 try {
 final response = await _stockService.getStockStatistics(
 warehouseId: _selectedWarehouseId,
 productId: _selectedProductId,
 );

 if (response.success) {{
 _statistics = response.data!;
 } else {
 _statisticsError = response.message;
 }
} catch (e) {
 _statisticsError = 'Failed to load statistics: $e';
}

 _isLoadingStatistics = false;
 notifyListeners();
 }

 // Reports Methods
 Future<void> loadLowStockItems() {async {
 _isLoadingLowStock = true;
 _lowStockError = null;
 notifyListeners();

 try {
 final response = await _stockService.getLowStockItems(
 warehouseId: _selectedWarehouseId,
 );

 if (response.success) {{
 _lowStockItems = response.data!;
 } else {
 _lowStockError = response.message;
 }
} catch (e) {
 _lowStockError = 'Failed to load low stock items: $e';
}

 _isLoadingLowStock = false;
 notifyListeners();
 }

 Future<void> loadExpiringItems({int daysAhead = 30}) {async {
 _isLoadingExpiring = true;
 _expiringError = null;
 notifyListeners();

 try {
 final response = await _stockService.getExpiringItems(
 warehouseId: _selectedWarehouseId,
 daysAhead: daysAhead,
 );

 if (response.success) {{
 _expiringItems = response.data!;
 } else {
 _expiringError = response.message;
 }
} catch (e) {
 _expiringError = 'Failed to load expiring items: $e';
}

 _isLoadingExpiring = false;
 notifyListeners();
 }

 // Filter Methods
 void setWarehouseFilter(String? warehouseId) {
 _selectedWarehouseId = warehouseId;
 notifyListeners();
 }

 void setProductFilter(String? productId) {
 _selectedProductId = productId;
 notifyListeners();
 }

 void setStatusFilter(StockStatus? status) {
 _selectedStatus = status;
 notifyListeners();
 }

 void setMovementTypeFilter(MovementType? type) {
 _selectedMovementType = type;
 notifyListeners();
 }

 void setAlertTypeFilter(AlertType? type) {
 _selectedAlertType = type;
 notifyListeners();
 }

 void setAlertSeverityFilter(AlertSeverity? severity) {
 _selectedAlertSeverity = severity;
 notifyListeners();
 }

 void setTransferStatusFilter(TransferStatus? status) {
 _selectedTransferStatus = status;
 notifyListeners();
 }

 void clearFilters() {
 _selectedWarehouseId = null;
 _selectedProductId = null;
 _selectedStatus = null;
 _selectedMovementType = null;
 _selectedAlertType = null;
 _selectedAlertSeverity = null;
 _selectedTransferStatus = null;
 notifyListeners();
 }

 // Utility Methods
 void clearErrors() {
 _stockItemsError = null;
 _movementsError = null;
 _alertsError = null;
 _warehousesError = null;
 _transfersError = null;
 _statisticsError = null;
 _lowStockError = null;
 _expiringError = null;
 notifyListeners();
 }

 StockItem? findStockItemById(String id) {
 try {
 return _stockItems.firstWhere((item) => item.id == id);
} catch (e) {
 return null;
}
 }

 Warehouse? findWarehouseById(String id) {
 try {
 return _warehouses.firstWhere((warehouse) => warehouse.id == id);
} catch (e) {
 return null;
}
 }

 List<StockItem> getCriticalStockItems() {
 return _stockItems.where((item) => item.isLowStock || item.isExpired).toList();
 }

 List<StockAlert> getUnacknowledgedAlerts() {
 return _stockAlerts.where((alert) => !alert.isAcknowledged).toList();
 }

 int getTotalStockValue() {
 return _stockItems.fold(0, (sum, item) => sum + item.totalValue.toInt());
 }

 int getTotalStockQuantity() {
 return _stockItems.fold(0, (sum, item) => sum + item.quantity);
 }
}
