import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'base_model.g.dart';

/// Modèle de base pour toutes les entités de l'application
/// Fournit des fonctionnalités communes comme la sérialisation JSON,
/// l'égalité, et les métadonnées de base

@JsonSerializable()
class BaseModel extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const BaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.metadata,
  });

  /// Constructeur pour créer une instance depuis JSON
  factory BaseModel.fromJson(Map<String, dynamic> json) =>
      _$BaseModelFromJson(json);

  /// Convertit l'instance en JSON
  Map<String, dynamic> toJson() => _$BaseModelToJson(this);

  /// Crée une copie avec des modifications
  BaseModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return BaseModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Vérifie si l'entité est récemment créée (moins de 24h)
  bool get isRecentlyCreated {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Vérifie si l'entité a été récemment mise à jour (moins de 1h)
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inHours < 1;
  }

  /// Obtient l'âge de l'entité en jours
  int get ageInDays {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays;
  }

  /// Vérifie si l'entité est active et valide
  bool get isValid => isActive && id.isNotEmpty;

  /// Métadonnées par défaut si null
  Map<String, dynamic> get safeMetadata => metadata ?? {};

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        isActive,
        metadata,
      ];

  @override
  String toString() {
    return 'BaseModel{id: $id, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive}';
  }
}

/// Extension pour les opérations communes sur les listes de BaseModel
extension BaseModelListExtension on List<BaseModel> {
  /// Filtre les éléments actifs
  List<BaseModel> get active => where((item) => item.isActive).toList();

  /// Filtre les éléments inactifs
  List<BaseModel> get inactive => where((item) => !item.isActive).toList();

  /// Filtre les éléments récemment créés
  List<BaseModel> get recentlyCreated => 
      where((item) => item.isRecentlyCreated).toList();

  /// Filtre les éléments récemment mis à jour
  List<BaseModel> get recentlyUpdated => 
      where((item) => item.isRecentlyUpdated).toList();

  /// Trie par date de création (plus récent d'abord)
  List<BaseModel> sortedByCreatedAt() {
    final sorted = List<BaseModel>.from(this);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Trie par date de mise à jour (plus récent d'abord)
  List<BaseModel> sortedByUpdatedAt() {
    final sorted = List<BaseModel>.from(this);
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  /// Recherche par ID
  BaseModel? findById(String id) {
    try {
      return firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Mixin pour ajouter des fonctionnalités de validation aux modèles
mixin ValidatableModel on BaseModel {
  /// Valide les données du modèle
  List<String> validate();
  
  /// Vérifie si le modèle est valide
  bool get isValid => validate().isEmpty;
}

/// Mixin pour ajouter des fonctionnalités d'audit aux modèles
mixin AuditableModel on BaseModel {
  String? createdBy;
  String? updatedBy;
  DateTime? deletedAt;
  String? deletedBy;
  
  bool get isDeleted => deletedAt != null;
  
  /// Marque comme supprimé (soft delete)
  BaseModel markAsDeleted({String? deletedBy}) {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
      metadata: {
        ...safeMetadata,
        'deletedAt': DateTime.now().toIso8601String(),
        'deletedBy': deletedBy,
      },
    );
  }
}
