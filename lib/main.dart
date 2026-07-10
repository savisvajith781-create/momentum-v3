import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'constants/app_constants.dart';
import 'providers/core_providers.dart';
import 'providers/settings_provider.dart';
import 'providers/quote_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite FFI for desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize Hive
  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter('${appDir.path}/Momentum/hive');

  // Initialize window manager
  await windowManager.ensureInitialized();

  // Load saved window size
  final prefs = await SharedPreferences.getInstance();
  final savedWidth =
      prefs.getDouble(AppConstants.keyWindowWidth) ?? AppConstants.defaultWindowWidth;
  final savedHeight =
      prefs.getDouble(AppConstants.keyWindowHeight) ?? AppConstants.defaultWindowHeight;
  final savedX = prefs.getDouble(AppConstants.keyWindowX);
  final savedY = prefs.getDouble(AppConstants.keyWindowY);

  final windowOptions = WindowOptions(
    size: Size(savedWidth, savedHeight),
    minimumSize: const Size(
      AppConstants.minWindowWidth,
      AppConstants.minWindowHeight,
    ),
    center: savedX == null || savedY == null,
    backgroundColor: const Color(0xFF0B0F14),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Momentum',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (savedX != null && savedY != null) {
      await windowManager.setPosition(Offset(savedX, savedY));
    }
    await windowManager.show();
    await windowManager.focus();
  });

  // Create the provider container so we can initialize services
  final container = ProviderContainer();

  // Initialize settings service
  final settingsService = container.read(settingsServiceProvider);
  await settingsService.init();

  // Initialize quote service
  final quoteService = container.read(quoteServiceProvider);
  await quoteService.init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const _WindowListener(
        child: MomentumApp(),
      ),
    ),
  );
}

class _WindowListener extends ConsumerStatefulWidget {
  final Widget child;

  const _WindowListener({required this.child});

  @override
  ConsumerState<_WindowListener> createState() => _WindowListenerState();
}

class _WindowListenerState extends ConsumerState<_WindowListener>
    with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowResized() async {
    final size = await windowManager.getSize();
    final settings = ref.read(settingsServiceProvider);
    await settings.setWindowWidth(size.width);
    await settings.setWindowHeight(size.height);
  }

  @override
  void onWindowMoved() async {
    final position = await windowManager.getPosition();
    final settings = ref.read(settingsServiceProvider);
    await settings.setWindowPosition(position.dx, position.dy);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
