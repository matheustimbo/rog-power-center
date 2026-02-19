class PowerProfile {
  final String name;
  final int thermalPolicy; // 0=balanced, 1=performance, 2=quiet
  final bool cpuBoost;
  final String epp;
  final int pptPl1;
  final int pptPl2;
  final int? nvBoost;
  final int? nvTemp;
  final int kbdBrightness;

  const PowerProfile({
    required this.name,
    required this.thermalPolicy,
    required this.cpuBoost,
    required this.epp,
    required this.pptPl1,
    required this.pptPl2,
    this.nvBoost,
    this.nvTemp,
    required this.kbdBrightness,
  });

  static const silent = PowerProfile(
    name: 'Silent',
    thermalPolicy: 2,
    cpuBoost: false,
    epp: 'power',
    pptPl1: 15,
    pptPl2: 25,
    kbdBrightness: 0,
  );

  static const daily = PowerProfile(
    name: 'Daily',
    thermalPolicy: 0,
    cpuBoost: true,
    epp: 'balance_performance',
    pptPl1: 45,
    pptPl2: 65,
    kbdBrightness: 1,
  );

  static const gaming = PowerProfile(
    name: 'Gaming',
    thermalPolicy: 1,
    cpuBoost: true,
    epp: 'performance',
    pptPl1: 80,
    pptPl2: 115,
    nvBoost: 25,
    nvTemp: 87,
    kbdBrightness: 3,
  );

  static const profiles = [silent, daily, gaming];
}
