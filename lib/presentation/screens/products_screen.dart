import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/product.dart';
import '../../core/models/user.dart';
import '../../core/services/product_service.dart';
import '../../core/services/api_service.dart';
import '../../presentation/widgets/custom_button.dart';
import '../../presentation/widgets/custom_text_field.dart';
import '../../presentation/widgets/loading_overlay.dart';

class ProductsScreen extends StatefulWidget {
 final User? currentUser;

 const ProductsScreen({
 Key? key,
 this.currentUser,
 }) : super(key: key);

 @override
 State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
 final ProductService _productService = ProductService(ApiService());
 final _searchController = TextEditingController();
 final _scrollController = ScrollController();
 
 bool _isLoading = false;
 bool _isLoadingMore = false;
 bool _hasMore = true;
 
 List<Product> _products = [];
 List<Product> _filteredProducts = [];
 String _searchQuery = '';
 String? _selectedCategory;
 bool _sortByPrice = false;
 bool _sortByStock = false;
 bool _showOutOfStock = true;
 
 int _currentPage = 1;
 final int _pageSize = 20;

 @override
 void initState() {
 super.initState();
 _loadProducts();
 _scrollController.addListener(_onScroll);
 }

 @override
 void dispose() {
 _searchController.dispose();
 _scrollController.dispose();
 super.dispose();
 }

 void _onScroll() {
 if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {{
 _loadMoreProducts();
}
 }

 Future<void> _loadProducts({bool refresh = false}) {async {
 if (refresh) {{
 setState(() {
 _isLoading = true;
 _currentPage = 1;
 _hasMore = true;
 _products.clear();
 });
} else {
 setState(() {
 _isLoading = true;
 });
}

 try {
 final response = await _productService.getProducts(
 page: _currentPage,
 limit: _pageSize,
 search: _searchQuery.isEmpty ? null : _searchQuery,
 category: _selectedCategory,
 sortBy: _sortByPrice ? 'price' : _sortByStock ? 'stock' : 'name',
 sortOrder: 'asc',
 );

 if (response.isSuccess && response.data != null) {{
 setState(() {
 if (refresh) {{
 _products = response.data!;
} else {
 _products.addAll(response.data!);
}
 _filteredProducts = _filterProducts(_products);
 _hasMore = response.data!.length == _pageSize;
 _currentPage++;
 });
 } else {
 _showErrorSnackBar(response.errorMessage ?? 'Erreur lors du chargement des produits');
 }
} catch (e) {
 _showErrorSnackBar('Erreur réseau: $e');
} finally {
 setState(() {
 _isLoading = false;
 });
}
 }

 Future<void> _loadMoreProducts() {async {
 if (_isLoadingMore || !_hasMore) r{eturn;

 setState(() {
 _isLoadingMore = true;
});

 try {
 final response = await _productService.getProducts(
 page: _currentPage,
 limit: _pageSize,
 search: _searchQuery.isEmpty ? null : _searchQuery,
 category: _selectedCategory,
 sortBy: _sortByPrice ? 'price' : _sortByStock ? 'stock' : 'name',
 sortOrder: 'asc',
 );

 if (response.isSuccess && response.data != null) {{
 setState(() {
 _products.addAll(response.data!);
 _filteredProducts = _filterProducts(_products);
 _hasMore = response.data!.length == _pageSize;
 _currentPage++;
 });
 }
} catch (e) {
 _showErrorSnackBar('Erreur réseau: $e');
} finally {
 setState(() {
 _isLoadingMore = false;
 });
}
 }

 List<Product> _filterProducts(List<Product> products) {
 var filtered = products;

 // Filtrer par recherche
 if (_searchQuery.isNotEmpty) {{
 filtered = filtered.where((product) =>
 product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
 (product.sku?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
 product.description.toLowerCase().contains(_searchQuery.toLowerCase())
 ).toList();
}

 // Filtrer par catégorie
 if (_selectedCategory != null) {{
 filtered = filtered.where((product) => product.category == _selectedCategory).toList();
}

 // Filtrer par stock
 if (!_showOutOfStock) {{
 filtered = filtered.where((product) => product.stock > 0).toList();
}

 // Trier
 if (_sortByPrice) {{
 filtered.sort((a, b) => a.price.compareTo(b.price));
} else if (_sortByStock) {{
 filtered.sort((a, b) => a.stock.compareTo(b.stock));
} else {
 filtered.sort((a, b) => a.name.compareTo(b.name));
}

 return filtered;
 }

 void _onSearchChanged(String value) {
 setState(() {
 _searchQuery = value;
 _filteredProducts = _filterProducts(_products);
});
 }

 void _onCategoryChanged(String? category) {
 setState(() {
 _selectedCategory = category;
 _filteredProducts = _filterProducts(_products);
});
 }

 void _onSortChanged(String sortType) {
 setState(() {
 _sortByPrice = sortType == 'price';
 _sortByStock = sortType == 'stock';
 _filteredProducts = _filterProducts(_products);
});
 }

 void _toggleOutOfStock() {
 setState(() {
 _showOutOfStock = !_showOutOfStock;
 _filteredProducts = _filterProducts(_products);
});
 }

 Future<void> _deleteProduct(Product product) {async {
 final confirmed = await _showDeleteConfirmation(product);
 if (!confirmed) r{eturn;

 try {
 // TODO: Implémenter la suppression dans le service
 _showSuccessSnackBar('Suppression en cours de développement');
} catch (e) {
 _showErrorSnackBar('Erreur réseau: $e');
}
 }

 Future<bool> _showDeleteConfirmation(Product product) {async {
 final result = await showDialog<bool>(
 context: context,
 builder: (context) => AlertDialog(
 title: const Text('Confirmer la suppression'),
 content: Text('Êtes-vous sûr de vouloir supprimer le produit "${product.name}" ? Cette action est irréversible.'),
 actions: [
 TextButton(
 onPressed: () => Navigator.of(context).pop(false),
 child: const Text('Annuler'),
 ),
 TextButton(
 onPressed: () => Navigator.of(context).pop(true),
 style: TextButton.styleFrom(foregroundColor: Colors.red),
 child: const Text('Supprimer'),
 ),
 ],
 ),
 );
 return result ?? false;
 }

 void _navigateToProductForm({Product? product}) {
 // TODO: Implémenter l'écran de formulaire produit
 _showSuccessSnackBar('Formulaire produit en cours de développement');
 }

 void _showErrorSnackBar(String message) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(message),
 backgroundColor: Colors.red,
 behavior: SnackBarBehavior.floating,
 ),
 );
 }

 void _showSuccessSnackBar(String message) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(message),
 backgroundColor: Colors.green,
 behavior: SnackBarBehavior.floating,
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
 title: const Text('Gestion des produits'),
 actions: [
 IconButton(
 icon: const Icon(Icons.refresh),
 onPressed: () => _loadProducts(refresh: true),
 tooltip: 'Actualiser',
 ),
 ],
 ),
 body: Column(
 children: [
 // Filtres et recherche
 _buildFiltersSection(),
 
 // Liste des produits
 Expanded(
 child: _buildProductsList(),
 ),
 ],
 ),
 floatingActionButton: FloatingActionButton(
 onPressed: () => _navigateToProductForm(),
 child: const Icon(Icons.add),
 tooltip: 'Ajouter un produit',
 ),
 );
 }

 Widget _buildFiltersSection() {
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
 CustomTextField(
 controller: _searchController,
 label: 'Rechercher un produit',
 hintText: 'Nom, SKU, description...',
 onChanged: _onSearchChanged,
 prefixIcon: Icons.search,
 ),
 const SizedBox(height: 16),
 
 // Filtres
 Row(
 children: [
 Expanded(
 child: DropdownButtonFormField<String?>(
 value: _selectedCategory,
 decoration: const InputDecoration(
 labelText: 'Catégorie',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: [
 const DropdownMenuItem(value: null, child: Text('Toutes')),
 const DropdownMenuItem(value: 'electronics', child: Text('Électronique')),
 const DropdownMenuItem(value: 'clothing', child: Text('Vêtements')),
 const DropdownMenuItem(value: 'food', child: Text('Alimentation')),
 const DropdownMenuItem(value: 'books', child: Text('Livres')),
 const DropdownMenuItem(value: 'home', child: Text('Maison')),
 const DropdownMenuItem(value: 'sports', child: Text('Sports')),
 const DropdownMenuItem(value: 'toys', child: Text('Jouets')),
 const DropdownMenuItem(value: 'health', child: Text('Santé')),
 const DropdownMenuItem(value: 'beauty', child: Text('Beauté')),
 const DropdownMenuItem(value: 'automotive', child: Text('Automobile')),
 const DropdownMenuItem(value: 'other', child: Text('Autre')),
 ],
 onChanged: _onCategoryChanged,
 ),
 ),
 const SizedBox(width: 12),
 Expanded(
 child: DropdownButtonFormField<String>(
 value: _sortByPrice ? 'price' : _sortByStock ? 'stock' : 'name',
 decoration: const InputDecoration(
 labelText: 'Trier par',
 border: OutlineInputBorder(),
 contentPadding: const EdgeInsets.symmetric(1),
 ),
 items: const [
 DropdownMenuItem(value: 'name', child: Text('Nom')),
 DropdownMenuItem(value: 'price', child: Text('Prix')),
 DropdownMenuItem(value: 'stock', child: Text('Stock')),
 ],
 onChanged: (value) {
 if (value != null) {{
 _onSortChanged(value);
 }
 },
 ),
 ),
 ],
 ),
 const SizedBox(height: 12),
 
 // Filtre stock
 Row(
 children: [
 Checkbox(
 value: _showOutOfStock,
 onChanged: (value) => _toggleOutOfStock(),
 ),
 const Text('Afficher les produits en rupture de stock'),
 ],
 ),
 ],
 ),
 );
 }

 Widget _buildProductsList() {
 if (_isLoading && _products.isEmpty) {{
 return const Center(child: CircularProgressIndicator());
}

 if (_filteredProducts.isEmpty) {{
 return Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
 const SizedBox(height: 16),
 Text(
 'Aucun produit trouvé',
 style: const TextStyle(fontSize: 16, color: Colors.grey),
 ),
 const SizedBox(height: 8),
 Text(
 'Essayez de modifier vos filtres de recherche',
 style: const TextStyle(fontSize: 14, color: Colors.grey),
 ),
 ],
 ),
 );
}

 return RefreshIndicator(
 onRefresh: () => _loadProducts(refresh: true),
 child: GridView.builder(
 controller: _scrollController,
 padding: const EdgeInsets.all(1),
 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
 crossAxisCount: 2,
 childAspectRatio: 0.75,
 crossAxisSpacing: 16,
 mainAxisSpacing: 16,
 ),
 itemCount: _filteredProducts.length + (_hasMore ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == _filteredProducts.length && _hasMore) {{
 return const Center(child: CircularProgressIndicator());
}
 
 final product = _filteredProducts[index];
 return _buildProductCard(product);
 },
 ),
 );
 }

 Widget _buildProductCard(Product product) {
 return Card(
 elevation: 2,
 child: InkWell(
 onTap: () => _navigateToProductForm(product: product),
 borderRadius: const Borderconst Radius.circular(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Image
 Expanded(
 flex: 3,
 child: Container(
 width: double.infinity,
 decoration: BoxDecoration(
 borderRadius: const Borderconst Radius.vertical(top: const Radius.circular(12)),
 color: Colors.grey[100],
 ),
 child: product.images.isNotEmpty
 ? ClipRRect(
 borderRadius: const Borderconst Radius.vertical(top: const Radius.circular(12)),
 child: Image.network(
 product.images.first,
 fit: BoxFit.cover,
 errorBuilder: (context, error, stackTrace) {
 return const Center(
 child: Icon(Icons.image, size: 48, color: Colors.grey),
 );
},
 ),
 )
 : const Center(
 child: Icon(Icons.image, size: 48, color: Colors.grey),
 ),
 ),
 ),
 
 // Informations
 Expanded(
 flex: 2,
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 // Nom et catégorie
 Text(
 product.name,
 style: const TextStyle(
 fontWeight: FontWeight.bold,
 fontSize: 14,
 ),
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 ),
 const SizedBox(height: 2),
 Text(
 _getCategoryDisplayName(product.category),
 style: const TextStyle(
 fontSize: 12,
 color: Colors.grey[600],
 ),
 ),
 const SizedBox(height: 4),
 
 // SKU
 Text(
 'SKU: ${product.sku ?? 'N/A'}',
 style: const TextStyle(
 fontSize: 11,
 color: Colors.grey[500],
 ),
 ),
 
 const Spacer(),
 
 // Prix et stock
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Text(
 '${product.price.toStringAsFixed(2)} €',
 style: const TextStyle(
 fontWeight: FontWeight.bold,
 fontSize: 14,
 color: Colors.green,
 ),
 ),
 _buildStockBadge(product),
 ],
 ),
 ],
 ),
 ),
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildStockBadge(Product product) {
 final isInStock = product.stock > 0;
 final isLowStock = product.stock > 0 && product.stock <= 5;
 
 Color backgroundColor;
 Color textColor;
 String text;
 
 if (!isInStock) {{
 backgroundColor = Colors.red[100]!;
 textColor = Colors.red[700]!;
 text = 'Rupture';
} else if (isLowStock) {{
 backgroundColor = Colors.orange[100]!;
 textColor = Colors.orange[700]!;
 text = 'Stock faible';
} else {
 backgroundColor = Colors.green[100]!;
 textColor = Colors.green[700]!;
 text = 'En stock';
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
 fontSize: 10,
 color: textColor,
 fontWeight: FontWeight.w500,
 ),
 ),
 );
 }

 String _getCategoryDisplayName(String category) {
 switch (category) {
 case 'electronics':
 return 'Électronique';
 case 'clothing':
 return 'Vêtements';
 case 'food':
 return 'Alimentation';
 case 'books':
 return 'Livres';
 case 'home':
 return 'Maison';
 case 'sports':
 return 'Sports';
 case 'toys':
 return 'Jouets';
 case 'health':
 return 'Santé';
 case 'beauty':
 return 'Beauté';
 case 'automotive':
 return 'Automobile';
 case 'other':
 return 'Autre';
 default:
 return category;
}
 }
}
