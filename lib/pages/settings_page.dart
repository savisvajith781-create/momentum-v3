import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/subjects_provider.dart';
import '../providers/stages_provider.dart';
import '../providers/core_providers.dart';
import '../providers/stats_provider.dart';
import '../models/subject_model.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';
import '../widgets/surface_card.dart';
import '../widgets/page_transition.dart';
import '../constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FadeSlideIn(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingsHeader(),
              SizedBox(height: 28),
              _GoalSection(),
              SizedBox(height: 20),
              _AppearanceSection(),
              SizedBox(height: 20),
              _SubjectsSection(),
              SizedBox(height: 20),
              _StagesSection(),
              SizedBox(height: 20),
              _BackupSection(),
              SizedBox(height: 20),
              _AboutSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Customize your experience',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _GoalSection extends ConsumerStatefulWidget {
  const _GoalSection();

  @override
  ConsumerState<_GoalSection> createState() => _GoalSectionState();
}

class _GoalSectionState extends ConsumerState<_GoalSection> {
  late double _hours;
  late double _minutes;

  @override
  void initState() {
    super.initState();
    final seconds = ref.read(settingsProvider).dailyTargetSeconds;
    _hours = (seconds ~/ 3600).toDouble();
    _minutes = ((seconds % 3600) ~/ 60).toDouble();
  }

  void _save() {
    final total = (_hours.toInt() * 3600 + _minutes.toInt() * 60);
    ref.read(settingsProvider.notifier).setDailyTarget(total);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daily goal updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Study Goal'),
        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'Daily Study Target',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_hours.toInt()}h ${_minutes.toInt()}m',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SliderRow(
                label: 'Hours',
                value: _hours,
                min: 0,
                max: 16,
                divisions: 16,
                onChanged: (v) => setState(() => _hours = v),
              ),
              const SizedBox(height: 8),
              _SliderRow(
                label: 'Minutes',
                value: _minutes,
                min: 0,
                max: 55,
                divisions: 11,
                onChanged: (v) => setState(() => _minutes = v),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Goal'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '${value.toInt()}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currentColor = settings.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Appearance'),
        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Accent Color',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppColors.subjectPalette.map((c) {
                  final isSelected = c.value == currentColor.value;
                  return GestureDetector(
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .setAccentColor(c.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: c.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubjectsSection extends ConsumerWidget {
  const _SubjectsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionTitle('Subjects'),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddSubjectDialog(context, ref),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        SurfaceCard(
          child: subjectsAsync.when(
            data: (subjects) => Column(
              children: subjects.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                return Column(
                  children: [
                    if (i > 0)
                      const Divider(
                          color: AppColors.border, height: 1),
                    _SubjectRow(subject: s),
                  ],
                );
              }).toList(),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('$e'),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddSubjectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddSubjectDialog(),
    );
  }
}

class _SubjectRow extends ConsumerWidget {
  final SubjectModel subject;
  const _SubjectRow({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: subject.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                subject.icon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subject.isDefault)
                  const Text(
                    'Default',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: subject.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                size: 16, color: AppColors.textMuted),
            onPressed: () => _showEditDialog(context, ref),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Rename / recolor',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 16, color: AppColors.red),
            onPressed: () => _confirmDelete(context, ref),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _EditSubjectDialog(subject: subject),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
            'Delete "${subject.name}"? Sessions using this subject will still be preserved.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(subjectsProvider.notifier)
                  .deleteSubject(subject.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _StagesSection extends ConsumerWidget {
  const _StagesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stages = ref.watch(stagesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionTitle('Session Stages'),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddStageDialog(context, ref),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Labels used when logging a study session — rename these to '
            'match your own workflow (e.g. "Chapter 1", "Revision", '
            '"Practice Test").',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
        SurfaceCard(
          child: Column(
            children: stages.asMap().entries.map((entry) {
              final i = entry.key;
              final stage = entry.value;
              return Column(
                children: [
                  if (i > 0)
                    const Divider(color: AppColors.border, height: 1),
                  _StageRow(stage: stage, canDelete: stages.length > 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showAddStageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _StageEditDialog(
        title: 'Add Stage',
        onSubmit: (name) => ref.read(stagesProvider.notifier).addStage(name),
      ),
    );
  }
}

class _StageRow extends ConsumerWidget {
  final String stage;
  final bool canDelete;
  const _StageRow({required this.stage, required this.canDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stage,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                size: 16, color: AppColors.textMuted),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => _StageEditDialog(
                title: 'Rename Stage',
                initialValue: stage,
                onSubmit: (name) => ref
                    .read(stagesProvider.notifier)
                    .renameStage(stage, name),
              ),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Rename',
          ),
          if (canDelete) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 16, color: AppColors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Stage'),
                    content: Text(
                        'Delete "$stage"? Past sessions using this label are kept as-is.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref
                              .read(stagesProvider.notifier)
                              .deleteStage(stage);
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: AppColors.red)),
                      ),
                    ],
                  ),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Delete',
            ),
          ],
        ],
      ),
    );
  }
}

class _StageEditDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final ValueChanged<String> onSubmit;

  const _StageEditDialog({
    required this.title,
    this.initialValue,
    required this.onSubmit,
  });

  @override
  State<_StageEditDialog> createState() => _StageEditDialogState();
}

class _StageEditDialogState extends State<_StageEditDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _ctrl.text.trim();
    if (value.isEmpty) return;
    widget.onSubmit(value);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextFormField(
        controller: _ctrl,
        autofocus: true,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: const InputDecoration(
          labelText: 'Stage name',
          hintText: 'e.g. Chapter 1, Practice, Mock Test',
        ),
        onFieldSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

class _BackupSection extends ConsumerWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Backup & Export'),
        SurfaceCard(
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.backup_rounded,
                title: 'Export Backup',
                subtitle: 'Save all sessions and tasks to JSON',
                trailing: ElevatedButton.icon(
                  onPressed: () => _exportBackup(context, ref),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Export'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              _SettingsRow(
                icon: Icons.restore_rounded,
                title: 'Import Backup',
                subtitle: 'Restore sessions from a JSON backup',
                trailing: OutlinedButton.icon(
                  onPressed: () => _importBackup(context, ref),
                  icon: const Icon(Icons.upload_rounded, size: 16),
                  label: const Text('Import'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              _SettingsRow(
                icon: Icons.table_chart_rounded,
                title: 'Export as CSV',
                subtitle: 'Download session history as spreadsheet',
                trailing: OutlinedButton.icon(
                  onPressed: () => _exportCSV(context, ref),
                  icon: const Icon(Icons.file_download_rounded,
                      size: 16),
                  label: const Text('CSV'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              _SettingsRow(
                icon: Icons.picture_as_pdf_rounded,
                title: 'Weekly Report (PDF)',
                subtitle: 'Auto-generated summary of this week',
                trailing: OutlinedButton.icon(
                  onPressed: () => _exportWeeklyPDF(context, ref),
                  icon: const Icon(Icons.description_rounded, size: 16),
                  label: const Text('PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    try {
      final sessions = await ref
          .read(sessionRepositoryProvider)
          .getAllSessionsForExport();
      final tasks = await ref
          .read(taskRepositoryProvider)
          .getAllTasksForExport();
      final path = await ref
          .read(exportServiceProvider)
          .exportToJSON(sessions, tasks);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to: $path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Place backup JSON file in Documents/Momentum/exports/ and select it'),
        ),
      );
    }
  }

  Future<void> _exportCSV(BuildContext context, WidgetRef ref) async {
    try {
      final sessions = await ref
          .read(sessionRepositoryProvider)
          .getAllSessionsForExport();
      final path = await ref
          .read(exportServiceProvider)
          .exportSessionsToCSV(sessions);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV exported to: $path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportWeeklyPDF(BuildContext context, WidgetRef ref) async {
    try {
      final report = await ref.read(weeklyReportProvider.future);
      final path = await ref
          .read(exportServiceProvider)
          .exportWeeklyReportToPDF(report);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Weekly report saved to: $path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('About'),
        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('M',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      )),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Momentum',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Minimal Study Tracker',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddSubjectDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddSubjectDialog> createState() =>
      _AddSubjectDialogState();
}

class _AddSubjectDialogState
    extends ConsumerState<_AddSubjectDialog> {
  final _nameCtrl = TextEditingController();
  Color _selectedColor = AppColors.subjectPalette[0];
  String _icon = '⭐';
  final _uuid = const Uuid();

  final List<String> _icons = [
    '⭐', '📚', '📖', '📝', '✏️', '🖊️',
    '💡', '🧠', '🎯', '🔥', '⚡', '💪',
    '🏃', '🧮', '📊', '📈', '🔍', '⚖️',
    '🏦', '💰', '📋', '✅', '🗂️', '☕',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    ref.read(subjectsProvider.notifier).addSubject(
          SubjectModel(
            id: 'subj_${_uuid.v4().substring(0, 8)}',
            name: name,
            colorValue: _selectedColor.value,
            icon: _icon,
            isDefault: false,
            sortOrder: 100,
            createdAt: DateTime.now(),
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Subject'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                hintText: 'e.g. Law, SCMPE',
              ),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Color',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppColors.subjectPalette.map((c) {
                final isSelected = c.value == _selectedColor.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Icon',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _icons.map((emoji) {
                final selected = emoji == _icon;
                return GestureDetector(
                  onTap: () => setState(() => _icon = emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected
                          ? _selectedColor.withOpacity(0.2)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? _selectedColor.withOpacity(0.6)
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
            onPressed: _submit, child: const Text('Add Subject')),
      ],
    );
  }
}

class _EditSubjectDialog extends ConsumerStatefulWidget {
  final SubjectModel subject;
  const _EditSubjectDialog({required this.subject});

  @override
  ConsumerState<_EditSubjectDialog> createState() =>
      _EditSubjectDialogState();
}

class _EditSubjectDialogState extends ConsumerState<_EditSubjectDialog> {
  late final TextEditingController _nameCtrl;
  late Color _selectedColor;
  late String _icon;

  final List<String> _icons = [
    '⭐', '📚', '📖', '📝', '✏️', '🖊️',
    '💡', '🧠', '🎯', '🔥', '⚡', '💪',
    '🏃', '🧮', '📊', '📈', '🔍', '⚖️',
    '🏦', '💰', '📋', '✅', '🗂️', '☕',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.subject.name);
    _selectedColor = widget.subject.color;
    _icon = widget.subject.icon;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    ref.read(subjectsProvider.notifier).updateSubject(
          widget.subject.copyWith(
            name: name,
            colorValue: _selectedColor.value,
            icon: _icon,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Subject'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Subject Name',
              ),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Color',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppColors.subjectPalette.map((c) {
                final isSelected = c.value == _selectedColor.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Icon',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _icons.map((emoji) {
                final selected = emoji == _icon;
                return GestureDetector(
                  onTap: () => setState(() => _icon = emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected
                          ? _selectedColor.withOpacity(0.2)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? _selectedColor.withOpacity(0.6)
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
            onPressed: _submit, child: const Text('Save Changes')),
      ],
    );
  }
}
