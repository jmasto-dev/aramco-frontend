import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../core/models/task.dart';
import '../../core/services/task_service.dart';
import '../../core/models/api_response.dart';

class TaskProvider with ChangeNotifier {
 final TaskService _taskService;

 TaskProvider(this._taskService);

 // État
 List<Task> _tasks = [];
 List<Task> _filteredTasks = [];
 Task? _selectedTask;
 List<Task> _subtasks = [];
 List<TaskComment> _comments = [];
 List<TaskHistory> _history = [];
 Map<String, dynamic> _statistics = {};

 // État de chargement
 bool _isLoading = false;
 bool _isLoadingMore = false;
 bool _isCreating = false;
 bool _isUpdating = false;
 bool _isDeleting = false;

 // Pagination
 int _currentPage = 1;
 int _totalPages = 1;
 int _totalItems = 0;
 bool _hasMore = true;

 // Filtres
 TaskFilter _currentFilter = TaskFilter();
 String _searchQuery = '';

 // Erreurs
 String? _error;

 // Getters
 List<Task> get tasks => _filteredTasks;
 List<Task> get allTasks => _tasks;
 Task? get selectedTask => _selectedTask;
 List<Task> get subtasks => _subtasks;
 List<TaskComment> get comments => _comments;
 List<TaskHistory> get history => _history;
 Map<String, dynamic> get statistics => _statistics;

 bool get isLoading => _isLoading;
 bool get isLoadingMore => _isLoadingMore;
 bool get isCreating => _isCreating;
 bool get isUpdating => _isUpdating;
 bool get isDeleting => _isDeleting;

 int get currentPage => _currentPage;
 int get totalPages => _totalPages;
 int get totalItems => _totalItems;
 bool get hasMore => _hasMore;

 TaskFilter get currentFilter => _currentFilter;
 String get searchQuery => _searchQuery;
 String? get error => _error;

 // Getters calculés
 List<Task> get todoTasks => _tasks.where((task) => task.isTodo).toList();
 List<Task> get inProgressTasks => _tasks.where((task) => task.isInProgress).toList();
 List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
 List<Task> get overdueTasks => _tasks.where((task) => task.isOverdue).toList();
 List<Task> get highPriorityTasks => _tasks.where((task) => task.isHighPriority).toList();
 List<Task> get urgentTasks => _tasks.where((task) => task.isUrgent).toList();

 int get todoCount => todoTasks.length;
 int get inProgressCount => inProgressTasks.length;
 int get completedCount => completedTasks.length;
 int get overdueCount => overdueTasks.length;
 int get highPriorityCount => highPriorityTasks.length;
 int get urgentCount => urgentTasks.length;

 double get completionRate {
 if (_tasks.isEmpty) r{eturn 0.0;
 return completedTasks.length / _tasks.length;
 }

 // Méthodes principales
 Future<void> loadTasks({
 bool refresh = false,
 TaskStatus? status,
 TaskPriority? priority,
 TaskType? type,
 String? assigneeId,
 String? projectId,
 String? reporterId,
 String? searchQuery,
 DateTime? startDate,
 DateTime? endDate,
 List<String>? tagIds,
 bool? isOverdue,
 bool? hasAttachments,
 String? sortBy,
 String? sortOrder,
 }) {async {
 if (refresh) {{
 _currentPage = 1;
 _hasMore = true;
 _tasks.clear();
 _filteredTasks.clear();
}

 if (!_hasMore && !refresh) r{eturn;

 _setLoading(true);

 try {
 final response = await _taskService.getTasks(
 page: _currentPage,
 limit: 20,
 status: status ?? _currentFilter.status,
 priority: priority ?? _currentFilter.priority,
 type: type ?? _currentFilter.type,
 assigneeId: assigneeId ?? _currentFilter.assigneeId,
 projectId: projectId ?? _currentFilter.projectId,
 reporterId: reporterId ?? _currentFilter.reporterId,
 searchQuery: searchQuery ?? _searchQuery,
 startDate: startDate ?? _currentFilter.startDate,
 endDate: endDate ?? _currentFilter.endDate,
 tagIds: tagIds ?? _currentFilter.tagIds,
 isOverdue: isOverdue ?? _currentFilter.isOverdue,
 hasAttachments: hasAttachments ?? _currentFilter.hasAttachments,
 sortBy: sortBy,
 sortOrder: sortOrder,
 );

 if (response.success && response.data != null) {{
 if (refresh) {{
 _tasks = response.data!;
 } else {
 _tasks.addAll(response.data!);
 }

 _currentPage++;
 _hasMore = response.data!.length == 20;
 
 _updateCurrentFilter(
 status: status,
 priority: priority,
 type: type,
 assigneeId: assigneeId,
 projectId: projectId,
 reporterId: reporterId,
 searchQuery: searchQuery,
 startDate: startDate,
 endDate: endDate,
 tagIds: tagIds,
 isOverdue: isOverdue,
 hasAttachments: hasAttachments,
 );

 _applyFilters();
 _clearError();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des tâches');
 }
} catch (e) {
 _setError('Erreur inattendue: $e');
} finally {
 _setLoading(false);
}
 }

 Future<void> loadMoreTasks() {async {
 if (_isLoadingMore || !_hasMore) r{eturn;

 _setLoadingMore(true);

 try {
 final response = await _taskService.getTasks(
 page: _currentPage,
 limit: 20,
 status: _currentFilter.status,
 priority: _currentFilter.priority,
 type: _currentFilter.type,
 assigneeId: _currentFilter.assigneeId,
 projectId: _currentFilter.projectId,
 reporterId: _currentFilter.reporterId,
 searchQuery: _searchQuery,
 startDate: _currentFilter.startDate,
 endDate: _currentFilter.endDate,
 tagIds: _currentFilter.tagIds,
 isOverdue: _currentFilter.isOverdue,
 hasAttachments: _currentFilter.hasAttachments,
 );

 if (response.success && response.data != null) {{
 _tasks.addAll(response.data!);
 _currentPage++;
 _hasMore = response.data!.length == 20;
 _applyFilters();
 }
} catch (e) {
 _setError('Erreur lors du chargement supplémentaire: $e');
} finally {
 _setLoadingMore(false);
}
 }

 Future<void> loadTaskById(String taskId) {async {
 _setLoading(true);

 try {
 final response = await _taskService.getTaskById(taskId);

 if (response.success && response.data != null) {{
 _selectedTask = response.data;
 
 // Mettre à jour la tâche dans la liste si elle existe
 final index = _tasks.indexWhere((task) => task.id == taskId);
 if (index != -1) {{
 _tasks[index] = response.data!;
 _applyFilters();
 }
 
 _clearError();
 } else {
 _setError(response.message ?? 'Tâche non trouvée');
 }
} catch (e) {
 _setError('Erreur inattendue: $e');
} finally {
 _setLoading(false);
}
 }

 Future<bool> createTask({
 required String title,
 required String description,
 required TaskType type,
 required String assigneeId,
 TaskPriority priority = TaskPriority.normal,
 String? projectId,
 String? parentTaskId,
 DateTime? dueDate,
 DateTime? startDate,
 int estimatedHours = 0,
 List<String>? tagIds,
 List<File>? attachments,
 Map<String, dynamic>? customFields,
 TaskDependencies? dependencies,
 }) {async {
 _setCreating(true);

 try {
 final response = await _taskService.createTask(
 title: title,
 description: description,
 type: type,
 assigneeId: assigneeId,
 priority: priority,
 projectId: projectId,
 parentTaskId: parentTaskId,
 dueDate: dueDate,
 startDate: startDate,
 estimatedHours: estimatedHours,
 tagIds: tagIds,
 attachments: attachments,
 customFields: customFields,
 dependencies: dependencies,
 );

 if (response.success && response.data != null) {{
 _tasks.insert(0, response.data!);
 _applyFilters();
 _clearError();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la création de la tâche');
 return false;
 }
} catch (e) {
 _setError('Erreur inattendue: $e');
 return false;
} finally {
 _setCreating(false);
}
 }

 Future<bool> updateTask({
 required String taskId,
 String? title,
 String? description,
 TaskStatus? status,
 TaskPriority? priority,
 TaskType? type,
 String? assigneeId,
 String? projectId,
 DateTime? dueDate,
 DateTime? startDate,
 DateTime? completedAt,
 int? estimatedHours,
 int? actualHours,
 double? progress,
 List<String>? tagIds,
 Map<String, dynamic>? customFields,
 TaskDependencies? dependencies,
 }) {async {
 _setUpdating(true);

 try {
 final response = await _taskService.updateTask(
 taskId: taskId,
 title: title,
 description: description,
 status: status,
 priority: priority,
 type: type,
 assigneeId: assigneeId,
 projectId: projectId,
 dueDate: dueDate,
 startDate: startDate,
 completedAt: completedAt,
 estimatedHours: estimatedHours,
 actualHours: actualHours,
 progress: progress,
 tagIds: tagIds,
 customFields: customFields,
 dependencies: dependencies,
 );

 if (response.success && response.data != null) {{
 final index = _tasks.indexWhere((task) => task.id == taskId);
 if (index != -1) {{
 _tasks[index] = response.data!;
 _applyFilters();
 }
 
 if (_selectedTask?.id == taskId) {{
 _selectedTask = response.data!;
 }
 
 _clearError();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la mise à jour de la tâche');
 return false;
 }
} catch (e) {
 _setError('Erreur inattendue: $e');
 return false;
} finally {
 _setUpdating(false);
}
 }

 Future<bool> deleteTask(String taskId) {async {
 _setDeleting(true);

 try {
 final response = await _taskService.deleteTask(taskId);

 if (response.success) {{
 _tasks.removeWhere((task) => task.id == taskId);
 _applyFilters();
 
 if (_selectedTask?.id == taskId) {{
 _selectedTask = null;
 }
 
 _clearError();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la suppression de la tâche');
 return false;
 }
} catch (e) {
 _setError('Erreur inattendue: $e');
 return false;
} finally {
 _setDeleting(false);
}
 }

 // Sous-tâches
 Future<void> loadSubtasks(String parentTaskId) {async {
 _setLoading(true);

 try {
 final response = await _taskService.getSubtasks(parentTaskId);

 if (response.success && response.data != null) {{
 _subtasks = response.data!;
 _clearError();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des sous-tâches');
 }
} catch (e) {
 _setError('Erreur inattendue: $e');
} finally {
 _setLoading(false);
}
 }

 // Commentaires
 Future<bool> addComment({
 required String taskId,
 required String content,
 String? parentId,
 List<File>? attachments,
 }) {async {
 try {
 final response = await _taskService.addComment(
 taskId: taskId,
 content: content,
 parentId: parentId,
 attachments: attachments,
 );

 if (response.success && response.data != null) {{
 _comments.insert(0, response.data!);
 _clearError();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de l\'ajout du commentaire');
 return false;
 }
} catch (e) {
 _setError('Erreur inattendue: $e');
 return false;
}
 }

 Future<bool> deleteComment(String taskId, String commentId) {async {
 try {
 final response = await _taskService.deleteComment(taskId, commentId);

 if (response.success) {{
 _comments.removeWhere((comment) => comment.id == commentId);
 _clearError();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la suppression du commentaire');
 return false;
 }
} catch (e) {
 _setError('Erreur inattendue: $e');
 return false;
}
 }

 // Historique
 Future<void> loadTaskHistory(String taskId) {async {
 _setLoading(true);

 try {
 final response = await _taskService.getTaskHistory(taskId);

 if (response.success && response.data != null) {{
 _history = response.data!;
 _clearError();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement de l\'historique');
 }
} catch (e) {
 _setError('Erreur inattendue: $e');
} finally {
 _setLoading(false);
}
 }

 // Statistiques
 Future<void> loadStatistics({
 String? projectId,
 String? assigneeId,
 DateTime? startDate,
 DateTime? endDate,
 }) {async {
 _setLoading(true);

 try {
 final response = await _taskService.getTaskStatistics(
 projectId: projectId,
 assigneeId: assigneeId,
 startDate: startDate,
 endDate: endDate,
 );

 if (response.success && response.data != null) {{
 _statistics = response.data!;
 _clearError();
 } else {
 _setError(response.message ?? 'Erreur lors du chargement des statistiques');
 }
} catch (e) {
 _setError('Erreur inattendue: $e');
} finally {
 _setLoading(false);
}
 }

 // Recherche
 Future<void> searchTasks(String query) {async {
 _searchQuery = query;
 _currentPage = 1;
 _hasMore = true;
 _tasks.clear();
 _filteredTasks.clear();

 if (query.isNotEmpty) {{
 await loadTasks(searchQuery: query);
} else {
 await loadTasks(refresh: true);
}
 }

 // Actions en lot
 Future<bool> bulkUpdateTasks({
 required List<String> taskIds,
 TaskStatus? status,
 TaskPriority? priority,
 String? assigneeId,
 String? projectId,
 List<String>? tagIds,
 }) {async {
 try {
 final response = await _taskService.bulkUpdateTasks(
 taskIds: taskIds,
 status: status,
 priority: priority,
 assigneeId: assigneeId,
 projectId: projectId,
 tagIds: tagIds,
 );

 if (response.success) {{
 // Recharger les tâches pour refléter les changements
 await loadTasks(refresh: true);
 _clearError();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la mise à jour groupée');
 return false;
 }
} catch (e) {
 _setError('Erreur inattendue: $e');
 return false;
}
 }

 Future<bool> bulkDeleteTasks(List<String> taskIds) {async {
 try {
 final response = await _taskService.bulkDeleteTasks(taskIds);

 if (response.success) {{
 // Recharger les tâches pour refléter les changements
 await loadTasks(refresh: true);
 _clearError();
 return true;
 } else {
 _setError(response.message ?? 'Erreur lors de la suppression groupée');
 return false;
 }
} catch (e) {
 _setError('Erreur inattendue: $e');
 return false;
}
 }

 // Méthodes utilitaires
 void selectTask(Task? task) {
 _selectedTask = task;
 notifyListeners();
 }

 void clearSelectedTask() {
 _selectedTask = null;
 _comments.clear();
 _history.clear();
 notifyListeners();
 }

 void clearError() {
 _error = null;
 notifyListeners();
 }

 void refresh() {
 loadTasks(refresh: true);
 }

 // Méthodes privées
 void _setLoading(bool loading) {
 _isLoading = loading;
 notifyListeners();
 }

 void _setLoadingMore(bool loading) {
 _isLoadingMore = loading;
 notifyListeners();
 }

 void _setCreating(bool creating) {
 _isCreating = creating;
 notifyListeners();
 }

 void _setUpdating(bool updating) {
 _isUpdating = updating;
 notifyListeners();
 }

 void _setDeleting(bool deleting) {
 _isDeleting = deleting;
 notifyListeners();
 }

 void _setError(String error) {
 _error = error;
 notifyListeners();
 }

 void _clearError() {
 _error = null;
 notifyListeners();
 }

 void _updateCurrentFilter({
 TaskStatus? status,
 TaskPriority? priority,
 TaskType? type,
 String? assigneeId,
 String? projectId,
 String? reporterId,
 String? searchQuery,
 DateTime? startDate,
 DateTime? endDate,
 List<String>? tagIds,
 bool? isOverdue,
 bool? hasAttachments,
 }) {
 _currentFilter = TaskFilter(
 status: status ?? _currentFilter.status,
 priority: priority ?? _currentFilter.priority,
 type: type ?? _currentFilter.type,
 assigneeId: assigneeId ?? _currentFilter.assigneeId,
 projectId: projectId ?? _currentFilter.projectId,
 reporterId: reporterId ?? _currentFilter.reporterId,
 searchQuery: searchQuery ?? _currentFilter.searchQuery,
 startDate: startDate ?? _currentFilter.startDate,
 endDate: endDate ?? _currentFilter.endDate,
 tagIds: tagIds ?? _currentFilter.tagIds,
 isOverdue: isOverdue ?? _currentFilter.isOverdue,
 hasAttachments: hasAttachments ?? _currentFilter.hasAttachments,
 );
 }

 void _applyFilters() {
 _filteredTasks = _tasks.where((task) {
 // Appliquer les filtres localement si nécessaire
 if (_searchQuery.isNotEmpty) {{
 final query = _searchQuery.toLowerCase();
 if (!task.title.toLowerCase().{contains(query) &&
 !task.description.toLowerCase().contains(query)) {
 return false;
 }
 }

 return true;
}).toList();

 notifyListeners();
 }
}
