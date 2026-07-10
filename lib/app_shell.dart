import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../models/timer_state.dart';
import '../providers/timer_provider.dart';
import '../theme/app_colors.dart';
import '../pages/dashboard_page.dart';
import '../pages/history_page.dart';
import '../pages/statistics_page.dart';
import '../pages/tasks_page.dart';
import '../pages/checkpoints_page.dart';
import '../pages/settings_page.dart';
import '../utils/format_utils.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final timerState = ref.watch(timerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Navigation Rail
          _AppNavigationRail(
            currentPage: currentPage,
            hasActiveTimer: timerState.isActive,
          ),
          // Divider
          Container(
            width: 1,
            color: AppColors.border,
          ),
          // Content
          Expanded(
            child: _PageContent(currentPage: currentPage),
          ),
        ],
      ),
    );
  }
}

class _AppNavigationRail extends ConsumerWidget {
  final AppPage currentPage;
  final bool hasActiveTimer;

  const _AppNavigationRail({
    required this.currentPage,
    required this.hasActiveTimer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);

    return Container(
      width: 72,
      color: AppColors.surface,
      child: Column(
        children: [
          // Logo
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Nav items
          Expanded(
            child: Column(
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Home',
                  page: AppPage.dashboard,
                  currentPage: currentPage,
                ),
                _NavItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  page: AppPage.history,
                  currentPage: currentPage,
                ),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Stats',
                  page: AppPage.statistics,
                  currentPage: currentPage,
                ),
                _NavItem(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Tasks',
                  page: AppPage.tasks,
                  currentPage: currentPage,
                ),
                _NavItem(
                  icon: Icons.flag_rounded,
                  label: 'Goals',
                  page: AppPage.checkpoints,
                  currentPage: currentPage,
                ),
              ],
            ),
          ),
          // Active timer mini indicator
          if (hasActiveTimer)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _TimerIndicator(timerState: timerState),
            ),
          // Settings at bottom
          _NavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            page: AppPage.settings,
            currentPage: currentPage,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final AppPage page;
  final AppPage currentPage;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.page,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = page == currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Tooltip(
        message: label,
        preferBelow: false,
        child: InkWell(
          onTap: () => ref.read(currentPageProvider.notifier).state = page,
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppColors.primary.withOpacity(0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 22,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected ? AppColors.primary : AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerIndicator extends ConsumerWidget {
  final TimerState timerState;
  const _TimerIndicator({required this.timerState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message:
          '${timerState.subject?.name ?? ''} – ${FormatUtils.formatTimer(timerState.elapsedSeconds)}',
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: timerState.isRunning
              ? AppColors.green.withOpacity(0.12)
              : AppColors.orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: timerState.isRunning
                ? AppColors.green.withOpacity(0.3)
                : AppColors.orange.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              timerState.isRunning
                  ? Icons.play_circle_filled_rounded
                  : Icons.pause_circle_filled_rounded,
              color:
                  timerState.isRunning ? AppColors.green : AppColors.orange,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              FormatUtils.formatTimer(timerState.elapsedSeconds),
              style: TextStyle(
                color: timerState.isRunning
                    ? AppColors.green
                    : AppColors.orange,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final AppPage currentPage;

  const _PageContent({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey(currentPage),
        child: _buildPage(currentPage),
      ),
    );
  }

  Widget _buildPage(AppPage page) {
    switch (page) {
      case AppPage.dashboard:
        return const DashboardPage();
      case AppPage.history:
        return const HistoryPage();
      case AppPage.statistics:
        return const StatisticsPage();
      case AppPage.tasks:
        return const TasksPage();
      case AppPage.checkpoints:
        return const CheckpointsPage();
      case AppPage.settings:
        return const SettingsPage();
    }
  }
}
