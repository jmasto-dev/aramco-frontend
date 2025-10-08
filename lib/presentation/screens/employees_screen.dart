import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aramco_frontend/core/models/employee.dart';
import 'package:aramco_frontend/presentation/providers/employee_provider.dart';
import 'package:aramco_frontend/presentation/widgets/custom_button.dart';
import 'package:aramco_frontend/presentation/widgets/loading_overlay.dart';
import 'package:aramco_frontend/core/app_theme.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
 const EmployeesScreen({super.key});

 @override
 ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
 final ScrollController _scrollController = ScrollController();
 final TextEditingController _searchController = TextEditingController();
 EmployeeFilters _currentFilters = const EmployeeFilters();
 bool _isSearching = false;

 @override
 void initState() {
 super.initState();
 _scrollController.addListener(_onScroll);
 WidgetsBinding.instance.addPostFrameCallback((_) {
 ref.read(employeeProvider.notifier).loadEmployees();
});
 }

 @override
 void dispose() {
 _scrollController.dispose();
 _searchController.dispose();
 super.dispose();
 }

 void _onScroll() {
 if (_scrollController.position.pixels >= 
 _scrollController.position.maxScrollExtent - 200) {{
 ref.read(employeeProvider.notifier).loadMoreEmployees();
}
 }

 void _onSearchChanged(String query) {
 if (_isSearching) r{eturn;
 _isSearching = true;
 
 Future.delayed(const Duration(milliseconds: 500), () {
 if (mounted) {{
 ref.read(employeeProvider.notifier).searchEmployees(query);
 _isSearching = false;
 }
});
 }

 void _showFilterDialog() {
 showDialog(
 context: context,
 builder: (context) => EmployeeFilterDialog(
 currentFilters: _currentFilters,
 onFiltersChanged: (filters) {
 setState(() {
 _currentFilters = filters;
});
 ref.read(employeeProvider.notifier).applyFilters(filters);
 },
 ),
 );
 }

 void _showEmployeeDetails(Employee employee) {
 Navigator.push(
 context,
 MaterialPageRoute(
 builder: (context) => EmployeeDetailsScreen(employee: employee),
 ),
 );
 }

 void _showAddEmployeeDialog() {
 Navigator.push(
 context,
 MaterialPageRoute(
 builder: (context) => const EmployeeFormScreen(),
 ),
 );
 }

 @override
 Widget build(BuildContext context) {
 final employeeState = ref.watch(employeeProvider);
 final employees = employeeState.filteredEmployees;

 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Gestion des Employés'),
 backgroundColor: AppTheme.primaryColor,
 foregroundColor: Colors.white,
 actions: [
 IconButton(
 icon: const Icon(Icons.filter_list),
 onPressed: _showFilterDialog,
 tooltip: 'Filtrer',
 ),
 IconButton(
 icon: const Icon(Icons.refresh),
 onPressed: () => ref.read(employeeProvider.notifier).refreshEmployees(),
 tooltip: 'Actualiser',
 ),
 PopupMenuButton<String>(
 onSelected: (value) {
 switch (value) {
 case 'export':
 _exportEmployees();
 break;
 case 'stats':
 _showStatsDialog();
 break;
 }
},
 itemBuilder: (context) => [
 const PopupMenuItem(
 value: 'export',
 child: Row(
 children: [
 Icon(Icons.download),
 const SizedBox(width: 8),
 Text('Exporter'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'stats',
 child: Row(
 children: [
 Icon(Icons.bar_chart),
 const SizedBox(width: 8),
 Text('Statistiques'),
 ],
 ),
 ),
 ],
 ),
 ],
 ),
 body: Column(
 children: [
 // Barre de recherche
 Container(
 padding: const EdgeInsets.all(1),
 child: TextField(
 controller: _searchController,
 decoration: InputDecoration(
 hintText: 'Rechercher un employé...',
 prefixIcon: const Icon(Icons.search),
 suffixIcon: _searchController.text.isNotEmpty
 ? IconButton(
 icon: const Icon(Icons.clear),
 onPressed: () {
 _searchController.clear();
 ref.read(employeeProvider.notifier).clearFilters();
},
 )
 : null,
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 filled: true,
 fillColor: Colors.grey[50],
 ),
 onChanged: _onSearchChanged,
 ),
 ),

 // Filtres actifs
 if (_currentFilters.hasFilters)
 C{ontainer(
 padding: const EdgeInsets.symmetric(1),
 child: Wrap(
 spacing: 8,
 children: [
 Chip(
 label: const Text('Effacer les filtres'),
 deleteIcon: const Icon(Icons.close),
 onDeleted: () {
 setState(() {
 _currentFilters = const EmployeeFilters();
});
 ref.read(employeeProvider.notifier).clearFilters();
 },
 ),
 if (_currentFilters.department != Department.all)
 C{hip(
 label: Text(_currentFilters.department.displayName),
 ),
 if (_currentFilters.position != Position.all)
 C{hip(
 label: Text(_currentFilters.position.displayName),
 ),
 if (_currentFilters.isActive != null)
 C{hip(
 label: Text(_currentFilters.isActive! ? 'Actif' : 'Inactif'),
 ),
 ],
 ),
 ),

 // Statistiques rapides
 Container(
 padding: const EdgeInsets.all(1),
 child: Row(
 children: [
 Expanded(
 child: _StatCard(
 title: 'Total',
 value: employeeState.totalEmployees.toString(),
 color: AppTheme.primaryColor,
 ),
 ),
 const SizedBox(width: 8),
 Expanded(
 child: _StatCard(
 title: 'Actifs',
 value: employeeState.activeEmployees.toString(),
 color: Colors.green,
 ),
 ),
 const SizedBox(width: 8),
 Expanded(
 child: _StatCard(
 title: 'Inactifs',
 value: employeeState.inactiveEmployees.toString(),
 color: Colors.orange,
 ),
 ),
 ],
 ),
 ),

 // Liste des employés
 Expanded(
 child: employeeState.isLoading && employeeState.employees.isEmpty
 ? const Center(child: CircularProgressIndicator())
 : employeeState.hasError
 ? _buildErrorWidget(employeeState.error!)
 : employees.isEmpty
 ? _buildEmptyWidget()
 : RefreshIndicator(
 onRefresh: () async {
 await ref.read(employeeProvider.notifier).refreshEmployees();
},
 child: ListView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.all(1),
 itemCount: employees.length +
 (employeeState.canLoadMore ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == employees.length) {{
 return const Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: CircularProgressIndicator(),
 ),
 );
 }

 final employee = employees[index];
 return EmployeeCard(
 employee: employee,
 onTap: () => _showEmployeeDetails(employee),
 onEdit: () {
 Navigator.push(
 context,
 MaterialPageRoute(
 builder: (context) => EmployeeFormScreen(
 employee: employee,
 ),
 ),
 );
 },
 onToggleStatus: () {
 _showToggleStatusDialog(employee);
 },
 );
 },
 ),
 ),
 ),
 ],
 ),
 floatingActionButton: FloatingActionButton(
 onPressed: _showAddEmployeeDialog,
 backgroundColor: AppTheme.primaryColor,
 child: const Icon(Icons.add, color: Colors.white),
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
 'Erreur de chargement',
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
 onPressed: () => ref.read(employeeProvider.notifier).refreshEmployees(),
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
 Icons.people_outline,
 size: 64,
 color: Colors.grey[400],
 ),
 const SizedBox(height: 16),
 Text(
 'Aucun employé trouvé',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 const SizedBox(height: 8),
 Text(
 'Commencez par ajouter un nouvel employé',
 textAlign: TextAlign.center,
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: Colors.grey[600],
 ),
 ),
 const SizedBox(height: 24),
 CustomButton(
 text: 'Ajouter un employé',
 onPressed: _showAddEmployeeDialog,
 ),
 ],
 ),
 ),
 );
 }

 void _exportEmployees() {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Exporter les employés'),
 content: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 ListTile(
 title: const Text('Excel'),
 subtitle: const Text('.xlsx'),
 leading: const Icon(Icons.table_chart),
 onTap: () {
 Navigator.pop(context);
 _performExport('excel');
 },
 ),
 ListTile(
 title: const Text('CSV'),
 subtitle: const Text('.csv'),
 leading: const Icon(Icons.description),
 onTap: () {
 Navigator.pop(context);
 _performExport('csv');
 },
 ),
 ],
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 ],
 ),
 );
 }

 void _performExport(String format) {
 ref.read(employeeProvider.notifier).exportEmployees(format: format).then((url) {
 if (url != null) {{
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text('Export $format réussi'),
 backgroundColor: Colors.green,
 ),
 );
 } else {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Erreur lors de l\'export'),
 backgroundColor: Colors.red,
 ),
 );
 }
});
 }

 void _showStatsDialog() {
 final stats = ref.read(employeeStatsProvider);
 
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Statistiques des employés'),
 content: SingleChildScrollView(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 mainAxisSize: MainAxisSize.min,
 children: [
 Text('Total: ${stats['total']}'),
 Text('Actifs: ${stats['active']}'),
 Text('Inactifs: ${stats['inactive']}'),
 const SizedBox(height: 16),
 const Text('Par département:', style: const TextStyle(fontWeight: FontWeight.bold)),
 ...stats['byDepartment'].entries.map((entry) {
 return Text('${entry.key}: ${entry.value}');
 }).toList(),
 ],
 ),
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Fermer'),
 ),
 ],
 ),
 );
 }

 void _showToggleStatusDialog(Employee employee) {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: Text(employee.isActive ? 'Désactiver l\'employé' : 'Activer l\'employé'),
 content: Text(
 'Êtes-vous sûr de vouloir ${employee.isActive ? 'désactiver' : 'activer'} ${employee.fullName} ?',
 ),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () async {
 Navigator.pop(context);
 final success = await ref.read(employeeProvider.notifier)
 .toggleEmployeeStatus(employee.id);
 
 if (success) {{
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(
 'Employé ${employee.isActive ? 'désactivé' : 'activé'} avec succès',
 ),
 backgroundColor: Colors.green,
 ),
 );
 } else {
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Erreur lors de la mise à jour du statut'),
 backgroundColor: Colors.red,
 ),
 );
 }
},
 child: const Text('Confirmer'),
 ),
 ],
 ),
 );
 }
}

class _StatCard extends StatefulWidget {
 final String title;
 final String value;
 final Color color;

 const _StatCard({
 required this.title,
 required this.value,
 required this.color,
 });

 @override
 Widget build(BuildContext context) {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: color.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(color: color.withOpacity(0.3)),
 ),
 child: Column(
 children: [
 Text(
 value,
 style: const TextStyle(
 fontSize: 20,
 fontWeight: FontWeight.bold,
 color: color,
 ),
 ),
 const SizedBox(height: 4),
 Text(
 title,
 style: const TextStyle(
 fontSize: 12,
 color: Colors.grey[600],
 ),
 ),
 ],
 ),
 );
 }
}

// Widgets supplémentaires (seront implémentés dans les prochaines tâches)
class EmployeeFilterDialog extends StatefulWidget {
 final EmployeeFilters currentFilters;
 final Function(EmployeeFilters) onFiltersChanged;

 const EmployeeFilterDialog({
 super.key,
 required this.currentFilters,
 required this.onFiltersChanged,
 });

 @override
 Widget build(BuildContext context) {
 return AlertDialog(
 title: const Text('Filtrer les employés'),
 content: const Text('Filtres à implémenter dans la tâche suivante'),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Appliquer'),
 ),
 ],
 );
 }
}

class EmployeeCard extends StatefulWidget {
 final Employee employee;
 final VoidCallback onTap;
 final VoidCallback onEdit;
 final VoidCallback onToggleStatus;

 const EmployeeCard({
 super.key,
 required this.employee,
 required this.onTap,
 required this.onEdit,
 required this.onToggleStatus,
 });

 @override
 Widget build(BuildContext context) {
 return Card(
 margin: const EdgeInsets.only(bottom: 8),
 child: ListTile(
 leading: CircleAvatar(
 backgroundColor: employee.isActive ? Colors.green : Colors.grey,
 child: Text(
 (employee.user?.firstName[0] ?? 'E') + (employee.user?.lastName[0] ?? '?'),
 style: const TextStyle(
 color: Colors.white,
 fontWeight: FontWeight.bold,
 ),
 ),
 ),
 title: Text(employee.fullName),
 subtitle: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(employee.position),
 Text(employee.formattedDepartment),
 if (employee.email.isNotEmpty) T{ext(employee.email),
 ],
 ),
 trailing: PopupMenuButton<String>(
 onSelected: (value) {
 switch (value) {
 case 'edit':
 onEdit();
 break;
 case 'toggle':
 onToggleStatus();
 break;
}
},
 itemBuilder: (context) => [
 const PopupMenuItem(
 value: 'edit',
 child: Row(
 children: [
 Icon(Icons.edit),
 const SizedBox(width: 8),
 Text('Modifier'),
 ],
 ),
 ),
 PopupMenuItem(
 value: 'toggle',
 child: Row(
 children: [
 Icon(
 employee.isActive ? Icons.block : Icons.check_circle,
 ),
 const SizedBox(width: 8),
 Text(employee.isActive ? 'Désactiver' : 'Activer'),
 ],
 ),
 ),
 ],
 ),
 onTap: onTap,
 ),
 );
 }
}

class EmployeeDetailsScreen extends StatefulWidget {
 final Employee employee;

 const EmployeeDetailsScreen({super.key, required this.employee});

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: Text(employee.fullName),
 backgroundColor: AppTheme.primaryColor,
 foregroundColor: Colors.white,
 ),
 body: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text('Détails de l\'employé à implémenter'),
 const SizedBox(height: 16),
 Text('ID: ${employee.id}'),
 Text('Poste: ${employee.position}'),
 Text('Département: ${employee.formattedDepartment}'),
 Text('Email: ${employee.email}'),
 Text('Téléphone: ${employee.phone ?? 'Non renseigné'}'),
 Text('Date d\'embauche: ${employee.hireDate.toString().split(' ')[0]}'),
 if (employee.salary != null)
 T{ext('Salaire: ${employee.salary!.toStringAsFixed(2)} €'),
 Text('Statut: ${employee.isActive ? 'Actif' : 'Inactif'}'),
 ],
 ),
 ),
 );
 }
}

class EmployeeFormScreen extends StatefulWidget {
 final Employee? employee;

 const EmployeeFormScreen({super.key, this.employee});

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: Text(employee == null ? 'Nouvel employé' : 'Modifier l\'employé'),
 backgroundColor: AppTheme.primaryColor,
 foregroundColor: Colors.white,
 ),
 body: const Padding(
 padding: const EdgeInsets.all(1),
 child: Center(
 child: Text('Formulaire employé à implémenter dans la tâche suivante'),
 ),
 ),
 );
 }
}
