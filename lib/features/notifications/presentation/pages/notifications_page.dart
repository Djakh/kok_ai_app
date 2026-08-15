import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';
import 'package:kok_ai_app/features/notifications/data/models/api_notification.dart';
import 'package:kok_ai_app/features/notifications/data/services/notification_api_service.dart';
import 'package:kok_ai_app/injection_container.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _service = sl<NotificationApiService>();
  List<ApiNotification> _items = const [];
  bool _loading = true;
  bool _markingAll = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.listNotifications();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Notifications could not be loaded.';
      });
    }
  }

  Future<void> _read(ApiNotification item) async {
    if (item.isRead) return;
    final index = _items.indexWhere((value) => value.id == item.id);
    if (index < 0) return;
    setState(() {
      _items = [..._items]..[index] = item.copyWith(isRead: true);
    });
    try {
      await _service.readOne(item.id);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [..._items]..[index] = item;
      });
      _showError('Could not mark this notification as read.');
    }
  }

  Future<void> _readAll() async {
    if (_markingAll || !_items.any((item) => !item.isRead)) return;
    final previous = _items;
    setState(() {
      _markingAll = true;
      _items = _items.map((item) => item.copyWith(isRead: true)).toList();
    });
    try {
      await _service.readAll();
    } catch (_) {
      if (mounted) {
        setState(() => _items = previous);
        _showError('Could not mark all notifications as read.');
      }
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: context.pop,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: const Text('Notifications'),
      actions: [
        TextButton(
          onPressed: _markingAll ? null : _readAll,
          child: const Text('Read all'),
        ),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? _NotificationMessage(
            icon: Icons.cloud_off_rounded,
            title: _error!,
            action: _load,
          )
        : _items.isEmpty
        ? const _NotificationMessage(
            icon: Icons.notifications_none_rounded,
            title: 'You are all caught up',
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  color: item.isRead
                      ? KokTokens.surface
                      : KokTokens.forestContainer,
                  child: ListTile(
                    onTap: () => _read(item),
                    leading: Icon(
                      item.isRead
                          ? Icons.notifications_none_rounded
                          : Icons.notifications_active_rounded,
                      color: item.isRead
                          ? KokTokens.inkMuted
                          : KokTokens.forest,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: item.isRead
                            ? FontWeight.w600
                            : FontWeight.w800,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.body.isNotEmpty) Text(item.body),
                        if (item.createdAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _date(item.createdAt!),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
  );
}

class _NotificationMessage extends StatelessWidget {
  const _NotificationMessage({
    required this.icon,
    required this.title,
    this.action,
  });
  final IconData icon;
  final String title;
  final Future<void> Function()? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 56, color: KokTokens.leaf),
        const SizedBox(height: 12),
        Text(title),
        if (action != null) ...[
          const SizedBox(height: 12),
          ElevatedButton(onPressed: action, child: const Text('Retry')),
        ],
      ],
    ),
  );
}

String _date(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}
