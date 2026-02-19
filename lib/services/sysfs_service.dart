import 'dart:io';
import 'dart:isolate';
import '../models/system_state.dart';

class SysfsService {
  static const _base = '/sys/devices/platform/asus-nb-wmi';
  static const _thermal = '$_base/throttle_thermal_policy';
  static const _pptPl1 = '$_base/ppt_pl1_spl';
  static const _pptPl2 = '$_base/ppt_pl2_sppt';
  static const _nvBoost = '$_base/nv_dynamic_boost';
  static const _nvTemp = '$_base/nv_temp_target';
  static const _panelOd = '$_base/panel_od';
  static const _dgpuDisable = '$_base/dgpu_disable';
  static const _gpuMux = '$_base/gpu_mux_mode';
  static const _noTurbo = '/sys/devices/system/cpu/intel_pstate/no_turbo';
  static const _kbdBright = '/sys/class/leds/asus::kbd_backlight/brightness';
  static const _chargeLimit =
      '/sys/class/power_supply/BAT0/charge_control_end_threshold';

  static const _fanBase = '/sys/class/hwmon/hwmon8';
  static const _tempBase = '/sys/class/hwmon/hwmon7';

  static final _helperPath =
      '${Platform.environment['HOME']}/.local/bin/rog-power-helper';

  static int _readInt(String path, [int fallback = 0]) {
    try {
      final content = File(path).readAsStringSync().trim();
      return int.tryParse(content) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  static String _readString(String path, [String fallback = '']) {
    try {
      return File(path).readAsStringSync().trim();
    } catch (_) {
      return fallback;
    }
  }

  /// Reads all sysfs values in a background isolate so the UI thread is never blocked.
  static Future<SystemState> readAllInIsolate() {
    return Isolate.run(_readAllState);
  }

  static SystemState _readAllState() {
    final freq = _readInt('/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq', 0);
    final temp = _readInt('$_tempBase/temp1_input', 0);
    final pw = _readInt('/sys/class/power_supply/BAT0/power_now', 0);
    return SystemState(
      thermalPolicy: _readInt(_thermal),
      cpuBoost: _readInt(_noTurbo) == 0,
      epp: _readString(
        '/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference',
        'balance_performance',
      ),
      pptPl1: _readInt(_pptPl1),
      pptPl2: _readInt(_pptPl2),
      nvBoost: _readInt(_nvBoost),
      nvTemp: _readInt(_nvTemp),
      panelOd: _readInt(_panelOd) == 1,
      kbdBrightness: _readInt(_kbdBright),
      batteryPercent: _readInt('/sys/class/power_supply/BAT0/capacity', 0),
      batteryStatus: _readString('/sys/class/power_supply/BAT0/status', 'Unknown'),
      chargeLimit: _readInt(_chargeLimit, 100),
      powerDraw: pw / 1000000.0,
      cpuTemp: temp ~/ 1000,
      fan1Rpm: _readInt('$_fanBase/fan1_input'),
      fan2Rpm: _readInt('$_fanBase/fan2_input'),
      fan3Rpm: _readInt('$_fanBase/fan3_input'),
      dgpuDisabled: _readInt(_dgpuDisable) == 1,
      gpuMux: _readInt(_gpuMux),
      cpuFreqMhz: freq ~/ 1000,
      governor: _readString(
        '/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor',
        'powersave',
      ),
    );
  }

  Future<bool> _writeValue(String path, dynamic value) async {
    try {
      await File(path).writeAsString('$value');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Write multiple path/value pairs in one pkexec call
  Future<bool> writeBatch(Map<String, dynamic> values) async {
    // First try direct writes
    final failed = <String, dynamic>{};
    for (final entry in values.entries) {
      final ok = await _writeValue(entry.key, entry.value);
      if (!ok) failed[entry.key] = entry.value;
    }
    if (failed.isEmpty) return true;

    // Batch all failed writes into one pkexec call
    final args = <String>[];
    for (final entry in failed.entries) {
      args.addAll([entry.key, '${entry.value}']);
    }
    try {
      final result = await Process.run('pkexec', [_helperPath, ...args]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  // === SINGLE WRITES (for toggles/sliders) ===

  Future<bool> setThermalPolicy(int value) =>
      writeBatch({_thermal: value});
  Future<bool> setCpuBoost(bool on) =>
      writeBatch({_noTurbo: on ? 0 : 1});
  Future<bool> setPptPl1(int watts) =>
      writeBatch({_pptPl1: watts});
  Future<bool> setPptPl2(int watts) =>
      writeBatch({_pptPl2: watts});
  Future<bool> setNvBoost(int watts) =>
      writeBatch({_nvBoost: watts});
  Future<bool> setNvTemp(int degrees) =>
      writeBatch({_nvTemp: degrees});
  Future<bool> setPanelOd(bool on) =>
      writeBatch({_panelOd: on ? 1 : 0});
  Future<bool> setKbdBrightness(int level) =>
      writeBatch({_kbdBright: level});
  Future<bool> setChargeLimit(int percent) =>
      writeBatch({_chargeLimit: percent});

  Future<bool> setEpp(String value) async {
    final batch = <String, dynamic>{};
    final dir = Directory('/sys/devices/system/cpu');
    if (!await dir.exists()) return false;
    await for (final entity in dir.list()) {
      if (entity is Directory &&
          RegExp(r'cpu\d+$').hasMatch(entity.path.split('/').last)) {
        batch['${entity.path}/cpufreq/energy_performance_preference'] = value;
      }
    }
    return writeBatch(batch);
  }

  // === PATHS (for profile manager batch) ===

  static String get thermalPath => _thermal;
  static String get noTurboPath => _noTurbo;
  static String get pptPl1Path => _pptPl1;
  static String get pptPl2Path => _pptPl2;
  static String get nvBoostPath => _nvBoost;
  static String get nvTempPath => _nvTemp;
  static String get panelOdPath => _panelOd;
  static String get kbdBrightPath => _kbdBright;
}
