import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'performance_review.g.dart';

/// Types d'évaluation de performance
enum ReviewType {
 @JsonValue('annual')
 annual,
 @JsonValue('semi_annual')
 semiAnnual,
 @JsonValue('quarterly')
 quarterly,
 @JsonValue('probation')
 probation,
 @JsonValue('special')
 special,
}

/// Statuts de l'évaluation
enum ReviewStatus {
 @JsonValue('draft')
 draft,
 @JsonValue('in_progress')
 inProgress,
 @JsonValue('submitted')
 submitted,
 @JsonValue('reviewed')
 reviewed,
 @JsonValue('approved')
 approved,
 @JsonValue('rejected')
 rejected,
}

/// Niveaux de performance
enum PerformanceLevel {
 @JsonValue('excellent')
 excellent,
 @JsonValue('exceeds_expectations')
 exceedsExpectations,
 @JsonValue('meets_expectations')
 meetsExpectations,
 @JsonValue('needs_improvement')
 needsImprovement,
 @JsonValue('unsatisfactory')
 unsatisfactory,
}

/// Compétence évaluée
class Competency extends Equatable {
 final String id;
 final String name;
 final String description;
 final double weight; // Pondération (0.0 - 1.0)
 final int rating; // Note (1-5)
 final String? comments;

 const Competency({
 required this.id,
 required this.name,
 required this.description,
 required this.weight,
 required this.rating,
 this.comments,
 });

 factory Competency.fromJson(Map<String, dynamic> json) => _$CompetencyFromJson(json);
 Map<String, dynamic> toJson() => _$CompetencyToJson(this);

 Competency copyWith({
 String? id,
 String? name,
 String? description,
 double? weight,
 int? rating,
 String? comments,
 }) {
 return Competency(
 id: id ?? this.id,
 name: name ?? this.name,
 description: description ?? this.description,
 weight: weight ?? this.weight,
 rating: rating ?? this.rating,
 comments: comments ?? this.comments,
 );
 }

 /// Calcule le score pondéré de cette compétence
 double get weightedScore => (rating * weight);

 @override
 List<Object?> get props => [id, name, description, weight, rating, comments];
}

/// Objectif SMART
class SmartGoal extends Equatable {
 final String id;
 final String title;
 final String description;
 final DateTime? dueDate;
 final bool isCompleted;
 final double progress; // 0.0 - 1.0
 final String? notes;

 const SmartGoal({
 required this.id,
 required this.title,
 required this.description,
 this.dueDate,
 required this.isCompleted,
 required this.progress,
 this.notes,
 });

 factory SmartGoal.fromJson(Map<String, dynamic> json) => _$SmartGoalFromJson(json);
 Map<String, dynamic> toJson() => _$SmartGoalToJson(this);

 SmartGoal copyWith({
 String? id,
 String? title,
 String? description,
 DateTime? dueDate,
 bool? isCompleted,
 double? progress,
 String? notes,
 }) {
 return SmartGoal(
 id: id ?? this.id,
 title: title ?? this.title,
 description: description ?? this.description,
 dueDate: dueDate ?? this.dueDate,
 isCompleted: isCompleted ?? this.isCompleted,
 progress: progress ?? this.progress,
 notes: notes ?? this.notes,
 );
 }

 @override
 List<Object?> get props => [id, title, description, dueDate, isCompleted, progress, notes];
}

/// Signature numérique
class DigitalSignature extends Equatable {
 final String id;
 final String signerName;
 final String signerRole;
 final DateTime signedAt;
 final String? comments;

 const DigitalSignature({
 required this.id,
 required this.signerName,
 required this.signerRole,
 required this.signedAt,
 this.comments,
 });

 factory DigitalSignature.fromJson(Map<String, dynamic> json) => _$DigitalSignatureFromJson(json);
 Map<String, dynamic> toJson() => _$DigitalSignatureToJson(this);

 DigitalSignature copyWith({
 String? id,
 String? signerName,
 String? signerRole,
 DateTime? signedAt,
 String? comments,
 }) {
 return DigitalSignature(
 id: id ?? this.id,
 signerName: signerName ?? this.signerName,
 signerRole: signerRole ?? this.signerRole,
 signedAt: signedAt ?? this.signedAt,
 comments: comments ?? this.comments,
 );
 }

 @override
 List<Object?> get props => [id, signerName, signerRole, signedAt, comments];
}

/// Modèle d'évaluation de performance
class PerformanceReview extends Equatable {
 final String id;
 final String employeeId;
 final String reviewerId;
 final String reviewPeriod;
 final ReviewType reviewType;
 final ReviewStatus status;
 final DateTime createdAt;
 final DateTime? submittedAt;
 final DateTime? reviewedAt;
 final DateTime? approvedAt;
 final List<Competency> competencies;
 final List<SmartGoal> goals;
 final String? overallComments;
 final PerformanceLevel? overallRating;
 final List<DigitalSignature> signatures;
 final double? finalScore;

 const PerformanceReview({
 required this.id,
 required this.employeeId,
 required this.reviewerId,
 required this.reviewPeriod,
 required this.reviewType,
 required this.status,
 required this.createdAt,
 this.submittedAt,
 this.reviewedAt,
 this.approvedAt,
 required this.competencies,
 required this.goals,
 this.overallComments,
 this.overallRating,
 required this.signatures,
 this.finalScore,
 });

 factory PerformanceReview.fromJson(Map<String, dynamic> json) => _$PerformanceReviewFromJson(json);
 Map<String, dynamic> toJson() => _$PerformanceReviewToJson(this);

 PerformanceReview copyWith({
 String? id,
 String? employeeId,
 String? reviewerId,
 String? reviewPeriod,
 ReviewType? reviewType,
 ReviewStatus? status,
 DateTime? createdAt,
 DateTime? submittedAt,
 DateTime? reviewedAt,
 DateTime? approvedAt,
 List<Competency>? competencies,
 List<SmartGoal>? goals,
 String? overallComments,
 PerformanceLevel? overallRating,
 List<DigitalSignature>? signatures,
 double? finalScore,
 }) {
 return PerformanceReview(
 id: id ?? this.id,
 employeeId: employeeId ?? this.employeeId,
 reviewerId: reviewerId ?? this.reviewerId,
 reviewPeriod: reviewPeriod ?? this.reviewPeriod,
 reviewType: reviewType ?? this.reviewType,
 status: status ?? this.status,
 createdAt: createdAt ?? this.createdAt,
 submittedAt: submittedAt ?? this.submittedAt,
 reviewedAt: reviewedAt ?? this.reviewedAt,
 approvedAt: approvedAt ?? this.approvedAt,
 competencies: competencies ?? this.competencies,
 goals: goals ?? this.goals,
 overallComments: overallComments ?? this.overallComments,
 overallRating: overallRating ?? this.overallRating,
 signatures: signatures ?? this.signatures,
 finalScore: finalScore ?? this.finalScore,
 );
 }

 /// Crée une nouvelle évaluation avec des valeurs par défaut
 factory PerformanceReview.create({
 required String employeeId,
 required String reviewerId,
 required String reviewPeriod,
 required ReviewType reviewType,
 }) {
 return PerformanceReview(
 id: const Uuid().v4(),
 employeeId: employeeId,
 reviewerId: reviewerId,
 reviewPeriod: reviewPeriod,
 reviewType: reviewType,
 status: ReviewStatus.draft,
 createdAt: DateTime.now(),
 competencies: _getDefaultCompetencies(),
 goals: [],
 signatures: [],
 );
 }

 /// Calcule le score final basé sur les compétences
 double calculateFinalScore() {
 if (competencies.isEmpty) r{eturn 0.0;
 
 final totalWeight = competencies.fold(0.0, (sum, comp) => sum + comp.weight);
 if (totalWeight == 0.0) r{eturn 0.0;
 
 final totalScore = competencies.fold(0.0, (sum, comp) => sum + comp.weightedScore);
 return totalScore / totalWeight;
 }

 /// Vérifie si l'évaluation est complète
 bool get isComplete {
 return competencies.every((comp) => comp.rating > 0) &&
 overallComments != null && overallComments!.isNotEmpty &&
 overallRating != null;
 }

 /// Vérifie si l'évaluation peut être soumise
 bool get canSubmit => isComplete && status == ReviewStatus.draft;

 /// Vérifie si l'évaluation peut être approuvée
 bool get canApprove => status == ReviewStatus.submitted || status == ReviewStatus.reviewed;

 /// Retourne le niveau de performance basé sur le score
 PerformanceLevel? getPerformanceLevelFromScore(double score) {
 if (score >= 4.5) r{eturn PerformanceLevel.excellent;
 if (score >= 3.5) r{eturn PerformanceLevel.exceedsExpectations;
 if (score >= 2.5) r{eturn PerformanceLevel.meetsExpectations;
 if (score >= 1.5) r{eturn PerformanceLevel.needsImprovement;
 return PerformanceLevel.unsatisfactory;
 }

 /// Compétences par défaut
 static List<Competency> _getDefaultCompetencies() {
 return [
 Competency(
 id: const Uuid().v4(),
 name: 'Qualité du travail',
 description: 'Précision, attention aux détails, respect des normes',
 weight: 0.25,
 rating: 0,
 ),
 Competency(
 id: const Uuid().v4(),
 name: 'Productivité',
 description: 'Volume de travail, respect des délais, efficacité',
 weight: 0.20,
 rating: 0,
 ),
 Competency(
 id: const Uuid().v4(),
 name: 'Communication',
 description: 'Clarté, écoute, collaboration, présentation',
 weight: 0.15,
 rating: 0,
 ),
 Competency(
 id: const Uuid().v4(),
 name: 'Initiative et proactivité',
 description: 'Prise d\'initiative, résolution de problèmes, innovation',
 weight: 0.15,
 rating: 0,
 ),
 Competency(
 id: const Uuid().v4(),
 name: 'Travail d\'équipe',
 description: 'Collaboration, entraide, esprit d\'équipe',
 weight: 0.15,
 rating: 0,
 ),
 Competency(
 id: const Uuid().v4(),
 name: 'Développement professionnel',
 description: 'Apprentissage, adaptation, montée en compétences',
 weight: 0.10,
 rating: 0,
 ),
 ];
 }

 @override
 List<Object?> get props => [
 id,
 employeeId,
 reviewerId,
 reviewPeriod,
 reviewType,
 status,
 createdAt,
 submittedAt,
 reviewedAt,
 approvedAt,
 competencies,
 goals,
 overallComments,
 overallRating,
 signatures,
 finalScore,
 ];
}

/// Extensions pour les enums
extension ReviewTypeExtension on ReviewType {
 String get displayName {
 switch (this) {
 case ReviewType.annual:
 return 'Annuelle';
 case ReviewType.semiAnnual:
 return 'Semestrielle';
 case ReviewType.quarterly:
 return 'Trimestrielle';
 case ReviewType.probation:
 return 'Période d\'essai';
 case ReviewType.special:
 return 'Spéciale';
}
 }
}

extension ReviewStatusExtension on ReviewStatus {
 String get displayName {
 switch (this) {
 case ReviewStatus.draft:
 return 'Brouillon';
 case ReviewStatus.inProgress:
 return 'En cours';
 case ReviewStatus.submitted:
 return 'Soumise';
 case ReviewStatus.reviewed:
 return 'Révisée';
 case ReviewStatus.approved:
 return 'Approuvée';
 case ReviewStatus.rejected:
 return 'Rejetée';
}
 }

 String get color {
 switch (this) {
 case ReviewStatus.draft:
 return '#9E9E9E'; // Grey
 case ReviewStatus.inProgress:
 return '#2196F3'; // Blue
 case ReviewStatus.submitted:
 return '#FF9800'; // Orange
 case ReviewStatus.reviewed:
 return '#9C27B0'; // Purple
 case ReviewStatus.approved:
 return '#4CAF50'; // Green
 case ReviewStatus.rejected:
 return '#F44336'; // Red
;
 }
}

extension PerformanceLevelExtension on PerformanceLevel {
 String get displayName {
 switch (this) {
 case PerformanceLevel.excellent:
 return 'Excellent';
 case PerformanceLevel.exceedsExpectations:
 return 'Dépasse les attentes';
 case PerformanceLevel.meetsExpectations:
 return 'Répond aux attentes';
 case PerformanceLevel.needsImprovement:
 return 'Besoin d\'amélioration';
 case PerformanceLevel.unsatisfactory:
 return 'Insatisfaisant';
}
 }

 String get color {
 switch (this) {
 case PerformanceLevel.excellent:
 return '#4CAF50'; // Green
 case PerformanceLevel.exceedsExpectations:
 return '#8BC34A'; // Light Green
 case PerformanceLevel.meetsExpectations:
 return '#2196F3'; // Blue
 case PerformanceLevel.needsImprovement:
 return '#FF9800'; // Orange
 case PerformanceLevel.unsatisfactory:
 return '#F44336'; // Red
;
 }

 int get numericValue {
 switch (this) {
 case PerformanceLevel.excellent:
 return 5;
 case PerformanceLevel.exceedsExpectations:
 return 4;
 case PerformanceLevel.meetsExpectations:
 return 3;
 case PerformanceLevel.needsImprovement:
 return 2;
 case PerformanceLevel.unsatisfactory:
 return 1;
}
 }
}
