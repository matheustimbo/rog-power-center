import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'services/hardware_monitor.dart';
import 'services/profile_manager.dart';
import 'models/power_profile.dart';

bool _trayAvailable = false;

class TrayHandler with TrayListener {
  final HardwareMonitor monitor;
  final ProfileManager profileManager;

  TrayHandler({required this.monitor, required this.profileManager});

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'silent':
        await profileManager.applyProfile(PowerProfile.silent);
        await monitor.refresh();
        await _updateTrayMenu();
        break;
      case 'daily':
        await profileManager.applyProfile(PowerProfile.daily);
        await monitor.refresh();
        await _updateTrayMenu();
        break;
      case 'gaming':
        await profileManager.applyProfile(PowerProfile.gaming);
        await monitor.refresh();
        await _updateTrayMenu();
        break;
      case 'boost_toggle':
        final current = monitor.state.cpuBoost;
        await profileManager.sysfs.setCpuBoost(!current);
        await monitor.refresh();
        await _updateTrayMenu();
        break;
      case 'show':
        await windowManager.show();
        await windowManager.focus();
        break;
      case 'quit':
        await windowManager.destroy();
        break;
    }
  }

  Future<void> _updateTrayMenu() async {
    final state = monitor.state;
    final menu = Menu(items: _buildMenuItems(state));
    await trayManager.setContextMenu(menu);
    try {
      await trayManager.setToolTip(
          'ROG Power: ${state.profileName} | ${state.cpuTemp}°C');
    } catch (_) {}
  }

  List<MenuItem> _buildMenuItems(state) {
    return [
      MenuItem(
        key: 'silent',
        label: '${state.thermalPolicy == 2 ? "● " : "  "}Silent',
      ),
      MenuItem(
        key: 'daily',
        label: '${state.thermalPolicy == 0 ? "● " : "  "}Daily',
      ),
      MenuItem(
        key: 'gaming',
        label: '${state.thermalPolicy == 1 ? "● " : "  "}Gaming',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'boost_toggle',
        label: 'Boost: ${state.cpuBoost ? "ON" : "OFF"}',
      ),
      MenuItem.separator(),
      MenuItem(key: 'show', label: 'Open ROG Power Center'),
      MenuItem(key: 'quit', label: 'Quit'),
    ];
  }

  Future<bool> initTray() async {
    try {
      await trayManager.setIcon('assets/icon.png');
      final state = monitor.state;
      final menu = Menu(items: _buildMenuItems(state));
      await trayManager.setContextMenu(menu);
      try {
        await trayManager.setToolTip(
            'ROG Power: ${state.profileName} | ${state.cpuTemp}°C');
      } catch (_) {}
      trayManager.addListener(this);
      return true;
    } catch (e) {
      debugPrint('Tray init failed: $e');
      return false;
    }
  }
}

class _AppWindowListener with WindowListener {
  @override
  void onWindowClose() async {
    if (_trayAvailable) {
      await windowManager.hide();
    } else {
      await windowManager.destroy();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(680, 720),
    minimumSize: Size(360, 400),
    center: true,
    title: 'ROG Power Center',
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final monitor = HardwareMonitor();
  final profileManager = ProfileManager();

  final trayHandler =
      TrayHandler(monitor: monitor, profileManager: profileManager);
  _trayAvailable = await trayHandler.initTray();

  if (_trayAvailable) {
    await windowManager.setPreventClose(true);
    windowManager.addListener(_AppWindowListener());
  }

  runApp(
    ChangeNotifierProvider.value(
      value: monitor,
      child: const RogPowerApp(),
    ),
  );
}
