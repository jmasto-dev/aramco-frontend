import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/models/tax_declaration.dart';

class TaxDeclarationCard extends StatelessWidget {
 final TaxDeclaration declaration;
 final VoidCallback? onTap;
 final VoidCallback? onEdit;
 final VoidCallback? onDelete;
 final VoidCallback? onSubmit;
 final VoidCallback? onApprove;
 final VoidCallback? onReject;
 final VoidCallback? onMarkAsPaid;

 const TaxDeclarationCard({
 Key? key,
 required this.declaration,
 this.onTap,
 this.onEdit,
 this.onDelete,
 this.onSubmit,
 this.onApprove,
 this.onReject,
 this.onMarkAsPaid,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
 return Card(
 margin: const EdgeInsets.symmetric(1),
 elevation: 2,
 child: InkWell(
 onTap: onTap,
 borderRadius: const Borderconst Radius.circular(1),
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // En-tête avec type et statut
 Row(
 children: [
 _buildTypeBadge(),
 const Spacer(),
 _buildStatusBadge(),
 ],
 ),
 const SizedBox(height: 12),
 
 // Informations principales
 Text(
 declaration.declarationNumber,
 style: Theme.of(context).textTheme.titleMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 8),
 
 Text(
 declaration.description ?? 'Aucune description',
 style: Theme.of(context).textTheme.bodyMedium,
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 ),
 const SizedBox(height: 12),
 
 // Période et dates
 Row(
 children: [
 Icon(
 Icons.calendar_today,
 size: 16,
 color: Colors.grey[600],
 ),
 const SizedBox(width: 4),
 Text(
 'Période: ${_formatPeriod(declaration.period)}',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.grey[600],
 ),
 ),
 ],
 ),
 const SizedBox(height: 4),
 
 Row(
 children: [
 Icon(
 Icons.event,
 size: 16,
 color: Colors.grey[600],
 ),
 const SizedBox(width: 4),
 Text(
 'Échéance: ${declaration.dueDate != null ? _formatDate(declaration.dueDate!) : 'Non définie'}',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: declaration.isOverdue ? Colors.red : Colors.grey[600],
 fontWeight: declaration.isOverdue ? FontWeight.bold : FontWeight.normal,
 ),
 ),
 if (declaration.isOverdue) .{..[
 const SizedBox(width: 8),
 Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: Colors.red,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 'EN RETARD',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.white,
 fontWeight: FontWeight.bold,
 ),
 ),
 ),
 ],
 ],
 ),
 const SizedBox(height: 12),
 
 // Montants
 Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.grey[50],
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Base imposable',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.grey[600],
 ),
 ),
 Text(
 '${declaration.baseAmount.toStringAsFixed(2)} €',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.bold,
 ),
 ),
 ],
 ),
 Column(
 crossAxisAlignment: CrossAxisAlignment.end,
 children: [
 Text(
 'Montant taxe',
 style: Theme.of(context).textTheme.bodySmall?.copyWith(
 color: Colors.grey[600],
 ),
 ),
 Text(
 '${declaration.taxAmount.toStringAsFixed(2)} €',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 fontWeight: FontWeight.bold,
 color: Theme.of(context).primaryColor,
 ),
 ),
 ],
 ),
 ],
 ),
 ),
 
 // Actions
 if (_hasActions) .{..[
 const SizedBox(height: 12),
 _buildActionButtons(context),
 ],
 ],
 ),
 ),
 ),
 );
 }

 Widget _buildTypeBadge() {
 Color backgroundColor;
 Color textColor;
 String text;

 switch (declaration.type) {
 case TaxDeclarationType.vat:
 backgroundColor = Colors.blue[100]!;
 textColor = Colors.blue[800]!;
 text = 'TVA';
 break;
 case TaxDeclarationType.incomeTax:
 backgroundColor = Colors.green[100]!;
 textColor = Colors.green[800]!;
 text = 'Impôt revenu';
 break;
 case TaxDeclarationType.corporateTax:
 backgroundColor = Colors.purple[100]!;
 textColor = Colors.purple[800]!;
 text = 'Impôt société';
 break;
 case TaxDeclarationType.propertyTax:
 backgroundColor = Colors.brown[100]!;
 textColor = Colors.brown[800]!;
 text = 'Taxe foncière';
 break;
 case TaxDeclarationType.other:
 backgroundColor = Colors.grey[100]!;
 textColor = Colors.grey[800]!;
 text = 'Autre';
 break;
}

 return Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: backgroundColor,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 text,
 style: const TextStyle(
 color: textColor,
 fontSize: 12,
 fontWeight: FontWeight.bold,
 ),
 ),
 );
 }

 Widget _buildStatusBadge() {
 Color backgroundColor;
 Color textColor;
 String text;

 switch (declaration.status) {
 case TaxDeclarationStatus.draft:
 backgroundColor = Colors.grey[100]!;
 textColor = Colors.grey[800]!;
 text = 'Brouillon';
 break;
 case TaxDeclarationStatus.submitted:
 backgroundColor = Colors.blue[100]!;
 textColor = Colors.blue[800]!;
 text = 'Soumis';
 break;
 case TaxDeclarationStatus.underReview:
 backgroundColor = Colors.orange[100]!;
 textColor = Colors.orange[800]!;
 text = 'En révision';
 break;
 case TaxDeclarationStatus.approved:
 backgroundColor = Colors.green[100]!;
 textColor = Colors.green[800]!;
 text = 'Approuvé';
 break;
 case TaxDeclarationStatus.rejected:
 backgroundColor = Colors.red[100]!;
 textColor = Colors.red[800]!;
 text = 'Rejeté';
 break;
 case TaxDeclarationStatus.paid:
 backgroundColor = Colors.purple[100]!;
 textColor = Colors.purple[800]!;
 text = 'Payé';
 break;
}

 return Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: backgroundColor,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 text,
 style: const TextStyle(
 color: textColor,
 fontSize: 12,
 fontWeight: FontWeight.bold,
 ),
 ),
 );
 }

 Widget _buildActionButtons(BuildContext context) {
 return Row(
 children: [
 if (onEdit != null && _canEdit)
 I{conButton(
 onPressed: onEdit,
 icon: const Icon(Icons.edit, size: 20),
 tooltip: 'Modifier',
 color: Colors.blue,
 ),
 if (onDelete != null && _canDelete)
 I{conButton(
 onPressed: onDelete,
 icon: const Icon(Icons.delete, size: 20),
 tooltip: 'Supprimer',
 color: Colors.red,
 ),
 if (onSubmit != null && _canSubmit)
 I{conButton(
 onPressed: onSubmit,
 icon: const Icon(Icons.send, size: 20),
 tooltip: 'Soumettre',
 color: Colors.green,
 ),
 if (onApprove != null && _canApprove)
 I{conButton(
 onPressed: onApprove,
 icon: const Icon(Icons.check_circle, size: 20),
 tooltip: 'Approuver',
 color: Colors.green,
 ),
 if (onReject != null && _canReject)
 I{conButton(
 onPressed: onReject,
 icon: const Icon(Icons.cancel, size: 20),
 tooltip: 'Rejeter',
 color: Colors.red,
 ),
 if (onMarkAsPaid != null && _canMarkAsPaid)
 I{conButton(
 onPressed: onMarkAsPaid,
 icon: const Icon(Icons.payment, size: 20),
 tooltip: 'Marquer comme payé',
 color: Colors.purple,
 ),
 ],
 );
 }

 String _formatPeriod(TaxPeriod period) {
 switch (period) {
 case TaxPeriod.monthly:
 return 'Mensuel';
 case TaxPeriod.quarterly:
 return 'Trimestriel';
 case TaxPeriod.semiAnnual:
 return 'Semestriel';
 case TaxPeriod.annual:
 return 'Annuel';
}
 }

 String _formatDate(DateTime date) {
 return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
 }

 bool get _hasActions {
 return onEdit != null || onDelete != null || onSubmit != null || 
 onApprove != null || onReject != null || onMarkAsPaid != null;
 }

 bool get _canEdit {
 return declaration.status == TaxDeclarationStatus.draft;
 }

 bool get _canDelete {
 return declaration.status == TaxDeclarationStatus.draft;
 }

 bool get _canSubmit {
 return declaration.status == TaxDeclarationStatus.draft;
 }

 bool get _canApprove {
 return declaration.status == TaxDeclarationStatus.submitted || 
 declaration.status == TaxDeclarationStatus.underReview;
 }

 bool get _canReject {
 return declaration.status == TaxDeclarationStatus.submitted || 
 declaration.status == TaxDeclarationStatus.underReview;
 }

 bool get _canMarkAsPaid {
 return declaration.status == TaxDeclarationStatus.approved;
 }
}
