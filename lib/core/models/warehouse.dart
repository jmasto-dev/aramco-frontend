import 'package:json_annotation/json_annotation.dart';

part 'warehouse.g.dart';

@JsonSerializable()
class Warehouse {
 final String id;
 final String name;
 final String code;
 final String address;
 final String city;
 final String country;
 final String postalCode;
 final String? phone;
 final String? email;
 final WarehouseStatus status;
 final double capacity;
 final double currentOccupancy;
 final String? managerId;
 final DateTime createdAt;
 final DateTime updatedAt;

 const Warehouse({
 required this.id,
 required this.name,
 required this.code,
 required this.address,
 required this.city,
 required this.country,
 required this.postalCode,
 this.phone,
 this.email,
 required this.status,
 required this.capacity,
 required this.currentOccupancy,
 this.managerId,
 required this.createdAt,
 required this.updatedAt,
 });

 factory Warehouse.fromJson(Map<String, dynamic> json) =>
 _$WarehouseFromJson(json);

 Map<String, dynamic> toJson() => _$WarehouseToJson(this);

 Warehouse copyWith({
 String? id,
 String? name,
 String? code,
 String? address,
 String? city,
 String? country,
 String? postalCode,
 String? phone,
 String? email,
 WarehouseStatus? status,
 double? capacity,
 double? currentOccupancy,
 String? managerId,
 DateTime? createdAt,
 DateTime? updatedAt,
 }) {
 return Warehouse(
 id: id ?? this.id,
 name: name ?? this.name,
 code: code ?? this.code,
 address: address ?? this.address,
 city: city ?? this.city,
 country: country ?? this.country,
 postalCode: postalCode ?? this.postalCode,
 phone: phone ?? this.phone,
 email: email ?? this.email,
 status: status ?? this.status,
 capacity: capacity ?? this.capacity,
 currentOccupancy: currentOccupancy ?? this.currentOccupancy,
 managerId: managerId ?? this.managerId,
 createdAt: createdAt ?? this.createdAt,
 updatedAt: updatedAt ?? this.updatedAt,
 );
 }

 double get occupancyRate => capacity > 0 ? currentOccupancy / capacity : 0.0;
 bool get isNearCapacity => occupancyRate >= 0.9;
 bool get isFull => occupancyRate >= 1.0;
 String get statusText {
 switch (status) {
 case WarehouseStatus.active:
 return 'Actif';
 case WarehouseStatus.inactive:
 return 'Inactif';
 case WarehouseStatus.maintenance:
 return 'Maintenance';
}
 }
}

enum WarehouseStatus {
 @JsonValue('active')
 active,
 @JsonValue('inactive')
 inactive,
 @JsonValue('maintenance')
 maintenance,
}

@JsonSerializable()
class StockTransfer {
 final String id;
 final String fromWarehouseId;
 final String toWarehouseId;
 final String stockItemId;
 final int quantity;
 final TransferStatus status;
 final DateTime transferDate;
 final DateTime? completedDate;
 final String? requestedBy;
 final String? approvedBy;
 final String? notes;
 final DateTime createdAt;
 final DateTime updatedAt;

 const StockTransfer({
 required this.id,
 required this.fromWarehouseId,
 required this.toWarehouseId,
 required this.stockItemId,
 required this.quantity,
 required this.status,
 required this.transferDate,
 this.completedDate,
 this.requestedBy,
 this.approvedBy,
 this.notes,
 required this.createdAt,
 required this.updatedAt,
 });

 factory StockTransfer.fromJson(Map<String, dynamic> json) =>
 _$StockTransferFromJson(json);

 Map<String, dynamic> toJson() => _$StockTransferToJson(this);

 String get statusText {
 switch (status) {
 case TransferStatus.pending:
 return 'En attente';
 case TransferStatus.approved:
 return 'Approuvé';
 case TransferStatus.inTransit:
 return 'En transit';
 case TransferStatus.completed:
 return 'Terminé';
 case TransferStatus.cancelled:
 return 'Annulé';
}
 }
}

enum TransferStatus {
 @JsonValue('pending')
 pending,
 @JsonValue('approved')
 approved,
 @JsonValue('in_transit')
 inTransit,
 @JsonValue('completed')
 completed,
 @JsonValue('cancelled')
 cancelled,
}

@JsonSerializable()
class WarehouseZone {
 final String id;
 final String warehouseId;
 final String name;
 final String code;
 final String description;
 final ZoneType type;
 final double capacity;
 final double currentOccupancy;
 final String? location;
 final bool isActive;
 final DateTime createdAt;
 final DateTime updatedAt;

 const WarehouseZone({
 required this.id,
 required this.warehouseId,
 required this.name,
 required this.code,
 required this.description,
 required this.type,
 required this.capacity,
 required this.currentOccupancy,
 this.location,
 required this.isActive,
 required this.createdAt,
 required this.updatedAt,
 });

 factory WarehouseZone.fromJson(Map<String, dynamic> json) =>
 _$WarehouseZoneFromJson(json);

 Map<String, dynamic> toJson() => _$WarehouseZoneToJson(this);

 double get occupancyRate => capacity > 0 ? currentOccupancy / capacity : 0.0;
 String get typeText {
 switch (type) {
 case ZoneType.storage:
 return 'Stockage';
 case ZoneType.picking:
 return 'Préparation';
 case ZoneType.packing:
 return 'Emballage';
 case ZoneType.shipping:
 return 'Expédition';
 case ZoneType.receiving:
 return 'Réception';
 case ZoneType.quarantine:
 return 'Quarantaine';
}
 }
}

enum ZoneType {
 @JsonValue('storage')
 storage,
 @JsonValue('picking')
 picking,
 @JsonValue('packing')
 packing,
 @JsonValue('shipping')
 shipping,
 @JsonValue('receiving')
 receiving,
 @JsonValue('quarantine')
 quarantine,
}

@JsonSerializable()
class StockCount {
 final String id;
 final String warehouseId;
 final String? zoneId;
 final String countNumber;
 final CountType type;
 final CountStatus status;
 final DateTime scheduledDate;
 final DateTime? startedDate;
 final DateTime? completedDate;
 final String? countedBy;
 final String? verifiedBy;
 final List<StockCountItem> items;
 final int totalItems;
 final int countedItems;
 final int discrepancies;
 final String? notes;
 final DateTime createdAt;
 final DateTime updatedAt;

 const StockCount({
 required this.id,
 required this.warehouseId,
 this.zoneId,
 required this.countNumber,
 required this.type,
 required this.status,
 required this.scheduledDate,
 this.startedDate,
 this.completedDate,
 this.countedBy,
 this.verifiedBy,
 required this.items,
 required this.totalItems,
 required this.countedItems,
 required this.discrepancies,
 this.notes,
 required this.createdAt,
 required this.updatedAt,
 });

 factory StockCount.fromJson(Map<String, dynamic> json) =>
 _$StockCountFromJson(json);

 Map<String, dynamic> toJson() => _$StockCountToJson(this);

 double get progressPercentage => totalItems > 0 ? countedItems / totalItems : 0.0;
 String get statusText {
 switch (status) {
 case CountStatus.scheduled:
 return 'Planifié';
 case CountStatus.inProgress:
 return 'En cours';
 case CountStatus.completed:
 return 'Terminé';
 case CountStatus.verified:
 return 'Vérifié';
 case CountStatus.cancelled:
 return 'Annulé';
}
 }

 String get typeText {
 switch (type) {
 case CountType.full:
 return 'Complet';
 case CountType.partial:
 return 'Partiel';
 case CountType.cycle:
 return 'Cycle';
 case CountType.sampling:
 return 'Échantillonnage';
}
 }
}

enum CountType {
 @JsonValue('full')
 full,
 @JsonValue('partial')
 partial,
 @JsonValue('cycle')
 cycle,
 @JsonValue('sampling')
 sampling,
}

enum CountStatus {
 @JsonValue('scheduled')
 scheduled,
 @JsonValue('in_progress')
 inProgress,
 @JsonValue('completed')
 completed,
 @JsonValue('verified')
 verified,
 @JsonValue('cancelled')
 cancelled,
}

@JsonSerializable()
class StockCountItem {
 final String id;
 final String stockCountId;
 final String stockItemId;
 final int systemQuantity;
 final int? countedQuantity;
 final int? variance;
 final String? notes;
 final bool isCounted;
 final DateTime? countedAt;

 const StockCountItem({
 required this.id,
 required this.stockCountId,
 required this.stockItemId,
 required this.systemQuantity,
 this.countedQuantity,
 this.variance,
 this.notes,
 required this.isCounted,
 this.countedAt,
 });

 factory StockCountItem.fromJson(Map<String, dynamic> json) =>
 _$StockCountItemFromJson(json);

 Map<String, dynamic> toJson() => _$StockCountItemToJson(this);

 bool get hasDiscrepancy => variance != null && variance != 0;
}

