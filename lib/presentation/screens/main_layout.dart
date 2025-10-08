import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../../core/app_theme.dart';
import '../../core/utils/constants.dart';
import '../widgets/custom_button.dart';
import 'users_screen.dart';
import 'dashboard_screen.dart';
import 'employees_screen.dart';
import 'orders_screen.dart';
import 'products_screen.dart';
import 'notifications_screen.dart';
import 'user_form_screen.dart';
import 'order_form_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
 const MainLayout({super.key});

 @override
 ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
 int _currentIndex = 0;
 late PageController _pageController;

 @override
 void initState() {
 super.initState();
 _pageController = PageController();
 }

 @override
 void dispose() {
 _pageController.dispose();
 super.dispose();
 }

 void _onTabTapped(int index) {
 setState(() {
 _currentIndex = index;
});
 _pageController.animateToPage(
 index,
 duration: const Duration(milliseconds: 300),
 curve: Curves.easeInOut,
 );
 }

 void _onPageChanged(int index) {
 setState(() {
 _currentIndex = index;
});
 }

 @override
 Widget build(BuildContext context) {
 final user = ref.watch(currentUserProvider);
 final isDarkMode = ref.watch(isEffectiveDarkModeProvider);

 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 backgroundColor: AppTheme.backgroundColor,
 appBar: _buildAppBar(user),
 body: PageView(
 controller: _pageController,
 onPageChanged: _onPageChanged,
 children: _buildPages(),
 ),
 bottomNavigationBar: _buildBottomNavigationBar(),
 floatingActionButton: _buildFloatingActionButton(),
 drawer: _buildDrawer(user, isDarkMode),
 );
 }

 PreferredSizeWidget _buildAppBar(user) {
 return AppBar(
 title: Text(
 _getAppBarTitle(),
 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
 color: AppTheme.textOnPrimary,
 fontWeight: FontWeight.bold,
 ),
 ),
 backgroundColor: AppTheme.primaryColor,
 foregroundColor: AppTheme.textOnPrimary,
 elevation: 2,
 centerTitle: true,
 actions: [
 IconButton(
 icon: const Icon(Icons.notifications_outlined),
 onPressed: () {
 Navigator.push(
 context,
 MaterialPageRoute(builder: (context) => const NotificationsScreen()),
 );
},
 tooltip: 'Notifications',
 ),
 PopupMenuButton<String>(
 icon: CircleAvatar(
 radius: 16,
 backgroundColor: AppTheme.textOnPrimary.withOpacity(0.2),
 child: Text(
 user?.initials ?? 'U',
 style: const TextStyle(
 color: AppTheme.textOnPrimary,
 fontWeight: FontWeight.bold,
 fontSize: 12,
 ),
 ),
 ),
 onSelected: _handleMenuAction,
 itemBuilder: (context) => [
 const PopupMenuItem(
 value: 'profile',
 child: Row(
 children: [
 Icon(Icons.person_outline),
 const SizedBox(width: 8),
 Text('Profil'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'settings',
 child: Row(
 children: [
 Icon(Icons.settings_outlined),
 const SizedBox(width: 8),
 Text('Paramètres'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'help',
 child: Row(
 children: [
 Icon(Icons.help_outline),
 const SizedBox(width: 8),
 Text('Aide'),
 ],
 ),
 ),
 const PopupMenuDivider(),
 const PopupMenuItem(
 value: 'logout',
 child: Row(
 children: [
 Icon(Icons.logout, color: Colors.red),
 const SizedBox(width: 8),
 Text('Déconnexion', style: const TextStyle(color: Colors.red)),
 ],
 ),
 ),
 ],
 ),
 ],
 );
 }

 String _getAppBarTitle() {
 switch (_currentIndex) {
 case 0:
 return 'Tableau de bord';
 case 1:
 return 'Employés';
 case 2:
 return 'Commandes';
 case 3:
 return 'Livraisons';
 case 4:
 return 'Rapports';
 default:
 return 'Aramco SA';
}
 }

 List<Widget> _buildPages() {
 return [
 const DashboardScreen(),
 const EmployeesScreen(),
 const OrdersScreen(),
 const ProductsScreen(),
 const NotificationsScreen(),
 ];
 }

 Widget _buildBottomNavigationBar() {
 return BottomNavigationBar(
 currentIndex: _currentIndex,
 onTap: _onTabTapped,
 type: BottomNavigationBarType.fixed,
 backgroundColor: AppTheme.surfaceColor,
 selectedItemColor: AppTheme.primaryColor,
 unselectedItemColor: AppTheme.textSecondary,
 selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
 unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
 elevation: 8,
 items: const [
 BottomNavigationBarItem(
 icon: Icon(Icons.dashboard_outlined),
 activeIcon: Icon(Icons.dashboard),
 label: 'Accueil',
 ),
 BottomNavigationBarItem(
 icon: Icon(Icons.people_outline),
 activeIcon: Icon(Icons.people),
 label: 'Employés',
 ),
 BottomNavigationBarItem(
 icon: Icon(Icons.shopping_cart_outlined),
 activeIcon: Icon(Icons.shopping_cart),
 label: 'Commandes',
 ),
 BottomNavigationBarItem(
 icon: Icon(Icons.local_shipping_outlined),
 activeIcon: Icon(Icons.local_shipping),
 label: 'Livraisons',
 ),
 BottomNavigationBarItem(
 icon: Icon(Icons.bar_chart_outlined),
 activeIcon: Icon(Icons.bar_chart),
 label: 'Rapports',
 ),
 ],
 );
 }

 Widget? _buildFloatingActionButton() {
 if (_currentIndex == 1) {{
 // Page employés
 return FloatingActionButtonWidget(
 icon: Icons.person_add,
 onPressed: () {
 Navigator.push(
 context,
 MaterialPageRoute(builder: (context) => const UserFormScreen()),
 );
 },
 tooltip: 'Ajouter un employé',
 );
} else if (_currentIndex == 2) {{
 // Page commandes
 return FloatingActionButtonWidget(
 icon: Icons.add_shopping_cart,
 onPressed: () {
 Navigator.push(
 context,
 MaterialPageRoute(builder: (context) => const OrderFormScreen()),
 );
 },
 tooltip: 'Nouvelle commande',
 );
}
 return null;
 }

 Widget _buildDrawer(user, bool isDarkMode) {
 return Drawer(
 backgroundColor: AppTheme.surfaceColor,
 child: ListView(
 padding: const EdgeInsets.zero,
 children: [
 _buildDrawerHeader(user),
 _buildDrawerItems(),
 const Divider(),
 _buildSettingsItems(isDarkMode),
 const Divider(),
 _buildLogoutItem(),
 ],
 ),
 );
 }

 Widget _buildDrawerHeader(user) {
 return DrawerHeader(
 decoration: BoxDecoration(
 gradient: AppTheme.primaryGradient,
 ),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 CircleAvatar(
 radius: 30,
 backgroundColor: AppTheme.textOnPrimary.withOpacity(0.2),
 child: Text(
 user?.initials ?? 'U',
 style: const TextStyle(
 color: AppTheme.textOnPrimary,
 fontWeight: FontWeight.bold,
 fontSize: 24,
 ),
 ),
 ),
 const SizedBox(height: 12),
 Text(
 user?.fullName ?? 'Utilisateur',
 style: const TextStyle(
 color: AppTheme.textOnPrimary,
 fontSize: 18,
 fontWeight: FontWeight.bold,
 ),
 ),
 const SizedBox(height: 4),
 Text(
 user?.email ?? 'user@aramco-sa.com',
 style: const TextStyle(
 color: AppTheme.textOnPrimary.withOpacity(0.8),
 fontSize: 14,
 ),
 ),
 const SizedBox(height: 8),
 Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: AppTheme.textOnPrimary.withOpacity(0.2),
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 user?.role.toUpperCase() ?? 'USER',
 style: const TextStyle(
 color: AppTheme.textOnPrimary,
 fontSize: 12,
 fontWeight: FontWeight.w500,
 ),
 ),
 ),
 ],
 ),
 );
 }

 Widget _buildDrawerItems() {
 return Column(
 children: [
 ListTile(
 leading: const Icon(Icons.dashboard),
 title: const Text('Tableau de bord'),
 selected: _currentIndex == 0,
 onTap: () {
 Navigator.pop(context);
 _onTabTapped(0);
},
 ),
 ListTile(
 leading: const Icon(Icons.people),
 title: const Text('Employés'),
 selected: _currentIndex == 1,
 onTap: () {
 Navigator.pop(context);
 _onTabTapped(1);
},
 ),
 ListTile(
 leading: const Icon(Icons.shopping_cart),
 title: const Text('Commandes'),
 selected: _currentIndex == 2,
 onTap: () {
 Navigator.pop(context);
 _onTabTapped(2);
},
 ),
 ListTile(
 leading: const Icon(Icons.local_shipping),
 title: const Text('Livraisons'),
 selected: _currentIndex == 3,
 onTap: () {
 Navigator.pop(context);
 _onTabTapped(3);
},
 ),
 ListTile(
 leading: const Icon(Icons.bar_chart),
 title: const Text('Rapports'),
 selected: _currentIndex == 4,
 onTap: () {
 Navigator.pop(context);
 _onTabTapped(4);
},
 ),
 ],
 );
 }

 Widget _buildSettingsItems(bool isDarkMode) {
 return Column(
 children: [
 ListTile(
 leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
 title: Text(isDarkMode ? 'Thème clair' : 'Thème sombre'),
 onTap: () {
 Navigator.pop(context);
 ref.read(themeProvider.notifier).toggleTheme();
},
 ),
 ListTile(
 leading: const Icon(Icons.language),
 title: const Text('Langue'),
 onTap: () {
 Navigator.pop(context);
 _showLanguageDialog();
},
 ),
 ListTile(
 leading: const Icon(Icons.settings),
 title: const Text('Paramètres'),
 onTap: () {
 Navigator.pop(context);
 // TODO: Naviguer vers les paramètres
;,
 ),
 ],
 );
 }

 Widget _buildLogoutItem() {
 return ListTile(
 leading: const Icon(Icons.logout, color: Colors.red),
 title: const Text('Déconnexion', style: const TextStyle(color: Colors.red)),
 onTap: () {
 Navigator.pop(context);
 _showLogoutDialog();
 },
 );
 }

 void _handleMenuAction(String action) {
 switch (action) {
 case 'profile':
 _showProfileDialog();
 break;
 case 'settings':
 _showSettingsDialog();
 break;
 case 'help':
 _showHelpDialog();
 break;
 case 'logout':
 _showLogoutDialog();
 break;
}
 }

 void _showLanguageDialog() {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Choisir la langue'),
 content: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 ListTile(
 title: const Text('Français'),
 trailing: const Text('🇫🇷'),
 onTap: () {
 Navigator.pop(context);
 ref.read(languageProvider.notifier).setFrench();
 },
 ),
 ListTile(
 title: const Text('English'),
 trailing: const Text('🇬🇧'),
 onTap: () {
 Navigator.pop(context);
 ref.read(languageProvider.notifier).setEnglish();
 },
 ),
 ListTile(
 title: const Text('العربية'),
 trailing: const Text('🇸🇦'),
 onTap: () {
 Navigator.pop(context);
 ref.read(languageProvider.notifier).setArabic();
 },
 ),
 ],
 ),
 ),
 );
 }

 void _showProfileDialog() {
 final user = ref.watch(currentUserProvider);
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Profil utilisateur'),
 content: Column(
 mainAxisSize: MainAxisSize.min,
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text('Nom: ${user?.fullName ?? 'N/A'}'),
 const SizedBox(height: 8),
 Text('Email: ${user?.email ?? 'N/A'}'),
 const SizedBox(height: 8),
 Text('Rôle: ${user?.role ?? 'N/A'}'),
 const SizedBox(height: 8),
 Text('ID: ${user?.id ?? 'N/A'}'),
 ],
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

 void _showSettingsDialog() {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Paramètres'),
 content: const Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 ListTile(
 leading: Icon(Icons.notifications),
 title: Text('Notifications'),
 subtitle: Text('Gérer les préférences de notification'),
 ),
 ListTile(
 leading: Icon(Icons.security),
 title: Text('Sécurité'),
 subtitle: Text('Mot de passe et authentification'),
 ),
 ListTile(
 leading: Icon(Icons.privacy_tip),
 title: Text('Confidentialité'),
 subtitle: Text('Paramètres de confidentialité'),
 ),
 ],
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

 void _showHelpDialog() {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Aide et support'),
 content: const Column(
 mainAxisSize: MainAxisSize.min,
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text('Besoin d\'aide ?'),
 const SizedBox(height: 16),
 Text('• Documentation: app.aramco-sa.com/docs'),
 const SizedBox(height: 8),
 Text('• Support: support@aramco-sa.com'),
 const SizedBox(height: 8),
 Text('• Tel: +966 13 877 0000'),
 const SizedBox(height: 16),
 Text('Version: 1.0.0'),
 ],
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

 void _showLogoutDialog() {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Déconnexion'),
 content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
 actions: [
 TextButton(
 onPressed: () => Navigator.pop(context),
 child: const Text('Annuler'),
 ),
 ElevatedButton(
 onPressed: () {
 Navigator.pop(context);
 ref.read(authProvider.notifier).logout();
},
 style: ElevatedButton.styleFrom(
 backgroundColor: Colors.red,
 foregroundColor: Colors.white,
 ),
 child: const Text('Déconnexion'),
 ),
 ],
 ),
 );
 }
}

// Pages placeholder
class DashboardPage extends StatefulWidget {
 const DashboardPage({super.key});

 @override
 Widget build(BuildContext context) {
 return const Center(
 child: Text(
 'Tableau de bord',
 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
 ),
 );
 }
}

class EmployeesPage extends StatefulWidget {
 const EmployeesPage({super.key});

 @override
 Widget build(BuildContext context) {
 return const Center(
 child: Text(
 'Gestion des employés',
 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
 ),
 );
 }
}

class OrdersPage extends StatefulWidget {
 const OrdersPage({super.key});

 @override
 Widget build(BuildContext context) {
 return const Center(
 child: Text(
 'Gestion des commandes',
 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
 ),
 );
 }
}

class DeliveriesPage extends StatefulWidget {
 const DeliveriesPage({super.key});

 @override
 Widget build(BuildContext context) {
 return const Center(
 child: Text(
 'Suivi des livraisons',
 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
 ),
 );
 }
}

class ReportsPage extends StatefulWidget {
 const ReportsPage({super.key});

 @override
 Widget build(BuildContext context) {
 return const Center(
 child: Text(
 'Rapports et analyses',
 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
 ),
 );
 }
}
