import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/system_state.dart';
import 'sysfs_service.dart';

class HardwareMonitor extends ChangeNotifier {
  SystemState _state = const SystemState();
  Timer? _timer;
  bool _refreshing = false;

  SystemState get state => _state;

  HardwareMonitor() {
    refresh();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => refresh());
  }

  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      _state = await SysfsService.readAllInIsolate();
      notifyListeners();
    } finally {
      _refreshing = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
