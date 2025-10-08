// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Warehouse _$WarehouseFromJson(Map<String, dynamic> json) => Warehouse(
  id: json['id'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  address: json['address'] as String,
  city: json['city'] as String,
  country: json['country'] as String,
  postalCode: json['postalCode'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  status: $enumDecode(_$WarehouseStatusEnumMap, json['status']),
  capacity: (json['capacity'] as num).toDouble(),
  currentOccupancy: (json['currentOccupancy'] as num).toDouble(),
  managerId: json['managerId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$WarehouseToJson(Warehouse instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'address': instance.address,
  'city': instance.city,
  'country': instance.country,
  'postalCode': instance.postalCode,
  'phone': instance.phone,
  'email': instance.email,
  'status': _$WarehouseStatusEnumMap[instance.status]!,
  'capacity': instance.capacity,
  'currentOccupancy': instance.currentOccupancy,
  'managerId': instance.managerId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$WarehouseStatusEnumMap = {
  WarehouseStatus.active: 'active',
  WarehouseStatus.inactive: 'inactive',
  WarehouseStatus.maintenance: 'maintenance',
};

StockTransfer _$StockTransferFromJson(Map<String, dynamic> json) =>
    StockTransfer(
      id: json['id'] as String,
      fromWarehouseId: json['fromWarehouseId'] as String,
      toWarehouseId: json['toWarehouseId'] as String,
      stockItemId: json['stockItemId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      status: $enumDecode(_$TransferStatusEnumMap, json['status']),
      transferDate: DateTime.parse(json['transferDate'] as String),
      completedDate: json['completedDate'] == null
          ? null
          : DateTime.parse(json['completedDate'] as String),
      requestedBy: json['requestedBy'] as String?,
      approvedBy: json['approvedBy'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StockTransferToJson(StockTransfer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fromWarehouseId': instance.fromWarehouseId,
      'toWarehouseId': instance.toWarehouseId,
      'stockItemId': instance.stockItemId,
      'quantity': instance.quantity,
      'status': _$TransferStatusEnumMap[instance.status]!,
      'transferDate': instance.transferDate.toIso8601String(),
      'completedDate': instance.completedDate?.toIso8601String(),
      'requestedBy': instance.requestedBy,
      'approvedBy': instance.approvedBy,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TransferStatusEnumMap = {
  TransferStatus.pending: 'pending',
  TransferStatus.approved: 'approved',
  TransferStatus.inTransit: 'in_transit',
  TransferStatus.completed: 'completed',
  TransferStatus.cancelled: 'cancelled',
};

WarehouseZone _$WarehouseZoneFromJson(Map<String, dynamic> json) =>
    WarehouseZone(
      id: json['id'] as String,
      warehouseId: json['warehouseId'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ZoneTypeEnumMap, json['type']),
      capacity: (json['capacity'] as num).toDouble(),
      currentOccupancy: (json['currentOccupancy'] as num).toDouble(),
      location: json['location'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WarehouseZoneToJson(WarehouseZone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'warehouseId': instance.warehouseId,
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'type': _$ZoneTypeEnumMap[instance.type]!,
      'capacity': instance.capacity,
      'currentOccupancy': instance.currentOccupancy,
      'location': instance.location,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ZoneTypeEnumMap = {
  ZoneType.storage: 'storage',
  ZoneType.picking: 'picking',
  ZoneType.packing: 'packing',
  ZoneType.shipping: 'shipping',
  ZoneType.receiving: 'receiving',
  ZoneType.quarantine: 'quarantine',
};

StockCount _$StockCountFromJson(Map<String, dynamic> json) => StockCount(
  id: json['id'] as String,
  warehouseId: json['warehouseId'] as String,
  zoneId: json['zoneId'] as String?,
  countNumber: json['countNumber'] as String,
  type: $enumDecode(_$CountTypeEnumMap, json['type']),
  status: $enumDecode(_$CountStatusEnumMap, json['status']),
  scheduledDate: DateTime.parse(json['scheduledDate'] as String),
  startedDate: json['startedDate'] == null
      ? null
      : DateTime.parse(json['startedDate'] as String),
  completedDate: json['completedDate'] == null
      ? null
      : DateTime.parse(json['completedDate'] as String),
  countedBy: json['countedBy'] as String?,
  verifiedBy: json['verifiedBy'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => StockCountItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalItems: (json['totalItems'] as num).toInt(),
  countedItems: (json['countedItems'] as num).toInt(),
  discrepancies: (json['discrepancies'] as num).toInt(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$StockCountToJson(StockCount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'warehouseId': instance.warehouseId,
      'zoneId': instance.zoneId,
      'countNumber': instance.countNumber,
      'type': _$CountTypeEnumMap[instance.type]!,
      'status': _$CountStatusEnumMap[instance.status]!,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'startedDate': instance.startedDate?.toIso8601String(),
      'completedDate': instance.completedDate?.toIso8601String(),
      'countedBy': instance.countedBy,
      'verifiedBy': instance.verifiedBy,
      'items': instance.items,
      'totalItems': instance.totalItems,
      'countedItems': instance.countedItems,
      'discrepancies': instance.discrepancies,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$CountTypeEnumMap = {
  CountType.full: 'full',
  CountType.partial: 'partial',
  CountType.cycle: 'cycle',
  CountType.sampling: 'sampling',
};

const _$CountStatusEnumMap = {
  CountStatus.scheduled: 'scheduled',
  CountStatus.inProgress: 'in_progress',
  CountStatus.completed: 'completed',
  CountStatus.verified: 'verified',
  CountStatus.cancelled: 'cancelled',
};

StockCountItem _$StockCountItemFromJson(Map<String, dynamic> json) =>
    StockCountItem(
      id: json['id'] as String,
      stockCountId: json['stockCountId'] as String,
      stockItemId: json['stockItemId'] as String,
      systemQuantity: (json['systemQuantity'] as num).toInt(),
      countedQuantity: (json['countedQuantity'] as num?)?.toInt(),
      variance: (json['variance'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      isCounted: json['isCounted'] as bool,
      countedAt: json['countedAt'] == null
          ? null
          : DateTime.parse(json['countedAt'] as String),
    );

Map<String, dynamic> _$StockCountItemToJson(StockCountItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stockCountId': instance.stockCountId,
      'stockItemId': instance.stockItemId,
      'systemQuantity': instance.systemQuantity,
      'countedQuantity': instance.countedQuantity,
      'variance': instance.variance,
      'notes': instance.notes,
      'isCounted': instance.isCounted,
      'countedAt': instance.countedAt?.toIso8601String(),
    };
