import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppPage { dashboard, history, statistics, tasks, checkpoints, settings }

final currentPageProvider = StateProvider<AppPage>((ref) => AppPage.dashboard);
