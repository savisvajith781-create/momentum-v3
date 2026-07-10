import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quote_provider.dart';
import '../providers/core_providers.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import 'surface_card.dart';

class QuoteCard extends ConsumerStatefulWidget {
  const QuoteCard({super.key});

  @override
  ConsumerState<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends ConsumerState<QuoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    // Start rotation timer
    _scheduleNextQuote();
  }

  void _scheduleNextQuote() {
    final frequencyMinutes = ref.read(settingsProvider).quoteFrequencyMinutes;
    Future.delayed(Duration(minutes: frequencyMinutes), () {
      if (!mounted) return;
      _rotateQuote();
    });
  }

  Future<void> _rotateQuote() async {
    await _fadeController.reverse();
    if (!mounted) return;
    final service = ref.read(quoteServiceProvider);
    ref.read(quoteProvider.notifier).next(service.nextQuote);
    await _fadeController.forward();
    if (mounted) _scheduleNextQuote();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quote = ref.watch(quoteProvider);

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '"',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 40,
                height: 0.6,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              quote.text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 1.5,
                  color: AppColors.primary.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '— ${quote.author}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _rotateQuote,
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
