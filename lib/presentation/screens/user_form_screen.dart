import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../core/models/user.dart' as UserModel;
import '../../core/utils/validators.dart';
import '../providers/user_provider.dart';
// Import des rôles depuis le user_provider
import '../widgets/loading_overlay.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class UserFormScreen extends ConsumerStatefulWidget {
 final UserModel.User? user;

 const UserFormScreen({super.key, this.user});

 @override
 ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
 final _formKey = GlobalKey<FormState>();
 final _firstNameController = TextEditingController();
 final _lastNameController = TextEditingController();
 final _emailController = TextEditingController();
 final _passwordController = TextEditingController();
 final _confirmPasswordController = TextEditingController();
 final _departmentController = TextEditingController();
 final _phoneNumberController = TextEditingController();

 String _selectedRole = 'employee';
 bool _isActive = true;
 bool _isPasswordVisible = false;
 bool _isConfirmPasswordVisible = false;
 
 // États pour la validation en temps réel
 String? _firstNameError;
 String? _lastNameError;
 String? _emailError;
 String? _passwordError;
 String? _confirmPasswordError;
 String? _phoneError;
 
 bool _isFirstNameValid = false;
 bool _isLastNameValid = false;
 bool _isEmailValid = false;
 bool _isPasswordValid = false;
 bool _isConfirmPasswordValid = false;
 bool _isPhoneValid = false;

 @override
 void initState() {
 super.initState();
 if (widget.user != null) {{
 _initializeForm();
}
 
 // Ajouter les listeners pour la validation en temps réel
 _firstNameController.addListener(_validateFirstName);
 _lastNameController.addListener(_validateLastName);
 _emailController.addListener(_validateEmail);
 _passwordController.addListener(_validatePassword);
 _confirmPasswordController.addListener(_validateConfirmPassword);
 _phoneNumberController.addListener(_validatePhone);
 }

 void _initializeForm() {
 final user = widget.user!;
 _firstNameController.text = user.firstName;
 _lastNameController.text = user.lastName;
 _emailController.text = user.email;
 _selectedRole = user.role;
 _isActive = user.isActive;
 }

 // Méthodes de validation en temps réel
 void _validateFirstName() {
 final value = _firstNameController.text;
 final error = AppValidators.validateName(value);
 setState(() {
 _firstNameError = error;
 _isFirstNameValid = error == null && value.isNotEmpty;
});
 }

 void _validateLastName() {
 final value = _lastNameController.text;
 final error = AppValidators.validateName(value);
 setState(() {
 _lastNameError = error;
 _isLastNameValid = error == null && value.isNotEmpty;
});
 }

 void _validateEmail() {
 final value = _emailController.text;
 final error = AppValidators.validateEmail(value);
 setState(() {
 _emailError = error;
 _isEmailValid = error == null && value.isNotEmpty;
});
 }

 void _validatePassword() {
 if (_isEditMode) r{eturn;
 final value = _passwordController.text;
 final error = AppValidators.validatePassword(value);
 setState(() {
 _passwordError = error;
 _isPasswordValid = error == null && value.isNotEmpty;
});
 // Valider aussi la confirmation si elle a déjà été saisie
 if (_confirmPasswordController.text.isNotEmpty) {{
 _validateConfirmPassword();
}
 }

 void _validateConfirmPassword() {
 if (_isEditMode) r{eturn;
 final value = _confirmPasswordController.text;
 final error = AppValidators.validatePasswordConfirmation(value, _passwordController.text);
 setState(() {
 _confirmPasswordError = error;
 _isConfirmPasswordValid = error == null && value.isNotEmpty;
});
 }

 void _validatePhone() {
 final value = _phoneNumberController.text;
 final error = value.isEmpty ? null : AppValidators.validatePhone(value);
 setState(() {
 _phoneError = error;
 _isPhoneValid = error == null;
});
 }

 bool get _isFormValid {
 if (_isEditMode) {{
 return _isFirstNameValid && _isLastNameValid && _isEmailValid && _isPhoneValid;
} else {
 return _isFirstNameValid && _isLastNameValid && _isEmailValid && 
 _isPasswordValid && _isConfirmPasswordValid && _isPhoneValid;
}
 }

 @override
 void dispose() {
 _firstNameController.dispose();
 _lastNameController.dispose();
 _emailController.dispose();
 _passwordController.dispose();
 _confirmPasswordController.dispose();
 _departmentController.dispose();
 _phoneNumberController.dispose();
 super.dispose();
 }

 bool get _isEditMode => widget.user != null;

 String get _title => _isEditMode ? 'Modifier l\'utilisateur' : 'Ajouter un utilisateur';

 void _saveUser() async {
 if (!_formKey.currentState!.validate()){ return;

 final userNotifier = ref.read(userProvider.notifier);
 
 bool success;
 if (_isEditMode) {{
 success = await userNotifier.updateUser(
 userId: widget.user!.id,
 email: _emailController.text.trim(),
 firstName: _firstNameController.text.trim(),
 lastName: _lastNameController.text.trim(),
 role: _selectedRole,
 department: _departmentController.text.trim().isNotEmpty 
 ? _departmentController.text.trim() 
 : null,
 phoneNumber: _phoneNumberController.text.trim().isNotEmpty 
 ? _phoneNumberController.text.trim() 
 : null,
 isActive: _isActive,
 );
} else {
 success = await userNotifier.createUser(
 username: '${_firstNameController.text.trim().toLowerCase()}_${_lastNameController.text.trim().toLowerCase()}',
 email: _emailController.text.trim(),
 // password: _passwordController.text,
 firstName: _firstNameController.text.trim(),
 lastName: _lastNameController.text.trim(),
 role: _selectedRole,
 department: _departmentController.text.trim().isNotEmpty 
 ? _departmentController.text.trim() 
 : null,
 phoneNumber: _phoneNumberController.text.trim().isNotEmpty 
 ? _phoneNumberController.text.trim() 
 : null,
 );
}

 if (success && mounted) {{
 Navigator.pop(context);
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(_isEditMode ? 'Utilisateur modifié avec succès' : 'Utilisateur créé avec succès'),
 backgroundColor: Colors.green,
 ),
 );
} else if (mounted) {{
 final error = ref.read(userProvider).error;
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(error ?? 'Une erreur est survenue'),
 backgroundColor: Colors.red,
 ),
 );
}
 }

 @override
 Widget build(BuildContext context) {
 final userState = ref.watch(userProvider);
 final availableRoles = ref.watch(availableRolesProvider);

 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 backgroundColor: AppTheme.backgroundColor,
 appBar: AppBar(
 title: Text(_title),
 backgroundColor: AppTheme.primaryColor,
 foregroundColor: AppTheme.textOnPrimary,
 elevation: 2,
 ),
 body: LoadingOverlay(
 isLoading: userState.isCreating || userState.isUpdating,
 child: SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Form(
 key: _formKey,
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 _buildSectionTitle('Informations personnelles'),
 const SizedBox(height: 16),
 _buildPersonalInfoFields(),
 const SizedBox(height: 32),
 
 _buildSectionTitle('Informations professionnelles'),
 const SizedBox(height: 16),
 _buildProfessionalInfoFields(availableRoles),
 const SizedBox(height: 32),
 
 if (!_isEditMode) .{..[
 _buildSectionTitle('Mot de passe'),
 const SizedBox(height: 16),
 _buildPasswordFields(),
 const SizedBox(height: 32),
 ],
 
 _buildSectionTitle('Statut'),
 const SizedBox(height: 16),
 _buildStatusToggle(),
 const SizedBox(height: 32),
 
 _buildErrorBanner(userState.error),
 const SizedBox(height: 24),
 
 _buildActionButtons(),
 ],
 ),
 ),
 ),
 ),
 );
 }

 Widget _buildSectionTitle(String title) {
 return Text(
 title,
 style: const TextStyle(
 fontSize: 18,
 fontWeight: FontWeight.bold,
 color: AppTheme.primaryColor,
 ),
 );
 }

 Widget _buildPersonalInfoFields() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 children: [
 Row(
 children: [
 Expanded(
 child: CustomTextField(
 controller: _firstNameController,
 label: 'Prénom',
 validator: AppValidators.validateName,
 textCapitalization: TextCapitalization.words,
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: CustomTextField(
 controller: _lastNameController,
 label: 'Nom',
 validator: AppValidators.validateName,
 textCapitalization: TextCapitalization.words,
 ),
 ),
 ],
 ),
 const SizedBox(height: 16),
 CustomTextField(
 controller: _emailController,
 label: 'Email',
 keyboardType: TextInputType.emailAddress,
 validator: AppValidators.validateEmail,
 textInputAction: TextInputAction.next,
 ),
 const SizedBox(height: 16),
 CustomTextField(
 controller: _phoneNumberController,
 label: 'Numéro de téléphone',
 keyboardType: TextInputType.phone,
 validator: (value) => value?.isEmpty == true ? null : AppValidators.validatePhone(value),
 textInputAction: TextInputAction.next,
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildProfessionalInfoFields(List<String> availableRoles) {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 children: [
 DropdownButtonFormField<String>(
 value: _selectedRole,
 decoration: InputDecoration(
 labelText: 'Rôle',
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
 items: availableRoles.map((role) {
 return DropdownMenuItem(
 value: role,
 child: Text(_getRoleDisplayName(role)),
 );
 }).toList(),
 onChanged: (value) {
 if (value != null) {{
 setState(() {
 _selectedRole = value;
 });
 }
 },
 ),
 const SizedBox(height: 16),
 CustomTextField(
 controller: _departmentController,
 label: 'Département',
 textCapitalization: TextCapitalization.words,
 textInputAction: TextInputAction.next,
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildPasswordFields() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 children: [
 TextFormField(
 controller: _passwordController,
 obscureText: !_isPasswordVisible,
 decoration: InputDecoration(
 labelText: 'Mot de passe',
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
 suffixIcon: IconButton(
 icon: Icon(
 _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
 ),
 onPressed: () {
 setState(() {
 _isPasswordVisible = !_isPasswordVisible;
 });
 },
 ),
 ),
 validator: _isEditMode ? null : AppValidators.validatePassword,
 textInputAction: TextInputAction.next,
 ),
 const SizedBox(height: 16),
 TextFormField(
 controller: _confirmPasswordController,
 obscureText: !_isConfirmPasswordVisible,
 decoration: InputDecoration(
 labelText: 'Confirmer le mot de passe',
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
 suffixIcon: IconButton(
 icon: Icon(
 _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
 ),
 onPressed: () {
 setState(() {
 _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
 });
 },
 ),
 ),
 validator: _isEditMode ? null : (value) {
 if (value == null || value.isEmpty) {{
 return 'Veuillez confirmer le mot de passe';
 }
 if (value != _passwordController.text) {{
 return 'Les mots de passe ne correspondent pas';
 }
 return null;
 },
 textInputAction: TextInputAction.done,
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildStatusToggle() {
 return Card(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Row(
 children: [
 Icon(
 _isActive ? Icons.check_circle : Icons.cancel,
 color: _isActive ? Colors.green : Colors.red,
 ),
 const SizedBox(width: 12),
 Expanded(
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
 'Statut du compte',
 style: const TextStyle(
 fontSize: 16,
 fontWeight: FontWeight.w500,
 ),
 ),
 Text(
 _isActive ? 'L\'utilisateur peut se connecter' : 'L\'utilisateur ne peut pas se connecter',
 style: const TextStyle(
 fontSize: 12,
 color: AppTheme.textSecondary.withOpacity(0.7),
 ),
 ),
 ],
 ),
 ),
 Switch(
 value: _isActive,
 onChanged: (value) {
 setState(() {
 _isActive = value;
 });
 },
 activeColor: AppTheme.primaryColor,
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildErrorBanner(String? error) {
 if (error == null) r{eturn const SizedBox.shrink();
 
 return Container(
 width: double.infinity,
 padding: const EdgeInsets.all(1),
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

 Widget _buildActionButtons() {
 return Row(
 children: [
 Expanded(
 child: OutlinedButton(
 onPressed: () => Navigator.pop(context),
 style: OutlinedButton.styleFrom(
 padding: const EdgeInsets.symmetric(1),
 side: BorderSide(color: AppTheme.primaryColor),
 foregroundColor: AppTheme.primaryColor,
 ),
 child: const Text('Annuler'),
 ),
 ),
 const SizedBox(width: 16),
 Expanded(
 child: CustomButton(
 text: _isEditMode ? 'Mettre à jour' : 'Créer',
 onPressed: _saveUser,
 ),
 ),
 ],
 );
 }

 String _getRoleDisplayName(String role) {
 switch (role) {
 case 'admin':
 return 'Administrateur';
 case 'manager':
 return 'Manager';
 case 'employee':
 return 'Employé';
 case 'driver':
 return 'Chauffeur';
 case 'warehouse_staff':
 return 'Personnel d\'entrepôt';
 case 'customer_service':
 return 'Service client';
 default:
 return role.toUpperCase();
}
 }
}
