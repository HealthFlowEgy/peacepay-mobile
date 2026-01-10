import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/gradient_button.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحقق من الهوية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Level
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.shield, color: Colors.white, size: 48),
                SizedBox(height: 12),
                Text('المستوى الحالي: برونزي', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('الحد الشهري: 5,000 ج.م', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Levels
          _LevelCard(
            level: 'برونزي',
            limit: '5,000 ج.م',
            requirements: ['رقم الهاتف مفعل'],
            isComplete: true,
            isCurrent: true,
          ),
          _LevelCard(
            level: 'فضي',
            limit: '50,000 ج.م',
            requirements: ['صورة البطاقة الشخصية', 'صورة سيلفي'],
            isComplete: false,
            isCurrent: false,
          ),
          _LevelCard(
            level: 'ذهبي',
            limit: 'غير محدود',
            requirements: ['صورة البطاقة الشخصية', 'صورة سيلفي', 'إثبات عنوان'],
            isComplete: false,
            isCurrent: false,
          ),

          const SizedBox(height: 24),

          GradientButton(
            onPressed: () {
              // Start KYC verification flow
            },
            child: const Text('ترقية إلى فضي'),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String level;
  final String limit;
  final List<String> requirements;
  final bool isComplete;
  final bool isCurrent;

  const _LevelCard({
    required this.level,
    required this.limit,
    required this.requirements,
    required this.isComplete,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCurrent ? AppColors.primary : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isComplete ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isComplete ? Icons.check_circle : Icons.shield,
                  color: isComplete ? AppColors.success : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('حد شهري: $limit', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
              const Spacer(),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('الحالي', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      isComplete ? Icons.check : Icons.circle,
                      size: 12,
                      color: isComplete ? AppColors.success : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(req, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
