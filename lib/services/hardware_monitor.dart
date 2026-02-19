import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/system_state.dart';
import 'sysfs_service.dart';

class HardwareMonitor extends ChangeNotifier {
  final SysfsService _sysfs = SysfsService();
  SystemState _state = const SystemState();
  Timer? _timer;

  SystemState get state => _state;

  HardwareMonitor() {
    refresh();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => refresh());
  }

  void refresh() {
    _state = SystemState(
      thermalPolicy: _sysfs.thermalPolicy,
      cpuBoost: _sysfs.cpuBoost,
      epp: _sysfs.epp,
      pptPl1: _sysfs.pptPl1,
      pptPl2: _sysfs.pptPl2,
      nvBoost: _sysfs.nvBoost,
      nvTemp: _sysfs.nvTemp,
      panelOd: _sysfs.panelOd,
      kbdBrightness: _sysfs.kbdBrightness,
      batteryPercent: _sysfs.batteryPercent,
      batteryStatus: _sysfs.batteryStatus,
      chargeLimit: _sysfs.chargeLimit,
      powerDraw: _sysfs.powerDraw,
      cpuTemp: _sysfs.cpuTemp,
      fan1Rpm: _sysfs.fan1Rpm,
      fan2Rpm: _sysfs.fan2Rpm,
      fan3Rpm: _sysfs.fan3Rpm,
      dgpuDisabled: _sysfs.dgpuDisabled,
      gpuMux: _sysfs.gpuMux,
      cpuFreqMhz: _sysfs.cpuFreqMhz,
      governor: _sysfs.governor,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
