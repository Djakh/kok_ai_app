import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';
import 'package:kok_ai_app/features/tree_registration/domain/repositories/tree_repository.dart';
import 'package:kok_ai_app/injection_container.dart';
import 'package:kok_ai_app/router.dart';

class TreeListPage extends StatefulWidget {
  const TreeListPage({super.key});
  @override
  State<TreeListPage> createState() => _TreeListPageState();
}

class _TreeListPageState extends State<TreeListPage> {
  final TreeRepository _repository = sl();
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _debounce;
  List<TreeRecord> _trees = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _cursor;
  String? _error;
  String _sort = 'newest';
  GeoCoordinate? _sortCoordinate;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 300 && _hasMore && !_loadingMore) {
      _load(reset: false);
    }
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _cursor = null;
      });
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      final page = await _repository.getTrees(
        TreeQuery(
          cursor: reset ? null : _cursor,
          limit: 20,
          search: _search.text.trim(),
          sort: _sort,
          coordinate: _sortCoordinate,
        ),
      );
      if (!mounted) return;
      setState(() {
        _trees = reset ? page.items : [..._trees, ...page.items];
        _cursor = page.nextCursor;
        _hasMore = page.hasMore;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'We could not load your trees. Check your connection and try again.';
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _load(reset: true),
    );
  }

  Future<void> _selectSort(String value) async {
    if (value != 'nearest') {
      setState(() {
        _sort = value;
        _sortCoordinate = null;
      });
      await _load(reset: true);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required for nearest sort.')),
      );
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _sort = value;
      _sortCoordinate = GeoCoordinate(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
    await _load(reset: true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Trees', style: TextStyle(fontWeight: FontWeight.w900)),
          Text(
            'Registered evidence',
            style: TextStyle(
              fontSize: 12,
              color: KokTokens.inkMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _load(reset: true),
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: _onSearch,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search species or nickname',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: 'Sort trees',
                icon: const Icon(Icons.sort_rounded),
                initialValue: _sort,
                onSelected: _selectSort,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'newest', child: Text('Newest')),
                  PopupMenuItem(value: 'nearest', child: Text('Nearest')),
                  PopupMenuItem(
                    value: 'last_scanned',
                    child: Text('Last scanned'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: _body()),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.push(registerTreeRoute),
      backgroundColor: KokTokens.forest,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add tree'),
    ),
  );

  Widget _body() {
    if (_loading) return const _TreeListSkeleton();
    if (_error != null && _trees.isEmpty) {
      return _StateView(
        icon: Icons.cloud_off_outlined,
        title: 'Trees unavailable',
        message: _error!,
        actionLabel: 'Retry',
        onAction: () => _load(reset: true),
      );
    }
    if (_trees.isEmpty) {
      return _StateView(
        icon: Icons.park_outlined,
        title: _search.text.isEmpty
            ? 'No registered trees yet'
            : 'No matching trees',
        message: _search.text.isEmpty
            ? 'Register your first real tree to build a verified collection.'
            : 'Try another species name or clear the search.',
        actionLabel: _search.text.isEmpty ? 'Register a tree' : 'Clear search',
        onAction: _search.text.isEmpty
            ? () => context.push(registerTreeRoute)
            : () {
                _search.clear();
                _load(reset: true);
              },
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
        itemCount: _trees.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == _trees.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _TreeCard(tree: _trees[index]);
        },
      ),
    );
  }
}

class _TreeCard extends StatelessWidget {
  const _TreeCard({required this.tree});
  final TreeRecord tree;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: () => context.push('/app/tree/${tree.id}'),
      borderRadius: BorderRadius.circular(KokTokens.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Image(path: tree.primaryImageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tree.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (tree.scientificName != null)
                    Text(
                      tree.scientificName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: KokTokens.inkMuted,
                      ),
                    ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      _MetaChip(
                        icon: Icons.calendar_today_outlined,
                        label: _date(tree.registeredAt),
                      ),
                      _MetaChip(
                        icon: Icons.location_on_outlined,
                        label:
                            '±${tree.location.horizontalAccuracyMeters.toStringAsFixed(1)} m',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tree.identificationSource == 'user_confirmed_ai'
                        ? 'AI suggested · user confirmed'
                        : tree.identificationSource == 'user_corrected'
                        ? 'User corrected'
                        : 'Identification uncertain',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: KokTokens.inkMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: KokTokens.inkMuted),
          ],
        ),
      ),
    ),
  );
}

class _Image extends StatelessWidget {
  const _Image({this.path});
  final String? path;

  @override
  Widget build(BuildContext context) {
    Widget image = const Icon(
      Icons.park_rounded,
      size: 34,
      color: KokTokens.leaf,
    );
    if (path?.startsWith('http') == true) {
      image = Image.network(
        path!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.park_rounded, color: KokTokens.leaf),
      );
    } else if (path?.isNotEmpty == true) {
      image = Image.file(
        File(path!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.park_rounded, color: KokTokens.leaf),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: KokTokens.surfaceMuted,
        child: SizedBox(width: 82, height: 94, child: Center(child: image)),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: KokTokens.surfaceMuted,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: KokTokens.inkMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: KokTokens.inkMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _TreeListSkeleton extends StatelessWidget {
  const _TreeListSkeleton();
  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 6,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, _) => Container(
      height: 120,
      decoration: BoxDecoration(
        color: KokTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(icon, size: 54, color: KokTokens.leaf),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: KokTokens.inkMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    ),
  );
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
