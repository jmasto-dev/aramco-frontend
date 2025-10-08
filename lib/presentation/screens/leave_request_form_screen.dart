import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/leave_request_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/date_range_picker.dart';
import '../widgets/leave_type_selector.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';
import '../../core/models/leave_request.dart';
import '../../core/utils/validators.dart';

class LeaveRequestFormScreen extends ConsumerStatefulWidget {
 final LeaveRequest? leaveRequest; // Pour la modification
 final String? employeeId; // Pour la création

 const LeaveRequestFormScreen({
 super.key,
 this.leaveRequest,
 this.employeeId,
 });

 @override
 ConsumerState<LeaveRequestFormScreen> createState() => _LeaveRequestFormScreenState();
}

class _LeaveRequestFormScreenState extends ConsumerState<LeaveRequestFormScreen> {
 final _formKey = GlobalKey<FormState>();
 final _reasonController = TextEditingController();
 final _scrollController = ScrollController();

 LeaveType? _selectedLeaveType;
 LeavePriority? _selectedPriority = LeavePriority.medium;
 DateTime? _startDate;
 DateTime? _endDate;
 List<String> _attachments = [];
 Map<String, dynamic>? _availabilityInfo;

 bool _isEditing = false;
 bool _showTypeInfo = false;

 @override
 void initState() {
 super.initState();
 _isEditing = widget.leaveRequest != null;
 
 if (_isEditing) {{
 _initializeWithExistingRequest();
}
 }

 void _initializeWithExistingRequest() {
 final request = widget.leaveRequest!;
 setState(() {
 _selectedLeaveType = request.leaveType;
 _selectedPriority = request.priority;
 _startDate = request.startDate;
 _endDate = request.endDate;
 _reasonController.text = request.reason ?? '';
 _attachments = request.attachments ?? [];
});
 }

 @override
 void dispose() {
 _reasonController.dispose();
 _scrollController.dispose();
 super.dispose();
 }

 @override
 Widget build(BuildContext context) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;
 final authState = ref.watch(authProvider);
 final leaveRequestState = ref.watch(leaveRequestProvider);

 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: Text(_isEditing ? 'Modifier la demande' : 'Nouvelle demande de congé'),
 backgroundColor: colorScheme.primary,
 foregroundColor: colorScheme.onPrimary,
 actions: [
 if (_isEditing) .{..[
 IconButton(
 icon: const Icon(Icons.delete),
 onPressed: _showDeleteConfirmation,
 ),
 ],
 ],
 ),
 body: LoadingOverlay(
 isLoading: leaveRequestState.isLoading,
 child: Form(
 key: _formKey,
 child: Column(
 children: [
 Expanded(
 child: SingleChildScrollView(
 controller: _scrollController,
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 _buildHeader(context),
 const SizedBox(height: 24),
 _buildLeaveTypeSection(context),
 const SizedBox(height: 24),
 _buildDateRangeSection(context),
 const SizedBox(height: 24),
 _buildPrioritySection(context),
 const SizedBox(height: 24),
 _buildReasonSection(context),
 const SizedBox(height: 24),
 if (_selectedLeaveType?.requiresDocument == true) .{..[
 _buildAttachmentsSection(context),
 const SizedBox(height: 24),
 ],
 if (_showTypeInfo && _selectedLeaveType != null) .{..[
 LeaveTypeInfoWidget(leaveType: _selectedLeaveType!),
 const SizedBox(height: 24),
 ],
 if (_availabilityInfo != null) .{..[
 _buildAvailabilityInfo(context),
 const SizedBox(height: 24),
 ],
 ],
 ),
 ),
 ),
 _buildBottomActions(context),
 ],
 ),
 ),
 ),
 );
 }

 Widget _buildHeader(BuildContext context) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: colorScheme.primaryContainer.withOpacity(0.3),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Row(
 children: [
 Icon(
 _isEditing ? Icons.edit : Icons.add_circle_outline,
 color: colorScheme.primary,
 size: 24,
 ),
 const SizedBox(width: 12),
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 _isEditing 
 ? 'Modification de demande de congé'
 : 'Création d\'une nouvelle demande de congé',
 style: theme.textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.w600,
 color: colorScheme.primary,
 ),
 ),
 const SizedBox(height: 4),
 Text(
 _isEditing 
 ? 'Modifiez les informations de votre demande'
 : 'Remplissez les informations pour soumettre votre demande',
 style: theme.textTheme.bodyMedium?.copyWith(
 color: colorScheme.onSurface.withOpacity(0.8),
 ),
 ),
 ],
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildLeaveTypeSection(BuildContext context) {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 LeaveTypeSelector(
 selectedType: _selectedLeaveType,
 onTypeSelected: (type) {
 setState(() {
 _selectedLeaveType = type;
 _showTypeInfo = true;
});
 _validateAndCheckAvailability();
},
 enabled: !_isEditing,
 label: 'Type de congé',
 ),
 ],
 );
 }

 Widget _buildDateRangeSection(BuildContext context) {
 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 DateRangePickerWidget(
 startDate: _startDate,
 endDate: _endDate,
 onDateRangeChanged: (dateRange) {
 setState(() {
 _startDate = dateRange?.start;
 _endDate = dateRange?.end;
});
 _validateAndCheckAvailability();
},
 validator: _validateDateRange,
 firstDate: DateTime.now().subtract(const Duration(days: 30)),
 lastDate: DateTime.now().add(const Duration(days: 365)),
 ),
 ],
 );
 }

 Widget _buildPrioritySection(BuildContext context) {
 return LeavePrioritySelector(
 selectedPriority: _selectedPriority,
 onPrioritySelected: (priority) {
 setState(() {
 _selectedPriority = priority;
 });
 },
 label: 'Priorité',
 );
 }

 Widget _buildReasonSection(BuildContext context) {
 final isReasonRequired = _selectedLeaveType?.isReasonRequired ?? false;

 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Justification ${isReasonRequired ? '*' : ''}',
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.w600,
 ),
 ),
 const SizedBox(height: 8),
 CustomTextField(
 controller: _reasonController,
 label: isReasonRequired 
 ? 'Justification (obligatoire)' 
 : 'Justification (optionnelle)',
 hintText: 'Décrivez la raison de votre demande de congé...',
 maxLines: 4,
 validator: isReasonRequired 
 ? (value) {
 if (value == null || value.trim().{isEmpty) {
 return 'La justification est requise pour ce type de congé';
 }
 return null;
 }
 : null,
 textInputAction: TextInputAction.done,
 ),
 if (!isReasonRequired) .{..[
 const SizedBox(height: 8),
 Text(
 'La justification est optionnelle pour ce type de congé',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
 ),
 ),
 ],
 ],
 );
 }

 Widget _buildAttachmentsSection(BuildContext context) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Text(
 'Documents joints',
 style: theme.textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.w600,
 ),
 ),
 const SizedBox(width: 8),
 Icon(
 Icons.info_outline,
 color: colorScheme.primary,
 size: 20,
 ),
 ],
 ),
 const SizedBox(height: 8),
 Text(
 'Des documents sont requis pour ce type de congé',
 style: theme.textTheme.bodyMedium?.copyWith(
 color: colorScheme.onSurface.withOpacity(0.8),
 ),
 ),
 const SizedBox(height: 12),
 Container(
 width: double.infinity,
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 border: Border.all(
 color: colorScheme.outline.withOpacity(0.3),
 ),
 borderRadius: const Borderconst Radius.circular(1),
 color: colorScheme.surface,
 ),
 child: Column(
 children: [
 Icon(
 Icons.cloud_upload_outlined,
 size: 48,
 color: colorScheme.primary,
 ),
 const SizedBox(height: 8),
 Text(
 'Cliquez pour ajouter des documents',
 style: theme.textTheme.bodyMedium?.copyWith(
 color: colorScheme.primary,
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 4),
 Text(
 'PDF, JPG, PNG (max 5MB)',
 style: theme.textTheme.bodySmall?.copyWith(
 color: colorScheme.onSurface.withOpacity(0.6),
 ),
 ),
 const SizedBox(height: 12),
 CustomButton(
 text: 'Ajouter un document',
 onPressed: _addAttachment,
 type: ButtonType.secondary,
 ),
 ],
 ),
 ),
 if (_attachments.isNotEmpty) .{..[
 const SizedBox(height: 12),
 _buildAttachmentsList(context),
 ],
 ],
 );
 }

 Widget _buildAttachmentsList(BuildContext context) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Documents ajoutés (${_attachments.length})',
 style: theme.textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8),
 ..._attachments.asMap().entries.map((entry) {
 final index = entry.key;
 final attachment = entry.value;
 
 return Container(
 margin: const EdgeInsets.only(bottom: 8),
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 border: Border.all(
 color: colorScheme.outline.withOpacity(0.2),
 ),
 borderRadius: const Borderconst Radius.circular(1),
 color: colorScheme.surface,
 ),
 child: Row(
 children: [
 Icon(
 Icons.description_outlined,
 color: colorScheme.primary,
 size: 20,
 ),
 const SizedBox(width: 12),
 Expanded(
 child: Text(
 attachment.split('/').last,
 style: theme.textTheme.bodyMedium,
 overflow: TextOverflow.ellipsis,
 ),
 ),
 IconButton(
 icon: Icon(
 Icons.close,
 color: colorScheme.error,
 size: 20,
 ),
 onPressed: () => _removeAttachment(index),
 visualDensity: VisualDensity.compact,
 ),
 ],
 ),
 );
 }).toList(),
 ],
 );
 }

 Widget _buildAvailabilityInfo(BuildContext context) {
 final theme = Theme.of(context);
 final colorScheme = theme.colorScheme;

 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: colorScheme.primaryContainer.withOpacity(0.3),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(
 color: colorScheme.primary.withOpacity(0.3),
 ),
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 Icon(
 Icons.check_circle_outline,
 color: colorScheme.primary,
 size: 20,
 ),
 const SizedBox(width: 8),
 Text(
 'Disponibilité vérifiée',
 style: theme.textTheme.titleSmall?.copyWith(
 fontWeight: FontWeight.w600,
 color: colorScheme.primary,
 ),
 ),
 ],
 ),
 const SizedBox(height: 8),
 if (_availabilityInfo?['available_days'] != null) .{..[
 Text(
 'Jours disponibles: ${_availabilityInfo!['available_days']}',
 style: theme.textTheme.bodyMedium?.copyWith(
 color: colorScheme.onSurface,
 ),
 ),
 ],
 if (_availabilityInfo?['conflicts'] != null) .{..[
 const SizedBox(height: 4),
 Text(
 'Conflits détectés',
 style: theme.textTheme.bodyMedium?.copyWith(
 color: colorScheme.error,
 fontWeight: FontWeight.w500,
 ),
 ),
 ],
 ],
 ),
 );
 }

 Widget _buildBottomActions(BuildContext context) {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surface,
 boxShadow: [
 BoxShadow(
 color: Colors.black.withOpacity(0.1),
 blurRadius: 8,
 offset: const Offset(0, -2),
 ),
 ],
 ),
 child: Row(
 children: [
 Expanded(
 child: CustomButton(
 text: 'Annuler',
 onPressed: () => Navigator.of(context).pop(),
 type: ButtonType.secondary,
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 flex: 2,
 child: CustomButton(
 text: _isEditing ? 'Mettre à jour' : 'Soumettre la demande',
 onPressed: _submitForm,
 isLoading: false, // Géré par le LoadingOverlay
 ),
 ),
 ],
 ),
 );
 }

 String? _validateDateRange(DateTime? startDate, DateTime? endDate) {
 if (startDate == null || endDate == null) {{
 return 'Veuillez sélectionner une date de début et de fin';
}

 if (endDate.isBefore(startDate)){ {
 return 'La date de fin ne peut pas être avant la date de début';
}

 if (_selectedLeaveType != null) {{
 final totalDays = endDate.difference(startDate).inDays + 1;
 if (totalDays > _selectedLeaveType!.maxDays) {{
 return 'La durée maximale pour ce type de congé est de ${_selectedLeaveType!.maxDays} jours';
 }
}

 return null;
 }

 Future<void> _validateAndCheckAvailability() {async {
 if (_selectedLeaveType == null || _startDate == null || _endDate == null) {{
 return;
}

 final authState = ref.read(authProvider);
 if (authState.user?.id == null) r{eturn;

 final notifier = ref.read(leaveRequestProvider.notifier);
 final isAvailable = await notifier.checkLeaveAvailability(
 employeeId: authState.user!.id,
 leaveType: _selectedLeaveType!,
 startDate: _startDate!,
 endDate: _endDate!,
 );

 if (isAvailable) {{
 setState(() {
 _availabilityInfo = notifier.state.availabilityInfo;
 });
}
 }

 void _addAttachment() {
 // TODO: Implémenter la sélection de fichiers
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Fonctionnalité de téléchargement de fichiers bientôt disponible'),
 ),
 );
 }

 void _removeAttachment(int index) {
 setState(() {
 _attachments.removeAt(index);
});
 }

 Future<void> _submitForm() {async {
 if (!_formKey.currentState!.validate()){ {
 _scrollToFirstError();
 return;
}

 if (_selectedLeaveType == null) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Veuillez sélectionner un type de congé'),
 backgroundColor: Colors.red,
 ),
 );
 return;
}

 final authState = ref.read(authProvider);
 if (authState.user?.id == null) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Utilisateur non authentifié'),
 backgroundColor: Colors.red,
 ),
 );
 return;
}

 final now = DateTime.now();
 final totalDays = _endDate!.difference(_startDate!).inDays + 1;

 final leaveRequest = LeaveRequest(
 id: _isEditing ? widget.leaveRequest!.id : const Uuid().v4(),
 employeeId: _isEditing 
 ? widget.leaveRequest!.employeeId 
 : authState.user!.id,
 leaveType: _selectedLeaveType!,
 startDate: _startDate!,
 endDate: _endDate!,
 reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
 status: _isEditing ? widget.leaveRequest!.status : LeaveStatus.pending,
 priority: _selectedPriority!,
 totalDays: totalDays,
 paidDays: LeaveRequest.calculatePaidDays(_selectedLeaveType!, totalDays),
 unpaidDays: LeaveRequest.calculateUnpaidDays(_selectedLeaveType!, totalDays),
 attachments: _attachments.isEmpty ? null : _attachments,
 createdAt: _isEditing ? widget.leaveRequest!.createdAt : now,
 updatedAt: now,
 createdBy: _isEditing ? widget.leaveRequest!.createdBy : authState.user!.id,
 updatedBy: authState.user!.id,
 );

 final notifier = ref.read(leaveRequestProvider.notifier);
 bool success;

 if (_isEditing) {{
 success = await notifier.updateLeaveRequest(widget.leaveRequest!.id, leaveRequest);
} else {
 success = await notifier.createLeaveRequest(leaveRequest);
}

 if (success && mounted) {{
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(_isEditing 
 ? 'Demande de congé mise à jour avec succès'
 : 'Demande de congé créée avec succès'),
 backgroundColor: Colors.green,
 ),
 );
 Navigator.of(context).pop(true);
} else if (mounted) {{
 final error = notifier.state.error ?? 'Une erreur est survenue';
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(error),
 backgroundColor: Colors.red,
 ),
 );
}
 }

 void _scrollToFirstError() {
 WidgetsBinding.instance.addPostFrameCallback((_) {
 if (_formKey.currentState != null) {{
 _scrollController.animateTo(
 0,
 duration: const Duration(milliseconds: 300),
 curve: Curves.easeInOut,
 );
 }
});
 }

 void _showDeleteConfirmation() {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Supprimer la demande'),
 content: const Text(
 'Êtes-vous sûr de vouloir supprimer cette demande de congé ? Cette action est irréversible.',
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.of(context).pop(),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () async {
 Navigator.of(context).pop();
 await _deleteLeaveRequest();
},
 style: TextButton.styleFrom(
 foregroundColor: Theme.of(context).colorScheme.error,
 ),
 child: const Text('Supprimer'),
 ),
 ],
 ),
 );
 }

 Future<void> _deleteLeaveRequest() {async {
 if (widget.leaveRequest == null) r{eturn;

 final notifier = ref.read(leaveRequestProvider.notifier);
 final success = await notifier.deleteLeaveRequest(widget.leaveRequest!.id);

 if (success && mounted) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Demande de congé supprimée avec succès'),
 backgroundColor: Colors.green,
 ),
 );
 Navigator.of(context).pop(true);
} else if (mounted) {{
 final error = notifier.state.error ?? 'Une erreur est survenue';
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(error),
 backgroundColor: Colors.red,
 ),
 );
}
 }
}
