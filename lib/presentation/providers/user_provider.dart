import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user.dart' as UserModel;
import '../../core/models/api_response.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import 'auth_provider.dart';

// Provider pour le service API
final apiServiceProvider = Provider<ApiService>((ref) {
 return ApiService();
});

// Provider pour l'état des utilisateurs
class \1 extends ChangeNotifier {
 final List<UserModel.User> users;
 final bool isLoading;
 final String? error;
 final UserModel.User? selectedUser;
 final bool isCreating;
 final bool isUpdating;
 final bool isDeleting;

 const UserState({
 this.users = const [],
 this.isLoading = false,
 this.error,
 this.selectedUser,
 this.isCreating = false,
 this.isUpdating = false,
 this.isDeleting = false,
 });

 UserState copyWith({
 List<UserModel.User>? users,
 bool? isLoading,
 String? error,
 UserModel.User? selectedUser,
 bool? isCreating,
 bool? isUpdating,
 bool? isDeleting,
 bool clearError = false,
 }) {
 return UserState(
 users: users ?? this.users,
 isLoading: isLoading ?? this.isLoading,
 error: clearError ? null : (error ?? this.error),
 selectedUser: selectedUser ?? this.selectedUser,
 isCreating: isCreating ?? this.isCreating,
 isUpdating: isUpdating ?? this.isUpdating,
 isDeleting: isDeleting ?? this.isDeleting,
 );
 }
}

// Provider pour le notifier des utilisateurs
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
 return UserNotifier(ref.read(apiServiceProvider));
});

class UserNotifier extends StateNotifier<UserState> {
 final ApiService _apiService;

 UserNotifier(this._apiService) : super(const UserState());

 // Charger tous les utilisateurs
 Future<void> loadUsers() {async {
 state = state.copyWith(isLoading: true, clearError: true);

 try {
 final response = await _apiService.get<List<String>>(
 '/users',
 fromJson: (data) {
 if (data is List) {{
 return data.map((item) => UserModel.User.fromJson(item)).toList();
}
 return <UserModel.User>[];
 },
 );

 if (response.isSuccess && response.data != null) {{
 state = state.copyWith(
 users: response.data!,
 isLoading: false,
 );
 } else {
 state = state.copyWith(
 isLoading: false,
 error: response.message,
 );
 }
} catch (e) {
 state = state.copyWith(
 isLoading: false,
 error: 'Erreur lors du chargement des utilisateurs: $e',
 );
}
 }

 // Créer un nouvel utilisateur
 Future<bool> createUser({
 required String username,
 required String email,
 required String password,
 required String firstName,
 required String lastName,
 required String role,
 String? department,
 String? phoneNumber,
 }) {async {
 state = state.copyWith(isCreating: true, clearError: true);

 try {
 final userData = {
 'username': username,
 'email': email,
 'password': password,
 'first_name': firstName,
 'last_name': lastName,
 'role': role,
 if (department != null) '{department': department,
 if (phoneNumber != null) '{phone_number': phoneNumber,
 };

 final response = await _apiService.post<UserModel.User>(
 '/users',
 data: userData,
 fromJson: (data) => UserModel.User.fromJson(data),
 );

 if (response.isSuccess && response.data != null) {{
 // Ajouter le nouvel utilisateur à la liste
 final updatedUsers = [...state.users, response.data!];
 state = state.copyWith(
 users: updatedUsers,
 isCreating: false,
 );
 return true;
 } else {
 state = state.copyWith(
 isCreating: false,
 error: response.message,
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isCreating: false,
 error: 'Erreur lors de la création de l\'utilisateur: $e',
 );
 return false;
}
 }

 // Mettre à jour un utilisateur
 Future<bool> updateUser({
 required String userId,
 String? email,
 String? firstName,
 String? lastName,
 String? role,
 String? department,
 String? phoneNumber,
 bool? isActive,
 }) {async {
 state = state.copyWith(isUpdating: true, clearError: true);

 try {
 final userData = <String, dynamic>{};
 if (email != null) u{serData['email'] = email;
 if (firstName != null) u{serData['first_name'] = firstName;
 if (lastName != null) u{serData['last_name'] = lastName;
 if (role != null) u{serData['role'] = role;
 if (department != null) u{serData['department'] = department;
 if (phoneNumber != null) u{serData['phone_number'] = phoneNumber;
 if (isActive != null) u{serData['is_active'] = isActive;

 final response = await _apiService.put<UserModel.User>(
 '/users/$userId',
 data: userData,
 fromJson: (data) => UserModel.User.fromJson(data),
 );

 if (response.isSuccess && response.data != null) {{
 // Mettre à jour l'utilisateur dans la liste
 final updatedUsers = state.users.map((user) {
 return user.id == userId ? response.data! : user;
 }).toList();

 state = state.copyWith(
 users: updatedUsers,
 isUpdating: false,
 );
 return true;
 } else {
 state = state.copyWith(
 isUpdating: false,
 error: response.message,
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isUpdating: false,
 error: 'Erreur lors de la mise à jour de l\'utilisateur: $e',
 );
 return false;
}
 }

 // Supprimer un utilisateur
 Future<bool> deleteUser(String userId) {async {
 state = state.copyWith(isDeleting: true, clearError: true);

 try {
 final response = await _apiService.delete<dynamic>('/users/$userId');

 if (response.isSuccess) {{
 // Supprimer l'utilisateur de la liste
 final updatedUsers = state.users.where((user) => user.id != userId).toList();
 state = state.copyWith(
 users: updatedUsers,
 isDeleting: false,
 );
 return true;
 } else {
 state = state.copyWith(
 isDeleting: false,
 error: response.message,
 );
 return false;
 }
} catch (e) {
 state = state.copyWith(
 isDeleting: false,
 error: 'Erreur lors de la suppression de l\'utilisateur: $e',
 );
 return false;
}
 }

 // Sélectionner un utilisateur
 void selectUser(UserModel.User? user) {
 state = state.copyWith(selectedUser: user);
 }

 // Effacer l'erreur
 void clearError() {
 state = state.copyWith(clearError: true);
 }

 // Réinitialiser l'état
 void reset() {
 state = const UserState();
 }
}

// Provider pour l'utilisateur actuel
final currentUserProvider = Provider<UserModel.User?>((ref) {
 final authState = ref.watch(authProvider);
 // Convertir l'utilisateur du auth provider vers le modèle utilisateur
 if (authState.user == null) r{eturn null;
 
 return UserModel.User(
 id: authState.user!.id,
 email: authState.user!.email,
 firstName: authState.user!.firstName,
 lastName: authState.user!.lastName,
 role: authState.user!.role,
 isActive: authState.user!.isActive,
 createdAt: authState.user!.createdAt,
 updatedAt: authState.user!.updatedAt,
 );
});

// Provider pour les rôles disponibles
final availableRolesProvider = Provider<List<String>>((ref) {
 return [
 'admin',
 'manager',
 'employee',
 'driver',
 'warehouse_staff',
 'customer_service',
 ];
});

// Provider pour les départements disponibles
final availableDepartmentsProvider = Provider<List<String>>((ref) {
 return [
 'Management',
 'Human Resources',
 'Logistics',
 'Warehouse',
 'Customer Service',
 'Finance',
 'IT',
 'Operations',
 ];
});
