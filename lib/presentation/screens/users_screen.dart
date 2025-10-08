import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../core/app_theme.dart';
import '../../core/models/user.dart' as UserModel;
import '../providers/user_provider.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/custom_button.dart';
import 'user_form_screen.dart';

class UsersScreen extends ConsumerStatefulWidget {
 const UsersScreen({super.key});

 @override
 ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
 final TextEditingController _searchController = TextEditingController();
 String _searchQuery = '';
 int _rowsPerPage = 10;
 int _sortColumnIndex = 0;
 bool _sortAscending = true;

 @override
 void initState() {
 super.initState();
 // Charger les utilisateurs au démarrage
 WidgetsBinding.instance.addPostFrameCallback((_) {
 ref.read(userProvider.notifier).loadUsers();
});
 }

 @override
 void dispose() {
 _searchController.dispose();
 super.dispose();
 }

 List<UserModel.User> get _filteredUsers {
 final users = ref.watch(userProvider).users;
 if (_searchQuery.isEmpty) r{eturn users;
 
 return users.where((user) {
 final query = _searchQuery.toLowerCase();
 return user.fullName.toLowerCase().contains(query) ||
 user.email.toLowerCase().contains(query) ||
 user.role.toLowerCase().contains(query);
}).toList();
 }

 List<UserModel.User> get _sortedUsers {
 final filtered = _filteredUsers;
 if (_sortColumnIndex == 0) {{
 // Sort by name
 filtered.sort((a, b) {
 final comparison = a.fullName.compareTo(b.fullName);
 return _sortAscending ? comparison : -comparison;
 });
} else if (_sortColumnIndex == 1) {{
 // Sort by email
 filtered.sort((a, b) {
 final comparison = a.email.compareTo(b.email);
 return _sortAscending ? comparison : -comparison;
 });
} else if (_sortColumnIndex == 2) {{
 // Sort by role
 filtered.sort((a, b) {
 final comparison = a.role.compareTo(b.role);
 return _sortAscending ? comparison : -comparison;
 });
} else if (_sortColumnIndex == 3) {{
 // Sort by status
 filtered.sort((a, b) {
 final comparison = a.isActive.toString().compareTo(b.isActive.toString());
 return _sortAscending ? comparison : -comparison;
 });
}
 return filtered;
 }

 void _onSort(int columnIndex, bool ascending) {
 setState(() {
 _sortColumnIndex = columnIndex;
 _sortAscending = ascending;
});
 }

 void _showUserDetails(UserModel.User user) {
 showDialog(
 context: context,
 builder: (context) => UserDetailDialog(user: user),
 );
 }

 void _editUser(UserModel.User user) {
 Navigator.push(
 context,
 MaterialPageRoute(
 builder: (context) => UserFormScreen(user: user),
 ),
 );
 }

 void _deleteUser(UserModel.User user) {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Supprimer l\'utilisateur'),
 content: Text('Êtes-vous sûr de vouloir supprimer l\'utilisateur ${user.fullName} ?'),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 ElevatedButton(
 onPressed: () async {
 Navigator.pop(context);
 final success = await ref.read(userProvider.notifier).deleteUser(user.id);
 if (success && mounted) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
 content: Text('Utilisateur supprimé avec succès'),
 backgroundColor: Colors.green,
 ),
 );
 }
},
 style: ElevatedButton.styleFrom(
 backgroundColor: Colors.red,
 foregroundColor: Colors.white,
 ),
 child: const Text('Supprimer'),
 ),
 ],
 ),
 );
 }

 @override
 Widget build(BuildContext context) {
 final userState = ref.watch(userProvider);
 final currentUser = ref.watch(currentUserProvider);

 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 backgroundColor: AppTheme.backgroundColor,
 appBar: AppBar(
 title: const Text('Gestion des utilisateurs'),
 backgroundColor: AppTheme.primaryColor,
 foregroundColor: AppTheme.textOnPrimary,
 elevation: 2,
 actions: [
 IconButton(
 icon: const Icon(Icons.refresh),
 onPressed: () => ref.read(userProvider.notifier).loadUsers(),
 tooltip: 'Actualiser',
 ),
 ],
 ),
 body: Column(
 children: [
 _buildSearchAndFilters(),
 _buildErrorBanner(userState.error),
 Expanded(
 child: LoadingOverlay(
 isLoading: userState.isLoading,
 child: _buildUsersTable(),
 ),
 ),
 ],
 ),
 floatingActionButton: FloatingActionButtonWidget(
 icon: Icons.add,
 onPressed: () {
 Navigator.push(
 context,
 MaterialPageRoute(
 builder: (context) => const UserFormScreen(),
 ),
 );
 },
 tooltip: 'Ajouter un utilisateur',
 ),
 );
 }

 Widget _buildSearchAndFilters() {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: AppTheme.surfaceColor,
 boxShadow: [
 BoxShadow(
 color: Colors.black.withOpacity(0.05),
 blurRadius: 4,
 offset: const Offset(0, 2),
 ),
 ],
 ),
 child: Row(
 children: [
 Expanded(
 child: TextField(
 controller: _searchController,
 decoration: InputDecoration(
 hintText: 'Rechercher par nom, email ou rôle...',
 prefixIcon: const Icon(Icons.search),
 suffixIcon: _searchQuery.isNotEmpty
 ? IconButton(
 icon: const Icon(Icons.clear),
 onPressed: () {
 _searchController.clear();
 setState(() {
 _searchQuery = '';
});
},
 )
 : null,
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
 ),
 enabledBorder: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
 ),
 focusedBorder: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: const BorderSide(color: AppTheme.primaryColor),
 ),
 ),
 onChanged: (value) {
 setState(() {
 _searchQuery = value;
 });
 },
 ),
 ),
 const SizedBox(width: 16),
 Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: AppTheme.primaryconst Color.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 '${_sortedUsers.length} utilisateur${_sortedUsers.length > 1 ? 's' : ''}',
 style: const TextStyle(
 color: AppTheme.primaryColor,
 fontWeight: FontWeight.w500,
 ),
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildErrorBanner(String? error) {
 if (error == null) r{eturn const SizedBox.shrink();
 
 return Container(
 width: double.infinity,
 padding: const EdgeInsets.all(1),
 margin: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.red.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(color: Colors.red.withOpacity(0.3)),
 ),
 child: Row(
 children: [
 Icon(Icons.error, color: Colors.red[700]),
 const SizedBox(width: 12),
 Expanded(
 child: Text(
 error,
 style: const TextStyle(color: Colors.red[700]),
 ),
 ),
 IconButton(
 icon: const Icon(Icons.close),
 onPressed: () => ref.read(userProvider.notifier).clearError(),
 color: Colors.red[700],
 ),
 ],
 ),
 );
 }

 Widget _buildUsersTable() {
 if (_sortedUsers.isEmpty) {{
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.people_outline,
 size: 64,
 color: AppTheme.textSecondary.withOpacity(0.5),
 ),
 const SizedBox(height: 16),
 Text(
 _searchQuery.isNotEmpty
 ? 'Aucun utilisateur trouvé pour "${_searchQuery}"'
 : 'Aucun utilisateur trouvé',
 style: const TextStyle(
 fontSize: 18,
 color: AppTheme.textSecondary.withOpacity(0.7),
 ),
 ),
 if (_searchQuery.isEmpty) .{..[
 const SizedBox(height: 16),
 CustomButton(
 text: 'Ajouter le premier utilisateur',
 onPressed: () {
 Navigator.push(
 context,
 MaterialPageRoute(
 builder: (context) => const UserFormScreen(),
 ),
 );
 },
 ),
 ],
 ],
 ),
 );
}

 return Padding(
 padding: const EdgeInsets.all(1),
 child: DataTable2(
 columnSpacing: 12,
 horizontalMargin: 12,
 minWidth: 800,
 sortColumnIndex: _sortColumnIndex,
 sortAscending: _sortAscending,
 onSelectAll: (value) {},
 columns: [
 DataColumn2(
 label: const Text('Nom complet'),
 size: ColumnSize.L,
 onSort: _onSort,
 ),
 DataColumn2(
 label: const Text('Email'),
 size: ColumnSize.L,
 onSort: _onSort,
 ),
 DataColumn2(
 label: const Text('Rôle'),
 size: ColumnSize.M,
 onSort: _onSort,
 ),
 DataColumn2(
 label: const Text('Statut'),
 size: ColumnSize.S,
 onSort: _onSort,
 ),
 DataColumn2(
 label: const Text('Dernière connexion'),
 size: ColumnSize.M,
 ),
 const DataColumn2(
 label: Text('Actions'),
 size: ColumnSize.S,
 fixedWidth: 120,
 ),
 ],
 rows: List.generate(
 _sortedUsers.length,
 (index) => _buildUserRow(_sortedUsers[index]),
 ),
 ),
 );
 }

 DataRow _buildUserRow(UserModel.User user) {
 return DataRow2(
 onSelectChanged: (value) => _showUserDetails(user),
 cells: [
 DataCell(
 Row(
 children: [
 CircleAvatar(
 radius: 16,
 backgroundColor: AppTheme.primaryconst Color.withOpacity(0.1),
 child: Text(
 user.initials,
 style: const TextStyle(
 color: AppTheme.primaryColor,
 fontWeight: FontWeight.bold,
 fontSize: 12,
 ),
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 user.fullName,
 style: const TextStyle(
 fontWeight: FontWeight.w500,
 fontSize: 14,
 ),
 ),
 Text(
 'ID: ${user.id}',
 style: const TextStyle(
 fontSize: 12,
 color: AppTheme.textSecondary.withOpacity(0.7),
 ),
 ),
 ],
 ),
 ),
 ],
 ),
 ),
 DataCell(
 Text(
 user.email,
 style: const TextStyle(fontSize: 14),
 ),
 ),
 DataCell(
 Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: _getRoleColor(user.role).withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 _getRoleDisplayName(user.role),
 style: const TextStyle(
 color: _getRoleColor(user.role),
 fontSize: 12,
 fontWeight: FontWeight.w500,
 ),
 ),
 ),
 ),
 DataCell(
 Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: user.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 Icon(
 user.isActive ? Icons.check_circle : Icons.cancel,
 size: 12,
 color: user.isActive ? Colors.green : Colors.red,
 ),
 const SizedBox(width: 4),
 Text(
 user.isActive ? 'Actif' : 'Inactif',
 style: const TextStyle(
 color: user.isActive ? Colors.green : Colors.red,
 fontSize: 12,
 fontWeight: FontWeight.w500,
 ),
 ),
 ],
 ),
 ),
 ),
 DataCell(
 Text(
 user.lastLogin != null
 ? _formatDate(user.lastLogin!)
 : 'Jamais',
 style: const TextStyle(
 fontSize: 12,
 color: AppTheme.textSecondary.withOpacity(0.7),
 ),
 ),
 ),
 DataCell(
 Row(
 children: [
 IconButton(
 icon: const Icon(Icons.visibility, size: 18),
 onPressed: () => _showUserDetails(user),
 tooltip: 'Voir les détails',
 color: AppTheme.primaryColor,
 ),
 IconButton(
 icon: const Icon(Icons.edit, size: 18),
 onPressed: () => _editUser(user),
 tooltip: 'Modifier',
 color: Colors.blue,
 ),
 IconButton(
 icon: const Icon(Icons.delete, size: 18),
 onPressed: () => _deleteUser(user),
 tooltip: 'Supprimer',
 color: Colors.red,
 ),
 ],
 ),
 ),
 ],
 );
 }

 Color _getRoleColor(String role) {
 switch (role) {
 case 'admin':
 return Colors.purple;
 case 'manager':
 return Colors.blue;
 case 'operator':
 return Colors.green;
 case 'rh':
 return Colors.orange;
 case 'comptable':
 return Colors.teal;
 case 'logistique':
 return Colors.indigo;
 default:
 return Colors.grey;
}
 }

 String _getRoleDisplayName(String role) {
 switch (role) {
 case 'admin':
 return 'Administrateur';
 case 'manager':
 return 'Manager';
 case 'operator':
 return 'Opérateur';
 case 'rh':
 return 'RH';
 case 'comptable':
 return 'Comptable';
 case 'logistique':
 return 'Logistique';
 default:
 return role.toUpperCase();
}
 }

 String _formatDate(DateTime date) {
 return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
 }
}

class UserDetailDialog extends StatefulWidget {
 final UserModel.User user;

 const UserDetailDialog({super.key, required this.user});

 @override
 Widget build(BuildContext context) {
 return Dialog(
 child: Container(
 constraints: const BoxConstraints(maxWidth: 500),
 padding: const EdgeInsets.all(1),
 child: Column(
 mainAxisSize: MainAxisSize.min,
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Row(
 children: [
 CircleAvatar(
 radius: 30,
 backgroundColor: AppTheme.primaryconst Color.withOpacity(0.1),
 child: Text(
 user.initials,
 style: const TextStyle(
 color: AppTheme.primaryColor,
 fontWeight: FontWeight.bold,
 fontSize: 20,
 ),
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 user.fullName,
 style: const TextStyle(
 fontSize: 20,
 fontWeight: FontWeight.bold,
 ),
 ),
 Text(
 user.email,
 style: const TextStyle(
 color: AppTheme.textSecondary.withOpacity(0.7),
 ),
 ),
 ],
 ),
 ),
 ],
 ),
 const SizedBox(height: 24),
 _buildDetailRow('ID Utilisateur', user.id),
 _buildDetailRow('Rôle', _getRoleDisplayName(user.role)),
 _buildDetailRow('Statut', user.isActive ? 'Actif' : 'Inactif'),
 if (user.lastLogin != null)
 _{buildDetailRow('Dernière connexion', _formatDateTime(user.lastLogin!)),
 _buildDetailRow('Date de création', _formatDateTime(user.createdAt)),
 _buildDetailRow('Dernière mise à jour', _formatDateTime(user.updatedAt)),
 const SizedBox(height: 24),
 Row(
 mainAxisAlignment: MainAxisAlignment.end,
 children: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Fermer'),
 ),
 ],
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildDetailRow(String label, String value) {
 return Padding(
 padding: const EdgeInsets.symmetric(1),
 child: Row(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const SizedBox(
 width: 120,
 child: Text(
 '$label:',
 style: const TextStyle(
 fontWeight: FontWeight.w500,
 color: AppTheme.textSecondary.withOpacity(0.7),
 ),
 ),
 ),
 Expanded(
 child: Text(value),
 ),
 ],
 ),
 );
 }

 String _getRoleDisplayName(String role) {
 switch (role) {
 case 'admin':
 return 'Administrateur';
 case 'manager':
 return 'Manager';
 case 'operator':
 return 'Opérateur';
 case 'rh':
 return 'RH';
 case 'comptable':
 return 'Comptable';
 case 'logistique':
 return 'Logistique';
 default:
 return role.toUpperCase();
}
 }

 String _formatDateTime(DateTime dateTime) {
 return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
 }
}
