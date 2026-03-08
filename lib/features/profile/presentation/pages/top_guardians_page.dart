import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';

class TopGuardiansPage extends StatelessWidget {
  const TopGuardiansPage({super.key});

  List<(String, String, String, String)> get guardians => const [
    ('🌟', 'Sarah Chen', '156 trees', '#1'),
    ('🌲', 'Mike Johnson', '142 trees', '#2'),
    ('🍃', 'You', '58 trees', '#3'),
    ('🌳', 'Emma Davis', '51 trees', '#4'),
    ('🌿', 'Alex Brown', '49 trees', '#5'),
  ];

  Widget header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
    child: Row(
      children: [
        IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
        Expanded(child: Text('Top Guardians', style: Style.title20(context))),
      ],
    ),
  );

  Widget guardianCard(BuildContext context, (String, String, String, String) item) => KokCard(
    child: Row(
      children: [
        Text(item.$1, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.$2, style: Style.body14(context, weight: FontWeight.w700)),
              Text(item.$3, style: Style.body12(context, color: AppColors.gray717171)),
            ],
          ),
        ),
        Text(item.$4, style: Style.body14(context, color: AppColors.primary, weight: FontWeight.w700)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: SafeArea(
      child: Column(
        children: [
          header(context),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemBuilder: (context, index) => guardianCard(context, guardians[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: guardians.length,
            ),
          ),
        ],
      ),
    ),
  );
}
