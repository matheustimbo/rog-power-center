class SystemState {
  final int thermalPolicy; // 0=balanced, 1=performance, 2=quiet
  final bool cpuBoost;
  final String epp;
  final int pptPl1;
  final int pptPl2;
  final int nvBoost;
  final int nvTemp;
  final bool panelOd;
  final int kbdBrightness;
  final int batteryPercent;
  final String batteryStatus;
  final int chargeLimit;
  final double powerDraw;
  final int cpuTemp;
  final int fan1Rpm;
  final int fan2Rpm;
  final int fan3Rpm;
  final bool dgpuDisabled;
  final int gpuMux; // 0=dGPU, 1=iGPU
  final int cpuFreqMhz;
  final String governor;

  const SystemState({
    this.thermalPolicy = 0,
    this.cpuBoost = false,
    this.epp = 'balance_performance',
    this.pptPl1 = 45,
    this.pptPl2 = 65,
    this.nvBoost = 0,
    this.nvTemp = 0,
    this.panelOd = true,
    this.kbdBrightness = 1,
    this.batteryPercent = 0,
    this.batteryStatus = 'Unknown',
    this.chargeLimit = 100,
    this.powerDraw = 0,
    this.cpuTemp = 0,
    this.fan1Rpm = 0,
    this.fan2Rpm = 0,
    this.fan3Rpm = 0,
    this.dgpuDisabled = false,
    this.gpuMux = 1,
    this.cpuFreqMhz = 0,
    this.governor = 'powersave',
  });

  String get thermalName {
    switch (thermalPolicy) {
      case 0:
        return 'Balanced';
      case 1:
        return 'Performance';
      case 2:
        return 'Quiet';
      default:
        return 'Unknown';
    }
  }

  String get profileName {
    switch (thermalPolicy) {
      case 2:
        return 'Silent';
      case 0:
        return 'Daily';
      case 1:
        return 'Gaming';
      default:
        return 'Unknown';
    }
  }

  String get gpuMuxName => gpuMux == 1 ? 'iGPU' : 'dGPU';
  String get dgpuStatus => dgpuDisabled ? 'Disabled' : 'Enabled';

  SystemState copyWith({
    int? thermalPolicy,
    bool? cpuBoost,
    String? epp,
    int? pptPl1,
    int? pptPl2,
    int? nvBoost,
    int? nvTemp,
    bool? panelOd,
    int? kbdBrightness,
    int? batteryPercent,
    String? batteryStatus,
    int? chargeLimit,
    double? powerDraw,
    int? cpuTemp,
    int? fan1Rpm,
    int? fan2Rpm,
    int? fan3Rpm,
    bool? dgpuDisabled,
    int? gpuMux,
    int? cpuFreqMhz,
    String? governor,
  }) {
    return SystemState(
      thermalPolicy: thermalPolicy ?? this.thermalPolicy,
      cpuBoost: cpuBoost ?? this.cpuBoost,
      epp: epp ?? this.epp,
      pptPl1: pptPl1 ?? this.pptPl1,
      pptPl2: pptPl2 ?? this.pptPl2,
      nvBoost: nvBoost ?? this.nvBoost,
      nvTemp: nvTemp ?? this.nvTemp,
      panelOd: panelOd ?? this.panelOd,
      kbdBrightness: kbdBrightness ?? this.kbdBrightness,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      batteryStatus: batteryStatus ?? this.batteryStatus,
      chargeLimit: chargeLimit ?? this.chargeLimit,
      powerDraw: powerDraw ?? this.powerDraw,
      cpuTemp: cpuTemp ?? this.cpuTemp,
      fan1Rpm: fan1Rpm ?? this.fan1Rpm,
      fan2Rpm: fan2Rpm ?? this.fan2Rpm,
      fan3Rpm: fan3Rpm ?? this.fan3Rpm,
      dgpuDisabled: dgpuDisabled ?? this.dgpuDisabled,
      gpuMux: gpuMux ?? this.gpuMux,
      cpuFreqMhz: cpuFreqMhz ?? this.cpuFreqMhz,
      governor: governor ?? this.governor,
    );
  }
}
