import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aramco_frontend/core/models/performance_review.dart';
import 'package:aramco_frontend/core/models/employee.dart';
import 'package:aramco_frontend/presentation/widgets/rating_widget.dart';
import 'package:aramco_frontend/presentation/widgets/competency_card.dart';
import 'package:aramco_frontend/presentation/widgets/custom_button.dart';
import 'package:aramco_frontend/presentation/widgets/loading_overlay.dart';
import 'package:aramco_frontend/core/app_theme.dart';

/// Provider pour l'état des évaluations de performance
class PerformanceReviewNotifier extends StateNotifier<PerformanceReviewState> {
 PerformanceReviewNotifier() : super(const PerformanceReviewState());

 void createNewReview({
 required String employeeId,
 required String reviewerId,
 required String reviewPeriod,
 required ReviewType reviewType,
 }) {
 state = state.copyWith(isLoading: true);
 
 try {
 final review = PerformanceReview.create(
 employeeId: employeeId,
 reviewerId: reviewerId,
 reviewPeriod: reviewPeriod,
 reviewType: reviewType,
 );
 
 state = state.copyWith(
 currentReview: review,
 isLoading: false,
 );
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors de la création: $e',
 );
}
 }

 void updateCompetencies(List<Competency> competencies) {
 if (state.currentReview == null) r{eturn;
 
 final updatedReview = state.currentReview!.copyWith(
 competencies: competencies,
 finalScore: _calculateFinalScore(competencies),
 );
 
 state = state.copyWith(currentReview: updatedReview);
 }

 void updateOverallRating(PerformanceLevel rating) {
 if (state.currentReview == null) r{eturn;
 
 final updatedReview = state.currentReview!.copyWith(
 overallRating: rating,
 );
 
 state = state.copyWith(currentReview: updatedReview);
 }

 void updateOverallComments(String comments) {
 if (state.currentReview == null) r{eturn;
 
 final updatedReview = state.currentReview!.copyWith(
 overallComments: comments.isEmpty ? null : comments,
 );
 
 state = state.copyWith(currentReview: updatedReview);
 }

 void updateGoals(List<SmartGoal> goals) {
 if (state.currentReview == null) r{eturn;
 
 final updatedReview = state.currentReview!.copyWith(goals: goals);
 state = state.copyWith(currentReview: updatedReview);
 }

 Future<bool> submitReview() {async {
 if (state.currentReview == null || !state.currentReview!.canSubmit) {{
 state = state.copyWith(
 error: 'Veuillez compléter toutes les sections avant de soumettre',
 );
 return false;
}

 state = state.copyWith(isSubmitting: true);

 try {
 // Simuler l'API call
 await Future.delayed(const Duration(seconds: 2));
 
 final submittedReview = state.currentReview!.copyWith(
 status: ReviewStatus.submitted,
 submittedAt: DateTime.now(),
 );
 
 state = state.copyWith(
 currentReview: submittedReview,
 isSubmitting: false,
 );
 
 return true;
} catch (e) {
 state = state.copyWith(
 isSubmitting: false,
 error: 'Erreur lors de la soumission: $e',
 );
 return false;
}
 }

 void clearError() {
 state = state.copyWith(error: null);
 }

 double _calculateFinalScore(List<Competency> competencies) {
 if (competencies.isEmpty) r{eturn 0.0;
 
 final totalWeight = competencies.fold(0.0, (sum, comp) => sum + comp.weight);
 if (totalWeight == 0.0) r{eturn 0.0;
 
 final totalScore = competencies.fold(0.0, (sum, comp) => sum + comp.weightedScore);
 return totalScore / totalWeight;
 }
}

/// État des évaluations de performance
@immutable
class PerformanceReviewState {
 final PerformanceReview? currentReview;
 final bool isLoading;
 final bool isSubmitting;
 final String? error;

 const PerformanceReviewState({
 this.currentReview,
 this.isLoading = false,
 this.isSubmitting = false,
 this.error,
 });

 PerformanceReviewState copyWith({
 PerformanceReview? currentReview,
 bool? isLoading,
 bool? isSubmitting,
 String? error,
 bool clearError = false,
 }) {
 return PerformanceReviewState(
 currentReview: currentReview ?? this.currentReview,
 isLoading: isLoading ?? this.isLoading,
 isSubmitting: isSubmitting ?? this.isSubmitting,
 error: clearError ? null : (error ?? this.error),
 );
 }
}

/// Provider pour le notifier d'évaluations
final performanceReviewProvider = StateNotifierProvider<PerformanceReviewNotifier, PerformanceReviewState>(
 (ref) => PerformanceReviewNotifier(),
);

/// Écran principal des évaluations de performance
class PerformanceReviewScreen extends ConsumerStatefulWidget {
 final Employee? employee;
 final PerformanceReview? existingReview;

 const PerformanceReviewScreen({
 super.key,
 this.employee,
 this.existingReview,
 });

 @override
 ConsumerState<PerformanceReviewScreen> createState() => _PerformanceReviewScreenState();
}

class _PerformanceReviewScreenState extends ConsumerState<PerformanceReviewScreen>
 with TickerProviderStateMixin {
 late TabController _tabController;
 final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
 final TextEditingController _commentsController = TextEditingController();
 final TextEditingController _goalTitleController = TextEditingController();
 final TextEditingController _goalDescriptionController = TextEditingController();

 @override
 void initState() {
 super.initState();
 _tabController = TabController(length: 4, vsync: this);
 
 // Initialiser avec une évaluation existante ou en créer une nouvelle
 if (widget.existingReview != null) {{
 _initializeExistingReview();
} else if (widget.employee != null) {{
 _createNewReview();
}
 }

 @override
 void dispose() {
 _tabController.dispose();
 _commentsController.dispose();
 _goalTitleController.dispose();
 _goalDescriptionController.dispose();
 super.dispose();
 }

 void _initializeExistingReview() {
 // TODO: Initialiser avec l'évaluation existante
 ;

 void _createNewReview() {
 final reviewNotifier = ref.read(performanceReviewProvider.notifier);
 reviewNotifier.createNewReview(
 employeeId: widget.employee!.id,
 reviewerId: 'current_user_id', // TODO: Récupérer l'utilisateur actuel
 reviewPeriod: '2024-Q4', // TODO: Rendre configurable
 reviewType: ReviewType.annual,
 );
 }

 @override
 Widget build(BuildContext context) {
 final reviewState = ref.watch(performanceReviewProvider);
 final reviewNotifier = ref.read(performanceReviewProvider.notifier);

 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Évaluation de Performance'),
 backgroundColor: AppTheme.primaryColor,
 foregroundColor: Colors.white,
 bottom: TabBar(
 controller: _tabController,
 indicatorColor: Colors.white,
 labelColor: Colors.white,
 unselectedLabelColor: Colors.white70,
 tabs: const [
 Tab(text: 'Compétences', icon: Icon(Icons.star)),
 Tab(text: 'Objectifs', icon: Icon(Icons.flag)),
 Tab(text: 'Évaluation', icon: Icon(Icons.analytics)),
 Tab(text: 'Signature', icon: Icon(Icons.draw)),
 ],
 ),
 actions: [
 if (reviewState.currentReview != null) .{..[
 IconButton(
 icon: const Icon(Icons.save),
 onPressed: _saveDraft,
 tooltip: 'Sauvegarder brouillon',
 ),
 IconButton(
 icon: const Icon(Icons.send),
 onPressed: reviewState.currentReview!.canSubmit ? _submitReview : null,
 tooltip: 'Soumettre l\'évaluation',
 ),
 ],
 ],
 ),
 body: reviewState.isLoading
 ? const Center(child: CircularProgressIndicator())
 : reviewState.error != null
 ? _buildErrorWidget(reviewState.error!)
 : reviewState.currentReview == null
 ? _buildEmptyWidget()
 : Form(
 key: _formKey,
 child: TabBarView(
 controller: _tabController,
 children: [
 _buildCompetenciesTab(reviewState.currentReview!),
 _buildGoalsTab(reviewState.currentReview!),
 _buildEvaluationTab(reviewState.currentReview!),
 _buildSignatureTab(reviewState.currentReview!),
 ],
 ),
 ),
 bottomNavigationBar: reviewState.isSubmitting
 ? const LinearProgressIndicator()
 : null,
 );
 }

 Widget _buildCompetenciesTab(PerformanceReview review) {
 return Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 children: [
 // En-tête
 Row(
 children: [
 Icon(
 Icons.person,
 color: AppTheme.primaryColor,
 ),
 const SizedBox(width: 8),
 Text(
 'Évaluation des compétences',
 style: Theme.of(context).textTheme.titleLarge?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 const SizedBox(height: 8),
 Text(
 'Évaluez chaque compétence sur une échelle de 1 à 5',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: Colors.grey.shade600,
 ),
 ),
 const SizedBox(height: 16),
 
 // Liste des compétences
 Expanded(
 child: CompetencyListWidget(
 competencies: review.competencies,
 onCompetenciesChanged: (competencies) {
 ref.read(performanceReviewProvider.notifier).updateCompetencies(competencies);
 },
 enabled: review.status == ReviewStatus.draft,
 showSummary: true,
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildGoalsTab(PerformanceReview review) {
 return Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 children: [
 // En-tête avec bouton d'ajout
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Objectifs SMART',
 style: Theme.of(context).textTheme.titleLarge?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ElevatedButton.icon(
 onPressed: review.status == ReviewStatus.draft ? _addGoal : null,
 icon: const Icon(Icons.add),
 label: const Text('Ajouter un objectif'),
 ),
 ],
 ),
 const SizedBox(height: 16),
 
 // Liste des objectifs
 Expanded(
 child: review.goals.isEmpty
 ? _buildEmptyGoalsWidget()
 : ListView.builder(
 itemCount: review.goals.length,
 itemBuilder: (context, index) {
 final goal = review.goals[index];
 return _buildGoalCard(goal, index, review);
 },
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildEvaluationTab(PerformanceReview review) {
 return SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Score calculé
 Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 children: [
 Text(
 'Score final calculé',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 8),
 Text(
 review.finalScore?.toStringAsFixed(2) ?? '0.00',
 style: Theme.of(context).textTheme.headlineLarge?.copyWith(
 color: AppTheme.primaryColor,
 fontWeight: FontWeight.bold,
 ),
 ),
 Text(
 '/ 5.00',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 color: Colors.grey.shade600,
 ),
 ),
 ],
 ),
 ),
 ),
 
 const SizedBox(height: 16),
 
 // Niveau de performance global
 PerformanceLevelSelector(
 selectedLevel: review.overallRating,
 onLevelChanged: (level) {
 ref.read(performanceReviewProvider.notifier).updateOverallRating(level);
},
 enabled: review.status == ReviewStatus.draft,
 ),
 
 const SizedBox(height: 16),
 
 // Commentaires globaux
 Text(
 'Commentaires globaux',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 8),
 TextField(
 controller: _commentsController
 ..text = review.overallComments ?? '',
 enabled: review.status == ReviewStatus.draft,
 maxLines: 5,
 decoration: InputDecoration(
 hintText: 'Ajoutez vos commentaires généraux sur la performance de l\'employé...',
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 filled: true,
 fillColor: review.status == ReviewStatus.draft ? Colors.grey.shade50 : Colors.grey.shade100,
 ),
 onChanged: (value) {
 ref.read(performanceReviewProvider.notifier).updateOverallComments(value);
},
 ),
 
 const SizedBox(height: 16),
 
 // Statut de complétion
 _buildCompletionStatus(review),
 ],
 ),
 );
 }

 Widget _buildSignatureTab(PerformanceReview review) {
 return Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 children: [
 Text(
 'Signatures',
 style: Theme.of(context).textTheme.titleLarge?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 16),
 
 // Signatures existantes
 if (review.signatures.isNotEmpty) .{..[
 ...review.signatures.map((signature) => _buildSignatureCard(signature)),
 const SizedBox(height: 16),
 ],
 
 // Bouton de signature
 if (review.status == ReviewStatus.submitted || review.status == ReviewStatus.reviewed)
 C{ustomButton(
 text: 'Signer l\'évaluation',
 onPressed: _signReview,
 icon: Icons.draw,
 ),
 
 const Spacer(),
 
 // Actions finales
 Row(
 children: [
 Expanded(
 child: CustomButton(
 text: 'Exporter en PDF',
 onPressed: _exportToPDF,
 icon: Icons.download,
 type: ButtonType.secondary,
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: CustomButton(
 text: 'Imprimer',
 onPressed: _printReview,
 icon: Icons.print,
 type: ButtonType.secondary,
 ),
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildErrorWidget(String error) {
 return Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.error_outline,
 size: 64,
 color: Colors.red[400],
 ),
 const SizedBox(height: 16),
 Text(
 'Erreur',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 const SizedBox(height: 8),
 Text(
 error,
 textAlign: TextAlign.center,
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: Colors.grey[600],
 ),
 ),
 const SizedBox(height: 24),
 CustomButton(
 text: 'Réessayer',
 onPressed: () {
 ref.read(performanceReviewProvider.notifier).clearError();
 if (widget.employee != null) {{
 _createNewReview();
 }
 },
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildEmptyWidget() {
 return Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.assignment,
 size: 64,
 color: Colors.grey[400],
 ),
 const SizedBox(height: 16),
 Text(
 'Aucune évaluation',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 const SizedBox(height: 8),
 Text(
 'Sélectionnez un employé pour commencer une évaluation',
 textAlign: TextAlign.center,
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: Colors.grey[600],
 ),
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildEmptyGoalsWidget() {
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.flag,
 size: 64,
 color: Colors.grey[400],
 ),
 const SizedBox(height: 16),
 Text(
 'Aucun objectif défini',
 style: Theme.of(context).textTheme.titleMedium,
 ),
 const SizedBox(height: 8),
 Text(
 'Ajoutez des objectifs SMART pour cet employé',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: Colors.grey.shade600,
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildGoalCard(SmartGoal goal, int index, PerformanceReview review) {
 return Card(
 margin: const EdgeInsets.only(bottom: 8),
 child: ListTile(
 leading: Checkbox(
 value: goal.isCompleted,
 onChanged: review.status == ReviewStatus.draft ? (value) {
 final updatedGoal = goal.copyWith(isCompleted: value ?? false);
 final updatedGoals = List<SmartGoal>.from(review.goals);
 updatedGoals[index] = updatedGoal;
 ref.read(performanceReviewProvider.notifier).updateGoals(updatedGoals);
} : null,
 ),
 title: Text(goal.title),
 subtitle: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(goal.description),
 const SizedBox(height: 4),
 LinearProgressIndicator(
 value: goal.progress,
 backgroundColor: Colors.grey.shade300,
 valueColor: AlwaysStoppedAnimation<Color>(
 goal.isCompleted ? Colors.green : AppTheme.primaryColor,
 ),
 ),
 Text('${(goal.progress * 100).toInt()}%'),
 ],
 ),
 trailing: review.status == ReviewStatus.draft
 ? IconButton(
 icon: const Icon(Icons.delete),
 onPressed: () {
 final updatedGoals = List<SmartGoal>.from(review.goals);
 updatedGoals.removeAt(index);
 ref.read(performanceReviewProvider.notifier).updateGoals(updatedGoals);
 },
 )
 : null,
 ),
 );
 }

 Widget _buildCompletionStatus(PerformanceReview review) {
 final isComplete = review.isComplete;
 
 return Card(
 color: isComplete ? Colors.green.shade50 : Colors.orange.shade50,
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Row(
 children: [
 Icon(
 isComplete ? Icons.check_circle : Icons.warning,
 color: isComplete ? Colors.green : Colors.orange,
 ),
 const SizedBox(width: 12),
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 isComplete ? 'Évaluation complète' : 'Évaluation incomplète',
 style: const TextStyle(
 fontWeight: FontWeight.bold,
 color: isComplete ? Colors.green : Colors.orange,
 ),
 ),
 if (!isComplete)
 T{ext(
 'Veuillez compléter toutes les sections avant de soumettre',
 style: const TextStyle(
 fontSize: 12,
 color: Colors.orange.shade700,
 ),
 ),
 ],
 ),
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildSignatureCard(DigitalSignature signature) {
 return Card(
 margin: const EdgeInsets.only(bottom: 8),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(Icons.person, size: 20, color: Colors.grey.shade600),
 const SizedBox(width: 8),
 Text(
 signature.signerName,
 style: const TextStyle(fontWeight: FontWeight.bold),
 ),
 const Spacer(),
 Text(
 signature.signerRole,
 style: const TextStyle(
 color: Colors.grey.shade600,
 fontSize: 12,
 ),
 ),
 ],
 ),
 const SizedBox(height: 4),
 Text(
 'Signé le ${signature.signedAt.toString().split(' ')[0]}',
 style: const TextStyle(
 color: Colors.grey.shade600,
 fontSize: 12,
 ),
 ),
 if (signature.comments != null) .{..[
 const SizedBox(height: 8),
 Text(signature.comments!),
 ],
 ],
 ),
 ),
 );
 }

 void _addGoal() {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Ajouter un objectif SMART'),
 content: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 TextField(
 controller: _goalTitleController,
 decoration: const InputDecoration(
 labelText: 'Titre de l\'objectif',
 border: OutlineInputBorder(),
 ),
 ),
 const SizedBox(height: 16),
 TextField(
 controller: _goalDescriptionController,
 maxLines: 3,
 decoration: const InputDecoration(
 labelText: 'Description',
 border: OutlineInputBorder(),
 ),
 ),
 ],
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 ElevatedButton(
 onPressed: () {
 if (_goalTitleController.text.isNotEmpty) {{
 final newGoal = SmartGoal(
 id: DateTime.now().millisecondsSinceEpoch.toString(),
 title: _goalTitleController.text,
 description: _goalDescriptionController.text,
 isCompleted: false,
 progress: 0.0,
 );
 
 final review = ref.read(performanceReviewProvider).currentReview!;
 final updatedGoals = List<SmartGoal>.from(review.goals)..add(newGoal);
 ref.read(performanceReviewProvider.notifier).updateGoals(updatedGoals);
 
 _goalTitleController.clear();
 _goalDescriptionController.clear();
 Navigator.pop(context);
 }
},
 child: const Text('Ajouter'),
 ),
 ],
 ),
 );
 }

 void _saveDraft() {
 // TODO: Implémenter la sauvegarde du brouillon
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Brouillon sauvegardé'),
 backgroundColor: Colors.green,
 ),
 );
 }

 void _submitReview() async {
 final success = await ref.read(performanceReviewProvider.notifier).submitReview();
 
 if (success && mounted) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Évaluation soumise avec succès'),
 backgroundColor: Colors.green,
 ),
 );
} else if (!success && mounted) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Erreur lors de la soumission'),
 backgroundColor: Colors.red,
 ),
 );
}
 }

 void _signReview() {
 // TODO: Implémenter la signature
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Signature à implémenter'),
 ),
 );
 }

 void _exportToPDF() {
 // TODO: Implémenter l'export PDF
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Export PDF à implémenter'),
 ),
 );
 }

 void _printReview() {
 // TODO: Implémenter l'impression
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Impression à implémenter'),
 ),
 );
 }
}
