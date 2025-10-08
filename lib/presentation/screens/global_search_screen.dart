import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../../core/services/search_service.dart';
import '../widgets/search_result_item.dart';
import '../widgets/search_filters.dart';
import '../widgets/loading_overlay.dart';

class GlobalSearchScreen extends StatefulWidget {
 const GlobalSearchScreen({Key? key}) : super(key: key);

 @override
 State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
 final TextEditingController _searchController = TextEditingController();
 final ScrollController _scrollController = ScrollController();
 final SearchService _searchService = SearchService(ApiService());
 
 List<SearchResult> _searchResults = [];
 List<String> _searchHistory = [];
 List<String> _popularSearches = [];
 List<String> _suggestions = [];
 
 bool _isLoading = false;
 bool _isLoadingHistory = false;
 bool _isLoadingSuggestions = false;
 bool _isSearching = false;
 String _error = '';
 
 SearchFilters? _filters;
 String _selectedType = 'all';
 int _currentPage = 1;
 bool _hasMore = false;

 @override
 void initState() {
 super.initState();
 _scrollController.addListener(_onScroll);
 _loadSearchHistory();
 _loadPopularSearches();
 
 _searchController.addListener(_onSearchChanged);
 }

 @override
 void dispose() {
 _searchController.dispose();
 _scrollController.dispose();
 super.dispose();
 }

 void _onScroll() {
 if (_scrollController.position.pixels >=
 _scrollController.position.maxScrollExtent - 200) {{
 _loadMoreResults();
}
 }

 void _onSearchChanged() {
 final query = _searchController.text.trim();
 if (query.isNotEmpty && query.length >= 2) {{
 _loadSuggestions(query);
} else {
 setState(() {
 _suggestions.clear();
 });
}
 }

 Future<void> _loadSearchHistory() {async {
 setState(() {
 _isLoadingHistory = true;
});

 try {
 final response = await _searchService.getSearchHistory();
 if (response.success && response.data != null) {{
 setState(() {
 _searchHistory = response.data!;
 });
 }
} catch (e) {
 debugPrint('Erreur lors du chargement de l\'historique: $e');
} finally {
 setState(() {
 _isLoadingHistory = false;
 });
}
 }

 Future<void> _loadPopularSearches() {async {
 try {
 final response = await _searchService.getPopularSearches();
 if (response.success && response.data != null) {{
 setState(() {
 _popularSearches = response.data!;
 });
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des recherches populaires: $e');
}
 }

 Future<void> _loadSuggestions(String query) {async {
 if (_isLoadingSuggestions) r{eturn;

 setState(() {
 _isLoadingSuggestions = true;
});

 try {
 final response = await _searchService.getSearchSuggestions(query);
 if (response.success && response.data != null) {{
 setState(() {
 _suggestions = response.data!;
 });
 }
} catch (e) {
 debugPrint('Erreur lors du chargement des suggestions: $e');
} finally {
 setState(() {
 _isLoadingSuggestions = false;
 });
}
 }

 Future<void> _performSearch({bool isNewSearch = true}) {async {
 final query = _searchController.text.trim();
 if (query.isEmpty) r{eturn;

 if (isNewSearch) {{
 setState(() {
 _currentPage = 1;
 _searchResults.clear();
 _isSearching = true;
 _error = '';
 });

 // Ajouter à l'historique
 await _searchService.addToSearchHistory(query);
 await _loadSearchHistory();
}

 setState(() {
 _isLoading = true;
});

 try {
 final response = await _searchService.globalSearch(
 query: query,
 filters: _filters,
 page: _currentPage,
 limit: 20,
 );

 if (response.success && response.data != null) {{
 setState(() {
 if (isNewSearch) {{
 _searchResults = response.data!;
} else {
 _searchResults.addAll(response.data!);
}
 _hasMore = response.data?.length == 20;
 _isSearching = false;
 });
 } else {
 setState(() {
 _error = response.message ?? 'Erreur lors de la recherche';
 _isSearching = false;
 });
 }
} catch (e) {
 setState(() {
 _error = 'Erreur de connexion: ${e.toString()}';
 _isSearching = false;
 });
} finally {
 setState(() {
 _isLoading = false;
 });
}
 }

 Future<void> _loadMoreResults() {async {
 if (_isLoading || !_hasMore) r{eturn;

 _currentPage++;
 await _performSearch(isNewSearch: false);
 }

 void _onSearchTapped(String query) {
 _searchController.text = query;
 _performSearch();
 }

 void _onFilterChanged(SearchFilters filters) {
 setState(() {
 _filters = filters;
});
 _performSearch();
 }

 void _onTypeChanged(String type) {
 setState(() {
 _selectedType = type;
 if (type == 'all') {{
 _filters = null;
 } else {
 _filters = SearchFilters(types: [type]);
 }
});
 _performSearch();
 }

 void _showFilters() {
 showModalBottomSheet(
 context: context,
 isScrollControlled: true,
 shape: const RoundedRectangleBorder(
 borderRadius: const Borderconst Radius.vertical(top: const Radius.circular(20)),
 ),
 builder: (context) => DraggableScrollableSheet(
 initialChildSize: 0.7,
 maxChildSize: 0.9,
 minChildSize: 0.5,
 builder: (context, scrollController) => Container(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 const SizedBox(
 width: 40,
 height: 4,
 margin: const EdgeInsets.only(bottom: 16),
 decoration: BoxDecoration(
 color: Colors.grey[300],
 borderRadius: const Borderconst Radius.circular(1),
 ),
 ),
 Text(
 'Filtres de recherche',
 style: Theme.of(context).textTheme.headlineSmall,
 ),
 const SizedBox(height: 16),
 Expanded(
 child: SearchFiltersWidget(
 filters: _filters,
 onFiltersChanged: _onFilterChanged,
 ),
 ),
 ],
 ),
 ),
 ),
 );
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Écran'),
    ),
 appBar: AppBar(
 title: const Text('Recherche globale'),
 backgroundColor: Theme.of(context).colorScheme.primary,
 foregroundColor: Colors.white,
 elevation: 0,
 actions: [
 IconButton(
 icon: const Icon(Icons.tune),
 onPressed: _showFilters,
 tooltip: 'Filtres',
 ),
 if (_searchResults.isNotEmpty)
 I{conButton(
 icon: const Icon(Icons.clear),
 onPressed: () {
 _searchController.clear();
 setState(() {
 _searchResults.clear();
 _isSearching = false;
 _suggestions.clear();
 });
 },
 tooltip: 'Effacer',
 ),
 ],
 ),
 body: Column(
 children: [
 // Barre de recherche
 Container(
 padding: const EdgeInsets.all(1),
 decoration: BoxDecoration(
 color: Theme.of(context).colorScheme.surface,
 boxShadow: [
 BoxShadow(
 color: Colors.black.withOpacity(0.1),
 blurRadius: 4,
 offset: const Offset(0, 2),
 ),
 ],
 ),
 child: Column(
 children: [
 // Champ de recherche
 TextField(
 controller: _searchController,
 autofocus: true,
 decoration: InputDecoration(
 hintText: 'Rechercher des employés, commandes, produits...',
 prefixIcon: const Icon(Icons.search),
 suffixIcon: _searchController.text.isNotEmpty
 ? IconButton(
 icon: const Icon(Icons.clear),
 onPressed: () {
 _searchController.clear();
 setState(() {
 _suggestions.clear();
 });
},
 )
 : null,
 border: OutlineInputBorder(
 borderRadius: const Borderconst Radius.circular(1),
 ),
 filled: true,
 fillColor: Colors.white,
 ),
 onSubmitted: (_) => _performSearch(),
 ),
 
 // Suggestions
 if (_suggestions.isNotEmpty) .{..[
 const SizedBox(height: 8),
 Container(
 height: 40,
 child: ListView.builder(
 scrollDirection: Axis.horizontal,
 itemCount: _suggestions.length,
 itemBuilder: (context, index) {
 final suggestion = _suggestions[index];
 return Padding(
 padding: const EdgeInsets.only(right: 8),
 child: ActionChip(
 label: Text(suggestion),
 onPressed: () => _onSearchTapped(suggestion),
 backgroundColor: Colors.grey[100],
 ),
 );
},
 ),
 ),
 ],
 
 // Filtres par type
 if (_isSearching || _searchResults.isNotEmpty) .{..[
 const SizedBox(height: 12),
 _buildTypeFilters(),
 ],
 ],
 ),
 ),
 
 // Contenu principal
 Expanded(
 child: _buildContent(),
 ),
 ],
 ),
 );
 }

 Widget _buildTypeFilters() {
 final types = [
 {'value': 'all', 'label': 'Tous'},
 {'value': 'employee', 'label': 'Employés'},
 {'value': 'order', 'label': 'Commandes'},
 {'value': 'product', 'label': 'Produits'},
 {'value': 'supplier', 'label': 'Fournisseurs'},
 {'value': 'leave_request', 'label': 'Congés'},
 {'value': 'payslip', 'label': 'Paies'},
 {'value': 'performance_review', 'label': 'Évaluations'},
 ];

 return SingleChildScrollView(
 scrollDirection: Axis.horizontal,
 child: Row(
 children: types.map((type) {
 final isSelected = _selectedType == type['value'];
 return Padding(
 padding: const EdgeInsets.only(right: 8),
 child: FilterChip(
 label: Text(type['label'] as String),
 selected: isSelected,
 onSelected: (selected) {
 if (selected) {{
 _onTypeChanged(type['value'] as String);
 }
 },
 backgroundColor: Colors.white,
 selectedColor: Theme.of(context).colorScheme.primary,
 checkmarkColor: Colors.white,
 ),
 );
 }).toList(),
 ),
 );
 }

 Widget _buildContent() {
 if (_isSearching) {{
 return _buildSearchSuggestions();
}

 if (_isLoading) {{
 return const Center(
 child: CircularProgressIndicator(),
 );
}

 if (_error.isNotEmpty) {{
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.error_outline,
 size: 64,
 color: Colors.grey[400],
 ),
 const SizedBox(height: 16),
 Text(
 _error,
 style: const TextStyle(
 fontSize: 16,
 color: Colors.grey[600],
 ),
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: 16),
 ElevatedButton(
 onPressed: _performSearch,
 child: const Text('Réessayer'),
 ),
 ],
 ),
 );
}

 if (_searchResults.isEmpty) {{
 return _buildEmptyState();
}

 return Column(
 children: [
 // En-tête des résultats
 Container(
 padding: const EdgeInsets.symmetric(1),
 color: Colors.grey[50],
 child: Row(
 children: [
 Text(
 '${_searchResults.length} résultat${_searchResults.length > 1 ? 's' : ''}',
 style: const TextStyle(
 fontSize: 14,
 color: Colors.grey[600],
 fontWeight: FontWeight.w500,
 ),
 ),
 const Spacer(),
 if (_filters != null)
 A{ctionChip(
 label: const Text('Filtres actifs'),
 avatar: const Icon(Icons.filter_list, size: 16),
 onPressed: _showFilters,
 backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
 ),
 ],
 ),
 ),
 
 // Liste des résultats
 Expanded(
 child: ListView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.all(1),
 itemCount: _searchResults.length + (_hasMore ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == _searchResults.length) {{
 return const Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: CircularProgressIndicator(),
 ),
 );
 }

 final result = _searchResults[index];
 return SearchResultItem(
 result: result,
 onTap: () => _onResultTapped(result),
 );
},
 ),
 ),
 ],
 );
 }

 Widget _buildSearchSuggestions() {
 return SingleChildScrollView(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Historique de recherche
 if (_searchHistory.isNotEmpty) .{..[
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 'Recherches récentes',
 style: Theme.of(context).textTheme.titleMedium,
 ),
 TextButton(
 onPressed: () async {
 await _searchService.clearSearchHistory();
 setState(() {
 _searchHistory.clear();
 });
 },
 child: const Text('Effacer'),
 ),
 ],
 ),
 const SizedBox(height: 8),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: _searchHistory.map((query) {
 return ActionChip(
 label: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 const Icon(Icons.history, size: 16),
 const SizedBox(width: 4),
 Text(query),
 ],
 ),
 onPressed: () => _onSearchTapped(query),
 backgroundColor: Colors.grey[100],
 );
 }).toList(),
 ),
 const SizedBox(height: 24),
 ],
 
 // Recherches populaires
 if (_popularSearches.isNotEmpty) .{..[
 Text(
 'Recherches populaires',
 style: Theme.of(context).textTheme.titleMedium,
 ),
 const SizedBox(height: 8),
 Wrap(
 spacing: 8,
 runSpacing: 8,
 children: _popularSearches.map((query) {
 return ActionChip(
 label: Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 const Icon(Icons.trending_up, size: 16),
 const SizedBox(width: 4),
 Text(query),
 ],
 ),
 onPressed: () => _onSearchTapped(query),
 backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
 );
 }).toList(),
 ),
 ],
 ],
 ),
 );
 }

 Widget _buildEmptyState() {
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(
 Icons.search_off,
 size: 64,
 color: Colors.grey[400],
 ),
 const SizedBox(height: 16),
 Text(
 'Aucun résultat trouvé',
 style: const TextStyle(
 fontSize: 18,
 color: Colors.grey[600],
 fontWeight: FontWeight.w500,
 ),
 ),
 const SizedBox(height: 8),
 Text(
 'Essayez avec d\'autres mots-clés ou modifiez les filtres',
 style: const TextStyle(
 fontSize: 14,
 color: Colors.grey[500],
 ),
 textAlign: TextAlign.center,
 ),
 ],
 ),
 );
 }

 void _onResultTapped(SearchResult result) {
 // TODO: Naviguer vers la page appropriée en fonction du type de résultat
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text('Navigation vers: ${result.title} (${result.type})'),
 action: SnackBarAction(
 label: 'OK',
 onPressed: () {},
 ),
 ),
 );
 }
}

// Service API temporaire pour la démonstration
class ApiService {
 // Implémentation temporaire
;
