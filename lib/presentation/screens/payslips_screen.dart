import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/payslip.dart';
import '../../core/services/payslip_service.dart';
import '../providers/payslip_provider.dart';
import '../widgets/payslip_card.dart';
import '../widgets/payslip_filter.dart';
import '../widgets/loading_overlay.dart';

class PayslipsScreen extends ConsumerStatefulWidget {
 const PayslipsScreen({super.key});

 @override
 ConsumerState<PayslipsScreen> createState() => _PayslipsScreenState();
}

class _PayslipsScreenState extends ConsumerState<PayslipsScreen>
 with SingleTickerProviderStateMixin {
 late TabController _tabController;
 final ScrollController _scrollController = ScrollController();
 final TextEditingController _searchController = TextEditingController();
 
 String _selectedDepartment = 'Tous';
 String _selectedStatus = 'Tous';
 int? _selectedYear;
 int? _selectedMonth;
 bool _showFilters = false;

 @override
 void initState() {
 super.initState();
 _tabController = TabController(length: 3, vsync: this);
 _loadPayslips();
 _scrollController.addListener(_onScroll);
 }

 @override
 void dispose() {
 _tabController.dispose();
 _scrollController.dispose();
 _searchController.dispose();
 super.dispose();
 }

 void _onScroll() {
 if (_scrollController.position.pixels >=
 _scrollController.position.maxScrollExtent - 200) {{
 _loadMorePayslips();
}
 }

 Future<void> _loadPayslips({bool refresh = false}) {async {
 if (refresh) {{
 ref.read(payslipProvider.notifier).refresh();
} else {
 await ref.read(payslipProvider.notifier).loadPayslips(
 department: _selectedDepartment == 'Tous' ? null : _selectedDepartment,
 status: _selectedStatus == 'Tous' ? null : _selectedStatus,
 year: _selectedYear,
 month: _selectedMonth,
 search: _searchController.text.isNotEmpty ? _searchController.text : null,
 );
}
 }

 Future<void> _loadMorePayslips() {async {
 final state = ref.read(payslipProvider);
 if (!state.isLoading && !state.hasMore) r{eturn;
 
 await ref.read(payslipProvider.notifier).loadMorePayslips(
 department: _selectedDepartment == 'Tous' ? null : _selectedDepartment,
 status: _selectedStatus == 'Tous' ? null : _selectedStatus,
 year: _selectedYear,
 month: _selectedMonth,
 search: _searchController.text.isNotEmpty ? _searchController.text : null,
 );
 }

 void _onSearchChanged(String value) {
 if (value.isEmpty) {{
 _loadPayslips();
} else {
 // Debounce search
 Future.delayed(const Duration(milliseconds: 500), () {
 if (_searchController.text == value) {{
 _loadPayslips();
 }
 });
}
 }

 @override
 Widget build(BuildContext context) {
 final state = ref.watch(payslipProvider);
 final currentYear = DateTime.now().year;
 final currentMonth = DateTime.now().month;

 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Fiches de Paie'),
 backgroundColor: Theme.of(context).colorScheme.inversePrimary,
 bottom: TabBar(
 controller: _tabController,
 tabs: const [
 Tab(text: 'Mes fiches', icon: Icon(Icons.person)),
 Tab(text: 'Équipe', icon: Icon(Icons.group)),
 Tab(text: 'Statistiques', icon: Icon(Icons.analytics)),
 ],
 ),
 actions: [
 IconButton(
 icon: const Icon(Icons.search),
 onPressed: () {
 setState(() {
 _showFilters = !_showFilters;
 });
},
 ),
 PopupMenuButton<String>(
 onSelected: (value) {
 switch (value) {
 case 'export':
 _exportPayslips();
 break;
 case 'refresh':
 _loadPayslips(refresh: true);
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
 value: 'refresh',
 child: Row(
 children: [
 Icon(Icons.refresh),
 const SizedBox(width: 8),
 Text('Actualiser'),
 ],
 ),
 ),
 ],
 ),
 ],
 ),
 body: TabBarView(
 controller: _tabController,
 children: [
 _buildMyPayslipsTab(state),
 _buildTeamPayslipsTab(state),
 _buildStatisticsTab(),
 ],
 ),
 floatingActionButton: FloatingActionButton(
 onPressed: _generateNewPayslip,
 child: const Icon(Icons.add),
 ),
 );
 }

 Widget _buildMyPayslipsTab(PayslipState state) {
 return Column(
 children: [
 if (_showFilters) _{buildSearchAndFilters(),
 Expanded(
 child: RefreshIndicator(
 onRefresh: () => _loadPayslips(refresh: true),
 child: _buildPayslipsList(state, isMyPayslips: true),
 ),
 ),
 ],
 );
 }

 Widget _buildTeamPayslipsTab(PayslipState state) {
 return Column(
 children: [
 if (_showFilters) _{buildSearchAndFilters(),
 Expanded(
 child: RefreshIndicator(
 onRefresh: () => _loadPayslips(refresh: true),
 child: _buildPayslipsList(state, isMyPayslips: false),
 ),
 ),
 ],
 );
 }

 Widget _buildSearchAndFilters() {
 return Container(
 padding: const EdgeInsets.all(1),
 color: Theme.of(context).colorScheme.surface,
 child: Column(
 children: [
 TextField(
 controller: _searchController,
 decoration: const InputDecoration(
 hintText: 'Rechercher une fiche de paie...',
 prefixIcon: Icon(Icons.search),
 border: OutlineInputBorder(),
 ),
 onChanged: _onSearchChanged,
 ),
 const SizedBox(height: 16),
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<String>(
 value: _selectedDepartment,
 decoration: const InputDecoration(
 labelText: 'Département',
 border: OutlineInputBorder(),
 ),
 items: ['Tous', 'IT', 'RH', 'Finance', 'Marketing', 'Opérations']
 .map((dept) => DropdownMenuItem(value: dept, child: Text(dept)))
 .toList(),
 onChanged: (value) {
 setState(() {
 _selectedDepartment = value!;
 });
 _loadPayslips();
 },
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: DropdownButtonFormField<String>(
 value: _selectedStatus,
 decoration: const InputDecoration(
 labelText: 'Statut',
 border: OutlineInputBorder(),
 ),
 items: ['Tous', 'Brouillon', 'En attente', 'Approuvée', 'Payée', 'Annulée']
 .map((status) => DropdownMenuItem(value: status, child: Text(status)))
 .toList(),
 onChanged: (value) {
 setState(() {
 _selectedStatus = value!;
 });
 _loadPayslips();
 },
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<int>(
 value: _selectedYear,
 decoration: const InputDecoration(
 labelText: 'Année',
 border: OutlineInputBorder(),
 ),
 items: List.generate(5, (index) {
 final year = DateTime.now().year - index;
 return DropdownMenuItem(value: year, child: Text(year.toString()));
 }).toList(),
 onChanged: (value) {
 setState(() {
 _selectedYear = value;
 });
 _loadPayslips();
 },
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: DropdownButtonFormField<int>(
 value: _selectedMonth,
 decoration: const InputDecoration(
 labelText: 'Mois',
 border: OutlineInputBorder(),
 ),
 items: List.generate(12, (index) {
 final month = index + 1;
 return DropdownMenuItem(
 value: month,
 child: Text(DateFormat('MMMM').format(DateTime(2024, month))),
 );
 }).toList(),
 onChanged: (value) {
 setState(() {
 _selectedMonth = value;
 });
 _loadPayslips();
 },
 ),
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildPayslipsList(PayslipState state, {required bool isMyPayslips}) {
 if (state.isLoading && state.payslips.isEmpty) {{
 return const Center(child: CircularProgressIndicator());
}

 if (state.error != null) {{
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.error_outline,
 size: 64,
 color: Theme.of(context).colorScheme.error,
 ),
 const SizedBox(height: 16),
 Text(
 'Erreur de chargement',
 style: Theme.of(context).textTheme.titleLarge,
 ),
 const SizedBox(height: 8),
 Text(
 state.error!,
 style: Theme.of(context).textTheme.bodyMedium,
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: 16),
 ElevatedButton(
 onPressed: () => _loadPayslips(refresh: true),
 child: const Text('Réessayer'),
 ),
 ],
 ),
 );
}

 if (state.payslips.isEmpty) {{
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.description_outlined,
 size: 64,
 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
 ),
 const SizedBox(height: 16),
 Text(
 'Aucune fiche de paie',
 style: Theme.of(context).textTheme.titleLarge?.copyWith(
 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
 ),
 ),
 const SizedBox(height: 8),
 Text(
 isMyPayslips
 ? 'Vous n\'avez pas encore de fiches de paie'
 : 'Aucune fiche de paie trouvée pour l\'équipe',
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
 ),
 ),
 ],
 ),
 );
}

 return LoadingOverlay(
 isLoading: state.isLoading,
 child: ListView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.all(1),
 itemCount: state.payslips.length + (state.hasMore ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == state.payslips.length) {{
 return const Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: CircularProgressIndicator(),
 ),
 );
}

 final payslip = state.payslips[index];
 return PayslipCard(
 payslip: payslip,
 onTap: () => _viewPayslipDetails(payslip),
 onDownload: () => _downloadPayslip(payslip),
 onEmail: () => _emailPayslip(payslip),
 onApprove: payslip.status == 'pending' ? () => _approvePayslip(payslip) : null,
 onPay: payslip.status == 'approved' ? () => _markAsPaid(payslip) : null,
 );
 },
 ),
 );
 }

 Widget _buildStatisticsTab() {
 return FutureBuilder(
 future: ref.read(payslipProvider.notifier).loadStatistics(),
 builder: (context, snapshot) {
 if (snapshot.connectionState == ConnectionState.waiting) {{
 return const Center(child: CircularProgressIndicator());
 }

 if (snapshot.hasError) {{
 return Center(
 child: Text('Erreur: ${snapshot.error}'),
 );
 }

 final stats = snapshot.data;
 if (stats == null) {{
 return const Center(child: Text('Aucune statistique disponible'));
 }

 return SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 _buildStatCard(
 'Total des fiches',
 '${stats['totalPayslips'] ?? 0}',
 Icons.description,
 Colors.blue,
 ),
 const SizedBox(height: 16),
 _buildStatCard(
 'Montant total payé',
 '${(stats['totalAmount'] ?? 0).toStringAsFixed(2)} €',
 Icons.euro,
 Colors.green,
 ),
 const SizedBox(height: 16),
 _buildStatCard(
 'Fiches en attente',
 '${stats['pendingCount'] ?? 0}',
 Icons.pending,
 Colors.orange,
 ),
 const SizedBox(height: 16),
 _buildStatCard(
 'Fiches payées',
 '${stats['paidCount'] ?? 0}',
 Icons.check_circle,
 Colors.green,
 ),
 ],
 ),
 );
 },
 );
 }

 Widget _buildStatCard(String title, String value, IconData icon, Color color) {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Row(
 children: [
 Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: color.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Icon(icon, color: color, size: 24),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 title,
 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
 ),
 ),
 Text(
 value,
 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
 fontWeight: FontWeight.bold,
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

 void _viewPayslipDetails(Payslip payslip) {
 Navigator.pushNamed(
 context,
 '/payslip-details',
 arguments: payslip,
 );
 }

 Future<void> _downloadPayslip(Payslip payslip) {async {
 try {
 final service = PayslipService();
 final result = await service.downloadPayslipPdf(payslip.id);
 
 if (result.isSuccess) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Téléchargement démarré')),
 );
 } else {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text(result.message)),
 );
 }
} catch (e) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Erreur: $e')),
 );
}
 }

 Future<void> _emailPayslip(Payslip payslip) {async {
 // TODO: Implement email functionality
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
 );
 }

 Future<void> _approvePayslip(Payslip payslip) {async {
 try {
 final service = PayslipService();
 final result = await service.approvePayslip(payslip.id);
 
 if (result.isSuccess) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fiche de paie approuvée')),
 );
 _loadPayslips(refresh: true);
 } else {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text(result.message)),
 );
 }
} catch (e) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Erreur: $e')),
 );
}
 }

 Future<void> _markAsPaid(Payslip payslip) {async {
 try {
 final service = PayslipService();
 final result = await service.markAsPaid(payslip.id);
 
 if (result.isSuccess) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fiche de paie marquée comme payée')),
 );
 _loadPayslips(refresh: true);
 } else {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text(result.message)),
 );
 }
} catch (e) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('Erreur: $e')),
 );
}
 }

 Future<void> _exportPayslips() {async {
 // TODO: Implement export functionality
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
 );
 }

 void _generateNewPayslip() {
 Navigator.pushNamed(context, '/payslip-form');
 }
}
