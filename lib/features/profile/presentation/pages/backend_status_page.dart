import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';
import 'package:kok_ai_app/core/network/api_config.dart';
import 'package:kok_ai_app/core/network/system_api_service.dart';
import 'package:kok_ai_app/injection_container.dart';

class BackendStatusPage extends StatefulWidget {
  const BackendStatusPage({super.key});

  @override
  State<BackendStatusPage> createState() => _BackendStatusPageState();
}

class _BackendStatusPageState extends State<BackendStatusPage> {
  late Future<_BackendStatus> _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final service = sl<SystemApiService>();
    _status =
        Future.wait([
          service.getVersion(),
          service.getHealth(),
          service.getReadiness(),
        ]).then(
          (results) => _BackendStatus(
            version: results[0],
            health: results[1],
            readiness: results[2],
          ),
        );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: context.pop,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: const Text('Backend status'),
    ),
    body: FutureBuilder<_BackendStatus>(
      future: _status,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 54),
                const SizedBox(height: 12),
                const Text('Backend diagnostics are unavailable.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(_load),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final status = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatusCard(
              title: 'API version',
              icon: Icons.info_outline_rounded,
              values: status.version,
            ),
            const SizedBox(height: 10),
            _StatusCard(
              title: 'Health',
              icon: Icons.favorite_outline_rounded,
              values: status.health,
            ),
            const SizedBox(height: 10),
            _StatusCard(
              title: 'Readiness',
              icon: Icons.task_alt_rounded,
              values: status.readiness,
            ),
            const SizedBox(height: 16),
            Text(
              'API: ${ApiConfig.baseUrl}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: KokTokens.inkMuted),
            ),
          ],
        );
      },
    ),
  );
}

class _BackendStatus {
  const _BackendStatus({
    required this.version,
    required this.health,
    required this.readiness,
  });
  final Map<String, dynamic> version;
  final Map<String, dynamic> health;
  final Map<String, dynamic> readiness;
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.icon,
    required this.values,
  });
  final String title;
  final IconData icon;
  final Map<String, dynamic> values;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: KokTokens.leaf),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const Divider(height: 24),
          ...values.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(entry.key.replaceAll('_', ' '))),
                  Flexible(
                    child: Text(
                      '${entry.value}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
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
