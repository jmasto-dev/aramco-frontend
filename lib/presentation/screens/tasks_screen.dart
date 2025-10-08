import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/task.dart';
import '../../core/services/task_service.dart';
import '../../core/services/api_service.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter.dart';
import '../widgets/task_form.dart';
import '../widgets/task_statistics.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';

class TasksScreen extends StatefulWidget {
 const TasksScreen({Key? key}) : super(key: key);

 @override
 State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
 with SingleTickerProviderStateMixin {
 late TabController _tabController;
 final ScrollController _scrollController = ScrollController();
 final TextEditingController _searchController = TextEditingController();
 
 String _selectedView = 'list'; // list, kanban, calendar
 String _sortBy = 'createdAt';
 String _sortOrder = 'desc';

 @override
 void initState() {
 super.initState();
 _tabController = TabController(length: 6, vsync: this);
 _scrollController.addListener(_onScroll);
 
 // Initialiser le provider
 final apiService = context.read<ApiService>();
 final taskService = TaskService(apiService, context.read());
 
 WidgetsBinding.instance.addPostFrameCallback((_) {
 context.read<TaskProvider>().loadTasks(refresh: true);
});
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
 context.read<TaskProvider>().loadMoreTasks();
}
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Gestion des Tâches'),
 backgroundColor: Theme.of(context).colorScheme.primary,
 foregroundColor: Colors.white,
 elevation: 0,
 actions: [
 IconButton(
 onPressed: _showStatistics,
 icon: const Icon(Icons.analytics_outlined),
 tooltip: 'Statistiques',
 ),
 PopupMenuButton<String>(
 onSelected: _handleViewChange,
 icon: const Icon(Icons.view_list),
 tooltip: 'Vue',
 itemBuilder: (context) => [
 const PopupMenuItem(
 value: 'list',
 child: Row(
 children: [
 Icon(Icons.list),
 const SizedBox(width: 8),
 Text('Liste'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'kanban',
 child: Row(
 children: [
 Icon(Icons.view_kanban),
 const SizedBox(width: 8),
 Text('Kanban'),
 ],
 ),
 ),
 const PopupMenuItem(
 value: 'calendar',
 child: Row(
 children: [
 Icon(Icons.calendar_month),
 const SizedBox(width: 8),
 Text('Calendrier'),
 ],
 ),
 ),
 ],
 ),
 ],
 bottom: TabBar(
 controller: _tabController,
 isScrollable: true,
 indicatorColor: Colors.white,
 labelColor: Colors.white,
 unselectedLabelColor: Colors.white70,
 onTap: (index) {
 _loadTasksForTab(index);
},
 tabs: const [
 Tab(text: 'Toutes'),
 Tab(text: 'À faire'),
 Tab(text: 'En cours'),
 Tab(text: 'En révision'),
 Tab(text: 'Terminées'),
 Tab(text: 'En retard'),
 ],
 ),
 ),
 body: Column(
 children: [
 // Barre de recherche et filtres
 _buildSearchAndFilters(),
 
 // Contenu principal
 Expanded(
 child: TabBarView(
 controller: _tabController,
 children: [
 _buildTasksView(), // Toutes
 _buildTasksView(status: TaskStatus.todo), // À faire
 _buildTasksView(status: TaskStatus.inProgress), // En cours
 _buildTasksView(status: TaskStatus.inReview), // En révision
 _buildTasksView(status: TaskStatus.completed), // Terminées
 _buildOverdueTasksView(), // En retard
 ],
 ),
 ),
 ],
 ),
 floatingActionButton: FloatingActionButton(
 onPressed: _showCreateTaskDialog,
 backgroundColor: Theme.of(context).colorScheme.primary,
 foregroundColor: Colors.white,
 child: const Icon(Icons.add),
 ),
 );
 }

 Widget _buildSearchAndFilters() {
 return Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Colors.grey[50],
 border: Border(
 bottom: BorderSide(color: Colors.grey[300]!),
 ),
 ),
 child: Column(
 children: [
 // Barre de recherche
 TextField(
 controller: _searchController,
 decoration: InputDecoration(
 hintText: 'Rechercher des tâches...',
 prefixIcon: const Icon(Icons.search),
 suffixIcon: _searchController.text.isNotEmpty
 ? IconButton(
 onPressed: () {
 _searchController.clear();
 context.read<TaskProvider>().searchTasks('');
},
 icon: const Icon(Icons.clear),
 )
 : null,
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 borderSide: BorderSide(color: Colors.grey[300]!),
 ),
 filled: true,
 fillColor: Colors.white,
 ),
 onChanged: (value) {
 context.read<TaskProvider>().searchTasks(value);
},
 ),
 const SizedBox(height: 12),
 
 // Filtres rapides et tri
 Row(
 children: [
 Expanded(
 child: SingleChildScrollView(
 scrollDirection: Axis.horizontal,
 child: Row(
 children: [
 FilterChip(
 label: const Text('Priorité haute'),
 selected: false,
 onSelected: (selected) {
 _applyQuickFilter(priority: TaskPriority.high);
},
 backgroundColor: Colors.white,
 selectedColor: Colors.orange.withOpacity(0.2),
 checkmarkColor: Colors.orange,
 ),
 const SizedBox(width: 8),
 FilterChip(
 label: const Text('Urgent'),
 selected: false,
 onSelected: (selected) {
 _applyQuickFilter(priority: TaskPriority.urgent);
},
 backgroundColor: Colors.white,
 selectedColor: Colors.red.withOpacity(0.2),
 checkmarkColor: Colors.red,
 ),
 const SizedBox(width: 8),
 FilterChip(
 label: const Text('Mes tâches'),
 selected: false,
 onSelected: (selected) {
 _applyQuickFilter(assigneeId: context.read<AuthProvider>().user?.id);
},
 backgroundColor: Colors.white,
 selectedColor: Colors.blue.withOpacity(0.2),
 checkmarkColor: Colors.blue,
 ),
 ],
 ),
 ),
 ),
 const SizedBox(width: 8),
 PopupMenuButton<String>(
 onSelected: _handleSort,
 icon: const Icon(Icons.sort),
 tooltip: 'Trier',
 itemBuilder: (context) => [
 const PopupMenuItem(value: 'createdAt_desc', child: Text('Plus récent')),
 const PopupMenuItem(value: 'createdAt_asc', child: Text('Plus ancien')),
 const PopupMenuItem(value: 'dueDate_asc', child: Text('Date d\'échéance')),
 const PopupMenuItem(value: 'priority_desc', child: Text('Priorité')),
 const PopupMenuItem(value: 'title_asc', child: Text('Titre')),
 ],
 ),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildTasksView({TaskStatus? status}) {
 return Consumer<TaskProvider>(
 builder: (context, provider, child) {
 if (provider.isLoading && provider.tasks.isEmpty) {{
 return const Center(child: CircularProgressIndicator());
 }

 if (provider.error != null && provider.tasks.isEmpty) {{
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
 const SizedBox(height: 16),
 Text(
 provider.error!,
 style: const TextStyle(color: Colors.grey[600]),
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: 16),
 CustomButton(
 text: 'Réessayer',
 onPressed: () => provider.loadTasks(refresh: true, status: status),
 ),
 ],
 ),
 );
 }

 final tasks = status != null
 ? provider.tasks.where((task) => task.status == status).toList()
 : provider.tasks;

 if (tasks.isEmpty) {{
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
 const SizedBox(height: 16),
 Text(
 'Aucune tâche trouvée',
 style: const TextStyle(color: Colors.grey[600]),
 ),
 const SizedBox(height: 16),
 CustomButton(
 text: 'Créer une tâche',
 onPressed: _showCreateTaskDialog,
 ),
 ],
 ),
 );
 }

 return RefreshIndicator(
 onRefresh: () async {
 await provider.loadTasks(refresh: true, status: status);
},
 child: _buildTasksList(tasks),
 );
 },
 );
 }

 Widget _buildOverdueTasksView() {
 return Consumer<TaskProvider>(
 builder: (context, provider, child) {
 final overdueTasks = provider.overdueTasks;

 if (overdueTasks.isEmpty) {{
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
 const SizedBox(height: 16),
 Text(
 'Aucune tâche en retard',
 style: const TextStyle(color: Colors.grey[600]),
 ),
 ],
 ),
 );
 }

 return RefreshIndicator(
 onRefresh: () async {
 await provider.loadTasks(refresh: true);
},
 child: _buildTasksList(overdueTasks),
 );
 },
 );
 }

 Widget _buildTasksList(List<Task> tasks) {
 if (_selectedView == 'kanban') {{
 return _buildKanbanView(tasks);
}

 return ListView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.all(1),
 itemCount: tasks.length + (context.read<TaskProvider>().isLoadingMore ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == tasks.length) {{
 return const Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: CircularProgressIndicator(),
 ),
 );
 }

 final task = tasks[index];
 return TaskCard(
 task: task,
 onTap: () => _showTaskDetails(task),
 onStatusChanged: (newStatus) {
 _updateTaskStatus(task.id, newStatus);
},
 onEdit: () => _showEditTaskDialog(task),
 onDelete: () => _showDeleteTaskDialog(task),
 );
 },
 );
 }

 Widget _buildKanbanView(List<Task> tasks) {
 final todoTasks = tasks.where((t) => t.isTodo).toList();
 final inProgressTasks = tasks.where((t) => t.isInProgress).toList();
 final reviewTasks = tasks.where((t) => t.isInReview).toList();
 final completedTasks = tasks.where((t) => t.isCompleted).toList();

 return SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Row(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 _buildKanbanColumn('À faire', todoTasks, TaskStatus.todo, Colors.blue),
 const SizedBox(width: 16),
 _buildKanbanColumn('En cours', inProgressTasks, TaskStatus.inProgress, Colors.orange),
 const SizedBox(width: 16),
 _buildKanbanColumn('En révision', reviewTasks, TaskStatus.inReview, Colors.purple),
 const SizedBox(width: 16),
 _buildKanbanColumn('Terminées', completedTasks, TaskStatus.completed, Colors.green),
 ],
 ),
 );
 }

 Widget _buildKanbanColumn(String title, List<Task> tasks, TaskStatus status, Color color) {
 return Expanded(
 child: Container(
 decoration: BoxDecoration(
 color: color.withOpacity(0.1),
 borderRadius: const Borderconst Radius.circular(1),
 border: Border.all(color: color.withOpacity(0.3)),
 ),
 child: Column(
 children: [
 Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: color.withOpacity(0.2),
 borderRadius: const Borderconst Radius.only(
 topLeft: const Radius.circular(8),
 topRight: const Radius.circular(8),
 ),
 ),
 child: Row(
 children: [
 Icon(Icons.circle, size: 12, color: color),
 const SizedBox(width: 8),
 Text(
 title,
 style: const TextStyle(
 fontWeight: FontWeight.bold,
 color: color,
 ),
 ),
 const Spacer(),
 Container(
 padding: const EdgeInsets.symmetric(1),
 decoration: BoxDecoration(
 color: color,
 borderRadius: const Borderconst Radius.circular(1),
 ),
 child: Text(
 '${tasks.length}',
 style: const TextStyle(
 color: Colors.white,
 fontSize: 12,
 fontWeight: FontWeight.bold,
 ),
 ),
 ),
 ],
 ),
 ),
 Expanded(
 child: tasks.isEmpty
 ? Center(
 child: Text(
 'Aucune tâche',
 style: const TextStyle(color: Colors.grey[500]),
 ),
 )
 : ListView.builder(
 padding: const EdgeInsets.all(1),
 itemCount: tasks.length,
 itemBuilder: (context, index) {
 final task = tasks[index];
 return Padding(
 padding: const EdgeInsets.only(bottom: 8),
 child: TaskCard(
 task: task,
 compact: true,
 onTap: () => _showTaskDetails(task),
 onStatusChanged: (newStatus) {
 _updateTaskStatus(task.id, newStatus);
},
 ),
 );
},
 ),
 ),
 ],
 ),
 ),
 );
 }

 void _loadTasksForTab(int index) {
 TaskStatus? status;
 switch (index) {
 case 1:
 status = TaskStatus.todo;
 break;
 case 2:
 status = TaskStatus.inProgress;
 break;
 case 3:
 status = TaskStatus.inReview;
 break;
 case 4:
 status = TaskStatus.completed;
 break;
 case 5:
 // Tâches en retard - géré séparément
 context.read<TaskProvider>().loadTasks(refresh: true);
 return;
}

 context.read<TaskProvider>().loadTasks(refresh: true, status: status);
 }

 void _handleViewChange(String view) {
 setState(() {
 _selectedView = view;
});
 }

 void _handleSort(String sortOption) {
 final parts = sortOption.split('_');
 setState(() {
 _sortBy = parts[0];
 _sortOrder = parts[1];
});
 
 context.read<TaskProvider>().loadTasks(
 refresh: true,
 sortBy: _sortBy,
 sortOrder: _sortOrder,
 );
 }

 void _applyQuickFilter({
 TaskPriority? priority,
 String? assigneeId,
 }) {
 context.read<TaskProvider>().loadTasks(
 refresh: true,
 priority: priority,
 assigneeId: assigneeId,
 );
 }

 void _showCreateTaskDialog() {
 showDialog(
 context: context,
 builder: (context) => TaskForm(
 onSubmit: (taskData) async {
 final success = await context.read<TaskProvider>().createTask(
 title: taskData['title'],
 description: taskData['description'],
 type: taskData['type'],
 assigneeId: taskData['assigneeId'],
 priority: taskData['priority'],
 projectId: taskData['projectId'],
 dueDate: taskData['dueDate'],
 estimatedHours: taskData['estimatedHours'],
 );
 
 if (success) {{
 Navigator.of(context).pop();
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Tâche créée avec succès')),
 );
}
 },
 ),
 );
 }

 void _showEditTaskDialog(Task task) {
 showDialog(
 context: context,
 builder: (context) => TaskForm(
 task: task,
 onSubmit: (taskData) async {
 final success = await context.read<TaskProvider>().updateTask(
 taskId: task.id,
 title: taskData['title'],
 description: taskData['description'],
 status: taskData['status'],
 priority: taskData['priority'],
 assigneeId: taskData['assigneeId'],
 dueDate: taskData['dueDate'],
 estimatedHours: taskData['estimatedHours'],
 actualHours: taskData['actualHours'],
 progress: taskData['progress'],
 );
 
 if (success) {{
 Navigator.of(context).pop();
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Tâche mise à jour avec succès')),
 );
}
 },
 ),
 );
 }

 void _showTaskDetails(Task task) {
 context.read<TaskProvider>().selectTask(task);
 Navigator.of(context).pushNamed('/task-details');
 }

 void _updateTaskStatus(String taskId, TaskStatus newStatus) async {
 final success = await context.read<TaskProvider>().updateTask(
 taskId: taskId,
 status: newStatus,
 );
 
 if (success) {{
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Statut mis à jour')),
 );
}
 }

 void _showDeleteTaskDialog(Task task) {
 showDialog(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Supprimer la tâche'),
 content: Text('Êtes-vous sûr de vouloir supprimer la tâche "${task.title}" ?'),
 actions: [
 TextButton(
 onPressed: () => Navigator.of(context).pop(),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () async {
 final success = await context.read<TaskProvider>().deleteTask(task.id);
 if (success) {{
 Navigator.of(context).pop();
 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('Tâche supprimée')),
 );
 }
},
 style: TextButton.styleFrom(foregroundColor: Colors.red),
 child: const Text('Supprimer'),
 ),
 ],
 ),
 );
 }

 void _showStatistics() {
 showDialog(
 context: context,
 builder: (context) => const Dialog(
 child: TaskStatistics(),
 ),
 );
 }
}
