import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/session_model.dart';
import '../models/task_model.dart';
import '../models/stats_model.dart';

class ExportService {
  Future<String> _getExportDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/Momentum/exports');
    await dir.create(recursive: true);
    return dir.path;
  }

  Future<String> exportSessionsToCSV(List<SessionModel> sessions) async {
    final dir = await _getExportDir();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = '$dir/sessions_$timestamp.csv';

    final rows = <List<dynamic>>[
      ['Date', 'Subject', 'Chapter', 'Stage', 'Start', 'End', 'Duration (min)', 'Notes'],
    ];

    for (final s in sessions) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(s.startTime),
        s.subjectName,
        s.chapter,
        s.revisionStage,
        DateFormat('HH:mm').format(s.startTime),
        s.endTime != null ? DateFormat('HH:mm').format(s.endTime!) : '',
        (s.durationSeconds / 60).toStringAsFixed(1),
        s.notes ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    await File(path).writeAsString(csv);
    return path;
  }

  Future<String> exportToJSON(
    List<SessionModel> sessions,
    List<TaskModel> tasks,
  ) async {
    final dir = await _getExportDir();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = '$dir/backup_$timestamp.json';

    final data = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'sessions': sessions.map((s) => s.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
    };

    await File(path).writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
    return path;
  }

  Future<String> exportWeeklyReportToPDF(WeeklyReport report) async {
    final dir = await _getExportDir();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = '$dir/weekly_report_$timestamp.pdf';

    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM d, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Momentum Weekly Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${dateFormat.format(report.weekStart)} – ${dateFormat.format(report.weekEnd)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 32),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildPDFStat('Total Hours', report.formattedTotal),
              _buildPDFStat('Daily Average', report.formattedAverage),
              _buildPDFStat('Target Hit', '${report.daysHitTarget}/7 days'),
              _buildPDFStat('Streak', '${report.streak} days'),
            ],
          ),
          pw.SizedBox(height: 32),
          pw.Header(level: 1, text: 'Subject Breakdown'),
          pw.SizedBox(height: 12),
          ...report.subjectSeconds.entries.map((e) {
            final hours = e.value / 3600;
            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(e.key),
                    pw.Text('${hours.toStringAsFixed(1)}h'),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.LinearProgressIndicator(
                  value: report.totalSeconds > 0
                      ? e.value / report.totalSeconds
                      : 0,
                ),
                pw.SizedBox(height: 8),
              ],
            );
          }),
          pw.SizedBox(height: 32),
          pw.Header(level: 1, text: 'Daily Breakdown'),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Hours', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Sessions', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              ...report.dailyBreakdown.map((day) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(DateFormat('EEE, MMM d').format(day.date)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(day.formattedTotal),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('${day.sessionCount}'),
                  ),
                ],
              )),
            ],
          ),
        ],
      ),
    );

    await File(path).writeAsBytes(await pdf.save());
    return path;
  }

  pw.Widget _buildPDFStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>?> importFromJSON(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      return json.decode(content) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
