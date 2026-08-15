import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';
import 'package:kok_ai_app/core/network/api_config.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';
import 'package:kok_ai_app/features/tree_registration/domain/repositories/tree_repository.dart';
import 'package:kok_ai_app/injection_container.dart';
import 'package:kok_ai_app/router.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  final TreeRepository _repository = sl();
  late Future<PaginatedTrees> _trees;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _trees = _repository.getTrees(const TreeQuery(limit: 5));
  }

  Future<void> _refresh() async {
    setState(_load);
    await _trees;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: KokTokens.forest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: KokTokens.lime,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KOK.AI',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .4,
                              ),
                            ),
                            Text(
                              'Evidence for every tree',
                              style: TextStyle(color: KokTokens.inkMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push(socialRoute),
                        tooltip: 'Community',
                        icon: const Icon(Icons.forum_outlined),
                      ),
                      IconButton(
                        onPressed: () => context.push(notificationsRoute),
                        tooltip: 'Notifications',
                        icon: const Icon(Icons.notifications_none_rounded),
                      ),
                      IconButton(
                        onPressed: _refresh,
                        tooltip: 'Refresh',
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  if (ApiConfig.useFixtures) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: KokTokens.warningContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.science_outlined,
                            size: 18,
                            color: KokTokens.warning,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Demo mode · local fixtures, no AI provider calls',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _HeroCard(onRegister: () => context.push(registerTreeRoute)),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Text(
                        'Recently registered',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go(treesRoute),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FutureBuilder<PaginatedTrees>(
              future: _trees,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SliverToBoxAdapter(child: _HomeSkeleton());
                }
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: _HomeError(onRetry: () => setState(_load)),
                  );
                }
                final trees = snapshot.data?.items ?? const <TreeRecord>[];
                if (trees.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _HomeEmpty(
                      onRegister: () => context.push(registerTreeRoute),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  sliver: SliverList.separated(
                    itemCount: trees.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _RecentTreeCard(tree: trees[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onRegister});
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: KokTokens.forest,
      borderRadius: BorderRadius.circular(28),
    ),
    padding: const EdgeInsets.all(22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'FIELD REGISTRATION',
            style: TextStyle(
              color: KokTokens.lime,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Turn a real tree into trusted data.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Guided photos · measured GPS accuracy · AI-assisted review',
          style: TextStyle(color: KokTokens.forestContainer, height: 1.4),
        ),
        const SizedBox(height: 22),
        ElevatedButton.icon(
          onPressed: onRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: KokTokens.lime,
            foregroundColor: KokTokens.forest,
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Register a tree'),
        ),
      ],
    ),
  );
}

class _RecentTreeCard extends StatelessWidget {
  const _RecentTreeCard({required this.tree});
  final TreeRecord tree;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(KokTokens.radiusMedium),
      onTap: () => context.push('/app/tree/${tree.id}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _TreeThumbnail(path: tree.primaryImageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tree.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
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
                  const SizedBox(height: 4),
                  Text(
                    'Recorded ±${tree.location.horizontalAccuracyMeters.toStringAsFixed(1)} m · ${_date(tree.registeredAt)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: KokTokens.inkMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    ),
  );
}

class _TreeThumbnail extends StatelessWidget {
  const _TreeThumbnail({this.path});
  final String? path;
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (path == null || path!.isEmpty) {
      child = const Icon(Icons.park_rounded, color: KokTokens.leaf, size: 30);
    } else if (path!.startsWith('http')) {
      child = Image.network(
        path!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.park_rounded, color: KokTokens.leaf),
      );
    } else {
      child = Image.file(
        File(path!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.park_rounded, color: KokTokens.leaf),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: KokTokens.surfaceMuted,
        child: SizedBox(width: 58, height: 58, child: Center(child: child)),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(20),
    child: Column(
      children: [
        _SkeletonLine(),
        SizedBox(height: 10),
        _SkeletonLine(),
        SizedBox(height: 10),
        _SkeletonLine(),
      ],
    ),
  );
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine();
  @override
  Widget build(BuildContext context) => Container(
    height: 82,
    decoration: BoxDecoration(
      color: KokTokens.surfaceMuted,
      borderRadius: BorderRadius.circular(16),
    ),
  );
}

class _HomeEmpty extends StatelessWidget {
  const _HomeEmpty({required this.onRegister});
  final VoidCallback onRegister;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.park_outlined, size: 48, color: KokTokens.leaf),
            const SizedBox(height: 12),
            Text(
              'Your tree collection starts here',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Register a real tree to see it here and on your map.',
              textAlign: TextAlign.center,
              style: TextStyle(color: KokTokens.inkMuted),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRegister,
              child: const Text('Register first tree'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: KokTokens.warning,
              size: 40,
            ),
            const SizedBox(height: 10),
            const Text('Trees could not be loaded. Check your connection.'),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    ),
  );
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
