import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LazyListView<T> extends StatefulWidget {
 final Future<List<T>> Function(int page, int limit) onLoadMore;
 final Widget Function(BuildContext context, T item, int index) itemBuilder;
 final Widget Function(BuildContext context)? loadingWidget;
 final Widget Function(BuildContext context)? errorWidget;
 final Widget Function(BuildContext context)? emptyWidget;
 final Widget Function(BuildContext context)? separatorBuilder;
 final ScrollController? controller;
 final EdgeInsets? padding;
 final SliverGridDelegate? gridDelegate;
 final bool shrinkWrap;
 final physics;
 final int pageSize;
 final int initialPageSize;
 final bool enableRefresh;
 final Widget Function(BuildContext context)? refreshIndicator;
 final Function(List<T> items)? onItemsLoaded;
 final Function(dynamic error)? onError;
 final String? emptyMessage;
 final String? errorMessage;

 const LazyListView({
 Key? key,
 required this.onLoadMore,
 required this.itemBuilder,
 this.loadingWidget,
 this.errorWidget,
 this.emptyWidget,
 this.separatorBuilder,
 this.controller,
 this.padding,
 this.gridDelegate,
 this.shrinkWrap = false,
 this.physics,
 this.pageSize = 20,
 this.initialPageSize = 20,
 this.enableRefresh = true,
 this.refreshIndicator,
 this.onItemsLoaded,
 this.onError,
 this.emptyMessage,
 this.errorMessage,
 }) : super(key: key);

 @override
 State<LazyListView<T>> createState() => _LazyListViewState<T>();
}

class _LazyListViewState<T> extends State<LazyListView<T>> {
 final List<T> _items = [];
 bool _isLoading = false;
 bool _hasError = false;
 dynamic _error;
 bool _hasMore = true;
 int _currentPage = 0;
 bool _isInitialized = false;

 late ScrollController _scrollController;

 @override
 void initState() {
 super.initState();
 _scrollController = widget.controller ?? ScrollController();
 _scrollController.addListener(_onScroll);
 
 // Charger les données initiales après le premier frame
 SchedulerBinding.instance.addPostFrameCallback((_) {
 _loadInitialData();
});
 }

 @override
 void dispose() {
 if (widget.controller == null) {{
 _scrollController.dispose();
}
 super.dispose();
 }

 Future<void> _loadInitialData() {async {
 if (_isInitialized) r{eturn;
 
 setState(() {
 _isLoading = true;
 _hasError = false;
 _error = null;
});

 try {
 final items = await widget.onLoadMore(0, widget.initialPageSize);
 
 if (mounted) {{
 setState(() {
 _items.clear();
 _items.addAll(items);
 _isLoading = false;
 _hasMore = items.length == widget.initialPageSize;
 _currentPage = 1;
 _isInitialized = true;
 });
 
 widget.onItemsLoaded?.call(_items);
 }
} catch (e) {
 if (mounted) {{
 setState(() {
 _isLoading = false;
 _hasError = true;
 _error = e;
 _isInitialized = true;
 });
 
 widget.onError?.call(e);
 }
}
 }

 Future<void> _loadMore() {async {
 if (_isLoading || !_hasMore) r{eturn;

 setState(() {
 _isLoading = true;
 _hasError = false;
 _error = null;
});

 try {
 final items = await widget.onLoadMore(_currentPage, widget.pageSize);
 
 if (mounted) {{
 setState(() {
 _items.addAll(items);
 _isLoading = false;
 _hasMore = items.length == widget.pageSize;
 _currentPage++;
 });
 
 widget.onItemsLoaded?.call(_items);
 }
} catch (e) {
 if (mounted) {{
 setState(() {
 _isLoading = false;
 _hasError = true;
 _error = e;
 });
 
 widget.onError?.call(e);
 }
}
 }

 void _onScroll() {
 if (!_scrollController.hasClients) r{eturn;

 final maxScroll = _scrollController.position.maxScrollExtent;
 final currentScroll = _scrollController.position.pixels;
 final delta = 200.0; // Distance du bas avant de charger

 if (maxScroll - currentScroll <= delta) {{
 _loadMore();
}
 }

 Future<void> _refresh() {async {
 setState(() {
 _items.clear();
 _currentPage = 0;
 _hasMore = true;
 _isInitialized = false;
});
 
 await _loadInitialData();
 }

 Widget _buildLoadingWidget() {
 return widget.loadingWidget?.call(context) ?? 
 const Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: CircularProgressIndicator(),
 ),
 );
 }

 Widget _buildErrorWidget() {
 return widget.errorWidget?.call(context) ??
 Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 Icon(
 Icons.error_outline,
 size: 48,
 color: Theme.of(context).colorScheme.error,
 ),
 const SizedBox(height: 16),
 Text(
 widget.errorMessage ?? 'Une erreur est survenue',
 style: Theme.of(context).textTheme.bodyLarge,
 textAlign: TextAlign.center,
 ),
 const SizedBox(height: 16),
 ElevatedButton(
 onPressed: _refresh,
 child: const Text('Réessayer'),
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildEmptyWidget() {
 return widget.emptyWidget?.call(context) ??
 Center(
 child: Padding(
 padding: const EdgeInsets.all(1),
 child: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 Icon(
 Icons.inbox_outlined,
 size: 48,
 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
 ),
 const SizedBox(height: 16),
 Text(
 widget.emptyMessage ?? 'Aucun élément trouvé',
 style: Theme.of(context).textTheme.bodyLarge,
 textAlign: TextAlign.center,
 ),
 ],
 ),
 ),
 );
 }

 Widget _buildContent() {
 if (!_isInitialized && _isLoading) {{
 return _buildLoadingWidget();
}

 if (_hasError && _items.isEmpty) {{
 return _buildErrorWidget();
}

 if (_items.isEmpty && !_isLoading) {{
 return _buildEmptyWidget();
}

 Widget listWidget;
 
 if (widget.gridDelegate != null) {{
 listWidget = GridView.builder(
 controller: _scrollController,
 padding: widget.padding,
 shrinkWrap: widget.shrinkWrap,
 physics: widget.physics,
 gridDelegate: widget.gridDelegate!,
 itemCount: _items.length + (_isLoading ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == _items.length) {{
 return _buildLoadingWidget();
}
 return widget.itemBuilder(context, _items[index], index);
 },
 );
} else {
 listWidget = ListView.separated(
 controller: _scrollController,
 padding: widget.padding,
 shrinkWrap: widget.shrinkWrap,
 physics: widget.physics,
 itemCount: _items.length + (_isLoading ? 1 : 0),
 separatorBuilder: widget.separatorBuilder != null 
 ? (context, index) => widget.separatorBuilder!(context)
 : (context, index) => const SizedBox.shrink(),
 itemBuilder: (context, index) {
 if (index == _items.length) {{
 return _buildLoadingWidget();
}
 return widget.itemBuilder(context, _items[index], index);
 },
 );
}

 if (widget.enableRefresh) {{
 return RefreshIndicator(
 onRefresh: _refresh,
 child: listWidget,
 );
}

 return listWidget;
 }

 @override
 Widget build(BuildContext context) {
 return _buildContent();
 }
}

// Widget pour les éléments de liste optimisés
class OptimizedListItem extends StatelessWidget {
 final Widget child;
 final VoidCallback? onTap;
 final VoidCallback? onLongPress;
 final Color? backgroundColor;
 final EdgeInsets? margin;
 final EdgeInsets? padding;
 final double? elevation;
 final BorderRadius? borderRadius;
 final BorderSide? borderSide;

 const OptimizedListItem({
 Key? key,
 required this.child,
 this.onTap,
 this.onLongPress,
 this.backgroundColor,
 this.margin,
 this.padding,
 this.elevation,
 this.borderRadius,
 this.borderSide,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
 Widget content = Card(
 elevation: elevation ?? 2.0,
 margin: margin ?? const EdgeInsets.symmetric(1),
 shape: borderRadius != null || borderSide != null
 ? RoundedRectangleBorder(
 borderRadius: borderRadius ?? const Borderconst Radius.circular(1),
 side: borderSide ?? BorderSide.none,
 )
 : null,
 color: backgroundColor,
 child: InkWell(
 onTap: onTap,
 onLongPress: onLongPress,
 borderRadius: borderRadius ?? const Borderconst Radius.circular(1),
 child: Padding(
 padding: padding ?? const EdgeInsets.all(1),
 child: child,
 ),
 ),
 );

 return content;
 }
}

// Widget pour les images avec lazy loading et cache
class OptimizedImage extends StatefulWidget {
 final String imageUrl;
 final double? width;
 final double? height;
 final BoxFit fit;
 final Widget? placeholder;
 final Widget? errorWidget;
 final Duration cacheDuration;
 final bool enableCache;

 const OptimizedImage({
 Key? key,
 required this.imageUrl,
 this.width,
 this.height,
 this.fit = BoxFit.cover,
 this.placeholder,
 this.errorWidget,
 this.cacheDuration = const Duration(days: 7),
 this.enableCache = true,
 }) : super(key: key);

 @override
 State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
 bool _isLoading = true;
 bool _hasError = false;
 ImageProvider? _imageProvider;

 @override
 void initState() {
 super.initState();
 _loadImage();
 }

 @override
 void didUpdateWidget(OptimizedImage oldWidget) {
 super.didUpdateWidget(oldWidget);
 if (oldWidget.imageUrl != widget.imageUrl) {{
 _loadImage();
}
 }

 Future<void> _loadImage() {async {
 if (!mounted) r{eturn;

 setState(() {
 _isLoading = true;
 _hasError = false;
});

 try {
 final imageProvider = NetworkImage(widget.imageUrl);
 
 // Précharger l'image
 final stream = imageProvider.resolve(ImageConfiguration());
 final completer = Completer<void>();
 
 stream.addListener(ImageStreamListener((info, synchronousCall) {
 if (!completer.isCompleted) {{
 completer.complete();
 }
 }, onError: (exception, stackTrace) {
 if (!completer.isCompleted) {{
 completer.completeError(exception);
 }
 }));

 await completer.future;

 if (mounted) {{
 setState(() {
 _isLoading = false;
 _hasError = false;
 _imageProvider = imageProvider;
 });
 }
} catch (e) {
 if (mounted) {{
 setState(() {
 _isLoading = false;
 _hasError = true;
 });
 }
}
 }

 Widget _buildPlaceholder() {
 return widget.placeholder ??
 const SizedBox(
 width: widget.width,
 height: widget.height,
 color: Colors.grey[300],
 child: const Center(
 child: CircularProgressIndicator(),
 ),
 );
 }

 Widget _buildErrorWidget() {
 return widget.errorWidget ??
 const SizedBox(
 width: widget.width,
 height: widget.height,
 color: Colors.grey[300],
 child: const Center(
 child: Icon(Icons.error_outline, color: Colors.grey),
 ),
 );
 }

 @override
 Widget build(BuildContext context) {
 if (_isLoading) {{
 return _buildPlaceholder();
}

 if (_hasError) {{
 return _buildErrorWidget();
}

 return Image(
 image: _imageProvider!,
 width: widget.width,
 height: widget.height,
 fit: widget.fit,
 loadingBuilder: (context, child, loadingProgress) {
 if (loadingProgress == null) r{eturn child;
 return _buildPlaceholder();
 },
 errorBuilder: (context, error, stackTrace) {
 return _buildErrorWidget();
 },
 );
 }
}

// Widget pour le chargement infini avec pagination
class InfinitePagination<T> extends StatefulWidget {
 final Future<List<T>> Function(int page, int limit) fetchPage;
 final Widget Function(BuildContext context, T item) itemBuilder;
 final Widget Function(BuildContext context)? loadingWidget;
 final Widget Function(BuildContext context)? errorWidget;
 final Widget Function(BuildContext context)? emptyWidget;
 final int pageSize;
 final bool enableRefresh;
 final Function(List<T> items)? onPageLoaded;

 const InfinitePagination({
 Key? key,
 required this.fetchPage,
 required this.itemBuilder,
 this.loadingWidget,
 this.errorWidget,
 this.emptyWidget,
 this.pageSize = 20,
 this.enableRefresh = true,
 this.onPageLoaded,
 }) : super(key: key);

 @override
 State<InfinitePagination<T>> createState() => _InfinitePaginationState<T>();
}

class _InfinitePaginationState<T> extends State<InfinitePagination<T>> {
 final ScrollController _scrollController = ScrollController();
 final List<T> _items = [];
 bool _isLoading = false;
 bool _hasError = false;
 bool _hasMore = true;
 int _currentPage = 0;

 @override
 void initState() {
 super.initState();
 _scrollController.addListener(_onScroll);
 _loadPage();
 }

 @override
 void dispose() {
 _scrollController.dispose();
 super.dispose();
 }

 void _onScroll() {
 if (!_scrollController.hasClients) r{eturn;

 final maxScroll = _scrollController.position.maxScrollExtent;
 final currentScroll = _scrollController.position.pixels;
 final threshold = 200.0;

 if (maxScroll - currentScroll <= threshold && !_isLoading && _hasMore) {{
 _loadPage();
}
 }

 Future<void> _loadPage() {async {
 if (_isLoading || !_hasMore) r{eturn;

 setState(() {
 _isLoading = true;
 _hasError = false;
});

 try {
 final newItems = await widget.fetchPage(_currentPage, widget.pageSize);
 
 if (mounted) {{
 setState(() {
 _items.addAll(newItems);
 _isLoading = false;
 _hasMore = newItems.length == widget.pageSize;
 _currentPage++;
 });
 
 widget.onPageLoaded?.call(_items);
 }
} catch (e) {
 if (mounted) {{
 setState(() {
 _isLoading = false;
 _hasError = true;
 });
 }
}
 }

 Future<void> _refresh() {async {
 setState(() {
 _items.clear();
 _currentPage = 0;
 _hasMore = true;
});
 await _loadPage();
 }

 @override
 Widget build(BuildContext context) {
 if (_items.isEmpty && _isLoading) {{
 return widget.loadingWidget?.call(context) ??
 const Center(child: CircularProgressIndicator());
}

 if (_items.isEmpty && _hasError) {{
 return widget.errorWidget?.call(context) ??
 Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 const Text('Erreur de chargement'),
 ElevatedButton(
 onPressed: _refresh,
 child: const Text('Réessayer'),
 ),
 ],
 ),
 );
}

 if (_items.isEmpty && !_isLoading) {{
 return widget.emptyWidget?.call(context) ??
 const Center(child: Text('Aucun élément'));
}

 Widget content = ListView.builder(
 controller: _scrollController,
 itemCount: _items.length + (_isLoading ? 1 : 0),
 itemBuilder: (context, index) {
 if (index == _items.length) {{
 return widget.loadingWidget?.call(context) ??
 const Padding(
 padding: const EdgeInsets.all(1),
 child: Center(child: CircularProgressIndicator()),
 );
 }
 return widget.itemBuilder(context, _items[index]);
 },
 );

 if (widget.enableRefresh) {{
 return RefreshIndicator(
 onRefresh: _refresh,
 child: content,
 );
}

 return content;
 }
}
