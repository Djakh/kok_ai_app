import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/design_tokens.dart';

class TopGuardiansPage extends StatelessWidget {
  const TopGuardiansPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: context.pop,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: const Text('Top Guardians'),
    ),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.leaderboard_outlined, size: 64, color: KokTokens.leaf),
            SizedBox(height: 16),
            Text(
              'Leaderboard is coming soon',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              'The backend contract does not yet provide guardian ranking or score data. No sample users are shown as real data.',
              textAlign: TextAlign.center,
              style: TextStyle(color: KokTokens.inkMuted, height: 1.45),
            ),
          ],
        ),
      ),
    ),
  );
}
