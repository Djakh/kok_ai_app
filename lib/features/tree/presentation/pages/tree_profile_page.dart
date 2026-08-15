import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';
import 'package:kok_ai_app/features/auth/data/services/auth_api_service.dart';
import 'package:kok_ai_app/features/social/data/models/api_social_post.dart';
import 'package:kok_ai_app/features/tree/data/models/api_tree_timeline_event.dart';
import 'package:kok_ai_app/features/tree/data/services/tree_api_service.dart';
import 'package:kok_ai_app/features/tree_registration/domain/entities/tree_models.dart';
import 'package:kok_ai_app/features/tree_registration/domain/repositories/tree_repository.dart';
import 'package:kok_ai_app/features/user/data/models/api_user.dart';
import 'package:kok_ai_app/injection_container.dart';

class TreeProfilePage extends StatefulWidget {
  const TreeProfilePage({super.key, required this.treeId});
  final String treeId;

  @override
  State<TreeProfilePage> createState() => _TreeProfilePageState();
}

class _TreeProfilePageState extends State<TreeProfilePage> {
  final TreeRepository _repository = sl();
  final TreeApiService _treeApi = sl();
  late Future<_TreePageData> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future =
        Future.wait<dynamic>([
          _repository.getTree(widget.treeId),
          _repository.getTreeScans(widget.treeId),
          _treeApi.getTreeTimeline(widget.treeId),
          _treeApi.getTreePosts(widget.treeId),
          _getCurrentUser(),
        ]).then(
          (values) => _TreePageData(
            tree: values[0] as TreeRecord,
            scans: values[1] as List<TreeScan>,
            timeline: values[2] as List<ApiTreeTimelineEvent>,
            posts: values[3] as List<ApiSocialPost>,
            currentUser: values[4] as ApiUser?,
          ),
        );
  }

  Future<ApiUser?> _getCurrentUser() async {
    try {
      return await sl<AuthApiService>().getCurrentUser();
    } catch (_) {
      return null;
    }
  }

  Future<void> _editName(TreeRecord tree) async {
    final controller = TextEditingController(text: tree.displayName);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename tree'),
        content: TextField(
          controller: controller,
          maxLength: 120,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty || value == tree.displayName) return;
    await _treeApi.updateTree(tree.id, name: value);
    if (mounted) setState(_load);
  }

  Future<void> _verify(TreeRecord tree) async {
    final noteController = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify tree record'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Moderator note (optional)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, noteController.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
    noteController.dispose();
    if (note == null) return;
    await _treeApi.verifyTree(tree.id, note: note.isEmpty ? null : note);
    if (!mounted) return;
    setState(_load);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tree record verified.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FutureBuilder<_TreePageData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _DetailSkeleton();
        }
        if (snapshot.hasError || snapshot.data == null) {
          return _DetailError(
            onRetry: () => setState(_load),
            onBack: context.pop,
          );
        }
        final data = snapshot.data!;
        return _TreeDetails(
          tree: data.tree,
          scans: data.scans,
          timeline: data.timeline,
          posts: data.posts,
          canEdit: data.currentUser?.id == data.tree.ownerId,
          canVerify: const {
            'moderator',
            'admin',
          }.contains(data.currentUser?.role),
          onEdit: () => _editName(data.tree),
          onVerify: () => _verify(data.tree),
        );
      },
    ),
  );
}

class _TreePageData {
  const _TreePageData({
    required this.tree,
    required this.scans,
    required this.timeline,
    required this.posts,
    required this.currentUser,
  });
  final TreeRecord tree;
  final List<TreeScan> scans;
  final List<ApiTreeTimelineEvent> timeline;
  final List<ApiSocialPost> posts;
  final ApiUser? currentUser;
}

class _TreeDetails extends StatelessWidget {
  const _TreeDetails({
    required this.tree,
    required this.scans,
    required this.timeline,
    required this.posts,
    required this.canEdit,
    required this.canVerify,
    required this.onEdit,
    required this.onVerify,
  });
  final TreeRecord tree;
  final List<TreeScan> scans;
  final List<ApiTreeTimelineEvent> timeline;
  final List<ApiSocialPost> posts;
  final bool canEdit;
  final bool canVerify;
  final VoidCallback onEdit;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverAppBar.large(
        expandedHeight: 310,
        pinned: true,
        backgroundColor: KokTokens.forest,
        foregroundColor: Colors.white,
        actions: [
          if (canEdit)
            IconButton(
              tooltip: 'Rename tree',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          if (canVerify)
            IconButton(
              tooltip: 'Verify tree',
              onPressed: onVerify,
              icon: const Icon(Icons.verified_outlined),
            ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: _HeroImage(path: tree.primaryImageUrl),
          title: Text(
            tree.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
        sliver: SliverList.list(
          children: [
            _IdentificationCard(tree: tree),
            const SizedBox(height: 12),
            _LocationCard(tree: tree),
            if (tree.description != null) ...[
              const SizedBox(height: 12),
              _SectionCard(
                title: 'About this species',
                icon: Icons.menu_book_outlined,
                child: Text(
                  tree.description!,
                  style: const TextStyle(height: 1.5),
                ),
              ),
            ],
            if (tree.health != null) ...[
              const SizedBox(height: 12),
              _HealthCard(health: tree.health!),
            ],
            if (tree.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              _PhotoGallery(urls: tree.photoUrls),
            ],
            const SizedBox(height: 12),
            _ScanHistory(scans: scans, registeredAt: tree.registeredAt),
            if (timeline.isNotEmpty) ...[
              const SizedBox(height: 12),
              _Timeline(events: timeline),
            ],
            if (posts.isNotEmpty) ...[
              const SizedBox(height: 12),
              _TreePosts(posts: posts),
            ],
            const SizedBox(height: 12),
            const _Disclaimer(),
          ],
        ),
      ),
    ],
  );
}

class _IdentificationCard extends StatelessWidget {
  const _IdentificationCard({required this.tree});
  final TreeRecord tree;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'Identification',
    icon: Icons.auto_awesome_outlined,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tree.commonName ?? tree.displayName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (tree.scientificName != null)
          Text(
            tree.scientificName!,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: KokTokens.inkMuted,
              fontSize: 16,
            ),
          ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Chip(
              label: tree.identificationSource == 'user_corrected'
                  ? 'User corrected'
                  : tree.identificationSource == 'user_confirmed_ai'
                  ? 'User confirmed AI'
                  : 'Uncertain',
              icon: tree.identificationSource == 'user_corrected'
                  ? Icons.edit_outlined
                  : Icons.fact_check_outlined,
            ),
            if (tree.aiConfidence != null)
              _Chip(
                label: '${(tree.aiConfidence! * 100).round()}% AI confidence',
                icon: Icons.analytics_outlined,
              ),
          ],
        ),
        if (tree.aiProvider != null) ...[
          const SizedBox(height: 12),
          Text(
            'Analysis provider: ${tree.aiProvider}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: KokTokens.inkMuted),
          ),
        ],
      ],
    ),
  );
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.tree});
  final TreeRecord tree;

  @override
  Widget build(BuildContext context) {
    final location = tree.location;
    final point = LatLng(location.latitude, location.longitude);
    return _SectionCard(
      title: 'Recorded location',
      icon: Icons.location_on_outlined,
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: point, zoom: 18),
                markers: {
                  Marker(markerId: const MarkerId('tree'), position: point),
                },
                circles: {
                  Circle(
                    circleId: const CircleId('accuracy'),
                    center: point,
                    radius: location.horizontalAccuracyMeters,
                    fillColor: KokTokens.leaf.withValues(alpha: .16),
                    strokeColor: KokTokens.leaf,
                    strokeWidth: 2,
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                liteModeEnabled: Platform.isAndroid,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Value(
                  label: 'Coordinates',
                  value:
                      '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                ),
              ),
              _Value(
                label: 'Accuracy',
                value:
                    '±${location.horizontalAccuracyMeters.toStringAsFixed(1)} m',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'The circle represents recorded smartphone uncertainty, not a survey-grade boundary.',
            style: TextStyle(color: KokTokens.inkMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.health});
  final TreeHealthAssessment health;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'Optional health assessment',
    icon: Icons.health_and_safety_outlined,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(health.status, style: Theme.of(context).textTheme.titleMedium),
        if (health.summary != null) ...[
          const SizedBox(height: 6),
          Text(health.summary!),
        ],
        const SizedBox(height: 8),
        const Text(
          'Automated health information is not a professional diagnosis.',
          style: TextStyle(color: KokTokens.inkMuted, fontSize: 12),
        ),
      ],
    ),
  );
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({required this.urls});
  final List<String> urls;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'Registration photographs',
    icon: Icons.photo_library_outlined,
    child: SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 112, child: _ImageSource(path: urls[index])),
        ),
      ),
    ),
  );
}

class _ScanHistory extends StatelessWidget {
  const _ScanHistory({required this.scans, required this.registeredAt});
  final List<TreeScan> scans;
  final DateTime registeredAt;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'Scan history',
    icon: Icons.timeline_rounded,
    child: Column(
      children: [
        if (scans.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No follow-up scans yet. Choose “Same tree” during registration to add new evidence.',
              style: TextStyle(color: KokTokens.inkMuted),
            ),
          )
        else
          ...scans.map(
            (scan) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: KokTokens.forestContainer,
                child: Icon(Icons.document_scanner_outlined),
              ),
              title: Text(scan.summary ?? 'Tree scan'),
              subtitle: Text(_date(scan.scannedAt)),
            ),
          ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundColor: KokTokens.forest,
            child: Icon(Icons.park_rounded, color: Colors.white),
          ),
          title: const Text('Tree registered'),
          subtitle: Text(_date(registeredAt)),
        ),
      ],
    ),
  );
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.events});
  final List<ApiTreeTimelineEvent> events;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'Record timeline',
    icon: Icons.history_rounded,
    child: Column(
      children: events
          .map(
            (event) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.circle,
                size: 12,
                color: KokTokens.leaf,
              ),
              title: Text(_eventTitle(event.eventType)),
              subtitle: Text(
                [
                  if (event.details != null) '${event.details}',
                  if (event.createdAt != null)
                    _date(event.createdAt!.toLocal()),
                ].join(' · '),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _TreePosts extends StatelessWidget {
  const _TreePosts({required this.posts});
  final List<ApiSocialPost> posts;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'Community posts',
    icon: Icons.forum_outlined,
    child: Column(
      children: posts
          .map(
            (post) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: post.imageUrl == null
                  ? const CircleAvatar(child: Icon(Icons.chat_bubble_outline))
                  : CircleAvatar(backgroundImage: NetworkImage(post.imageUrl!)),
              title: Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: post.createdAt == null
                  ? null
                  : Text(_date(post.createdAt!.toLocal())),
            ),
          )
          .toList(),
    ),
  );
}

String _eventTitle(String value) {
  final words = value.replaceAll('_', ' ').trim();
  if (words.isEmpty) return 'Tree updated';
  return '${words.substring(0, 1).toUpperCase()}${words.substring(1)}';
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: KokTokens.surfaceMuted,
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'AI-generated species suggestions can be wrong. Confirm important identifications with a qualified specialist.',
            style: TextStyle(fontSize: 12, height: 1.4),
          ),
        ),
      ],
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: KokTokens.leaf),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: KokTokens.forestContainer,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: KokTokens.forest),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: KokTokens.forest,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _Value extends StatelessWidget {
  const _Value({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: KokTokens.inkMuted, fontSize: 11),
      ),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  );
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.path});
  final String? path;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      _ImageSource(path: path),
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xA6000000)],
          ),
        ),
      ),
    ],
  );
}

class _ImageSource extends StatelessWidget {
  const _ImageSource({this.path});
  final String? path;
  @override
  Widget build(BuildContext context) {
    if (path?.startsWith('http') == true) {
      return Image.network(
        path!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ImageFallback(),
      );
    }
    if (path?.isNotEmpty == true) {
      return Image.file(
        File(path!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ImageFallback(),
      );
    }
    return const _ImageFallback();
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();
  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: KokTokens.forest,
    child: Center(
      child: Icon(Icons.park_rounded, color: KokTokens.lime, size: 88),
    ),
  );
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry, required this.onBack});
  final VoidCallback onRetry;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 50),
            const SizedBox(height: 12),
            const Text(
              'Tree details are unavailable',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and retry.',
              style: TextStyle(color: KokTokens.inkMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            TextButton(onPressed: onBack, child: const Text('Go back')),
          ],
        ),
      ),
    ),
  );
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
