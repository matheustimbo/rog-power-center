import 'dart:io';
import 'sysfs_service.dart';
import '../models/power_profile.dart';

class ProfileManager {
  final SysfsService sysfs = SysfsService();

  Future<void> applyProfile(PowerProfile profile) async {
    // Collect all EPP paths
    final eppPaths = <String, dynamic>{};
    final dir = Directory('/sys/devices/system/cpu');
    if (await dir.exists()) {
      await for (final entity in dir.list()) {
        if (entity is Directory &&
            RegExp(r'cpu\d+$').hasMatch(entity.path.split('/').last)) {
          eppPaths['${entity.path}/cpufreq/energy_performance_preference'] =
              profile.epp;
        }
      }
    }

    // Single batch write: one pkexec prompt at most
    final batch = <String, dynamic>{
      SysfsService.thermalPath: profile.thermalPolicy,
      SysfsService.noTurboPath: profile.cpuBoost ? 0 : 1,
      SysfsService.pptPl1Path: profile.pptPl1,
      SysfsService.pptPl2Path: profile.pptPl2,
      SysfsService.kbdBrightPath: profile.kbdBrightness,
      SysfsService.panelOdPath: 1,
      ...eppPaths,
    };

    if (profile.nvBoost != null) {
      batch[SysfsService.nvBoostPath] = profile.nvBoost;
    }
    if (profile.nvTemp != null) {
      batch[SysfsService.nvTempPath] = profile.nvTemp;
    }

    await sysfs.writeBatch(batch);
  }

}
