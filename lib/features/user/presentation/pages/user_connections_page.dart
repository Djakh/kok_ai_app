import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';
import 'package:kok_ai_app/features/user/data/models/api_user.dart';
import 'package:kok_ai_app/features/user/data/services/user_api_service.dart';
import 'package:kok_ai_app/injection_container.dart';

class UserConnectionsPage extends StatefulWidget {
  const UserConnectionsPage({
    required this.userId,
    required this.showFollowers,
    super.key,
  });

  final String userId;
  final bool showFollowers;

  @override
  State<UserConnectionsPage> createState() => _UserConnectionsPageState();
}

class _UserConnectionsPageState extends State<UserConnectionsPage> {
  final _service = sl<UserApiService>();
  List<ApiUser> _users = const [];
  Set<String> _followingIds = const {};
  String? _myId;
  String? _error;
  bool _loading = true;
  final Set<String> _busyIds = {};

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
      final me = await _service.getMe();
      final results = await Future.wait([
        widget.showFollowers
            ? _service.getFollowers(widget.userId)
            : _service.getFollowing(widget.userId),
        _service.getFollowing(me.id),
      ]);
      if (!mounted) return;
      setState(() {
        _myId = me.id;
        _users = results[0];
        _followingIds = results[1].map((user) => user.id).toSet();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'People could not be loaded.';
      });
    }
  }

  Future<void> _toggle(ApiUser user) async {
    if (_busyIds.contains(user.id)) return;
    final wasFollowing = _followingIds.contains(user.id);
    setState(() {
      _busyIds.add(user.id);
      _followingIds = {..._followingIds};
      if (wasFollowing) {
        _followingIds.remove(user.id);
      } else {
        _followingIds.add(user.id);
      }
    });
    try {
      if (wasFollowing) {
        await _service.unfollow(user.id);
      } else {
        await _service.follow(user.id);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (wasFollowing) {
          _followingIds.add(user.id);
        } else {
          _followingIds.remove(user.id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The follow status could not be changed.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busyIds.remove(user.id));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: context.pop,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text(widget.showFollowers ? 'Followers' : 'Following'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? _Message(message: _error!, onRetry: _load)
        : _users.isEmpty
        ? _Message(
            message: widget.showFollowers
                ? 'No followers yet'
                : 'Not following anyone yet',
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = _users[index];
                final isMe = user.id == _myId;
                final following = _followingIds.contains(user.id);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: KokTokens.forestContainer,
                      backgroundImage: user.avatarUrl == null
                          ? null
                          : NetworkImage(user.avatarUrl!),
                      child: user.avatarUrl == null
                          ? Text(_initial(user.fullName ?? user.username))
                          : null,
                    ),
                    title: Text(user.fullName ?? user.username),
                    subtitle: Text('@${user.username}'),
                    trailing: isMe
                        ? null
                        : OutlinedButton(
                            onPressed: _busyIds.contains(user.id)
                                ? null
                                : () => _toggle(user),
                            child: Text(following ? 'Following' : 'Follow'),
                          ),
                  ),
                );
              },
            ),
          ),
  );
}

String _initial(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
}

class _Message extends StatelessWidget {
  const _Message({required this.message, this.onRetry});
  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.people_outline_rounded,
          size: 56,
          color: KokTokens.leaf,
        ),
        const SizedBox(height: 12),
        Text(message),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ],
    ),
  );
}
