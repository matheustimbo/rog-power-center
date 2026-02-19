import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/system_state.dart';
import 'sysfs_service.dart';

class HardwareMonitor extends ChangeNotifier {
  SystemState _state = const SystemState();
  Timer? _timer;
  Timer? _resizeDebounceTimer;
  bool _refreshing = false;
  bool _resizePaused = false;

  SystemState get state => _state;

  HardwareMonitor() {
    refresh();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => refresh());
  }

  Future<void> refresh() async {
    if (_refreshing || _resizePaused) return;
    _refreshing = true;
    try {
      _state = await SysfsService.readAllInIsolate();
      notifyListeners();
    } finally {
      _refreshing = false;
    }
  }

  void onWindowResized({Duration debounce = const Duration(milliseconds: 400)}) {
    _resizePaused = true;
    _resizeDebounceTimer?.cancel();
    _resizeDebounceTimer = Timer(debounce, () {
      _resizePaused = false;
      refresh();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resizeDebounceTimer?.cancel();
    super.dispose();
  }
}
