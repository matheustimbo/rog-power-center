import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/system_state.dart';
import '../services/hardware_monitor.dart';
import '../services/profile_manager.dart';
import '../widgets/profile_selector.dart';
import '../widgets/cpu_card.dart';
import '../widgets/gpu_card.dart';
import '../widgets/battery_card.dart';
import '../widgets/display_card.dart';
import '../widgets/keyboard_card.dart';
import '../widgets/monitor_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _profileManager = ProfileManager();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 48,
        title: Row(
          children: [
            Icon(Icons.bolt, color: scheme.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'ROG Power Center',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _ProfileChip(colorScheme: scheme),
          ),
        ],
      ),
      body: _Body(profileManager: _profileManager),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final ColorScheme colorScheme;

  const _ProfileChip({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final profileName =
        context.select((HardwareMonitor monitor) => monitor.state.profileName);
    return Chip(
      label: Text(
        profileName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      backgroundColor: colorScheme.primaryContainer,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}

class _Body extends StatelessWidget {
  final ProfileManager profileManager;

  const _Body({required this.profileManager});

  @override
  Widget build(BuildContext context) {
    final monitor = context.read<HardwareMonitor>();
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
          child: Column(
            children: [
              Selector<HardwareMonitor, int>(
                selector: (_, m) => m.state.thermalPolicy,
                builder: (context, thermalPolicy, _) {
                  return RepaintBoundary(
                    child: ProfileSelector(
                      currentThermal: thermalPolicy,
                      onProfileSelected: (profile) async {
                        await profileManager.applyProfile(profile);
                        await monitor.refresh();
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              if (constraints.maxWidth > 520)
                _WideLayout(onChanged: monitor.refresh)
              else
                _NarrowLayout(onChanged: monitor.refresh),
              const SizedBox(height: 8),
              const RepaintBoundary(child: _Footer()),
            ],
          ),
        );
      },
    );
  }
}

class _WideLayout extends StatelessWidget {
  final VoidCallback onChanged;

  const _WideLayout({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CpuSection(
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: _GpuSection()),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _BatterySection(
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DisplaySection(
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _KeyboardSection(
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: _MonitorSection()),
          ],
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final VoidCallback onChanged;

  const _NarrowLayout({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CpuSection(onChanged: onChanged),
        const SizedBox(height: 10),
        const _GpuSection(),
        const SizedBox(height: 10),
        _BatterySection(onChanged: onChanged),
        const SizedBox(height: 10),
        _DisplaySection(onChanged: onChanged),
        const SizedBox(height: 10),
        _KeyboardSection(onChanged: onChanged),
        const SizedBox(height: 10),
        const _MonitorSection(),
      ],
    );
  }
}

class _CpuSection extends StatelessWidget {
  final VoidCallback onChanged;

  const _CpuSection({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Selector<HardwareMonitor, SystemState>(
      selector: (_, m) => m.state,
      shouldRebuild: (prev, next) =>
          prev.cpuBoost != next.cpuBoost ||
          prev.governor != next.governor ||
          prev.cpuFreqMhz != next.cpuFreqMhz ||
          prev.epp != next.epp ||
          prev.pptPl1 != next.pptPl1 ||
          prev.pptPl2 != next.pptPl2,
      builder: (_, state, __) {
        return RepaintBoundary(
          child: CpuCard(state: state, onChanged: onChanged),
        );
      },
    );
  }
}

class _GpuSection extends StatelessWidget {
  const _GpuSection();

  @override
  Widget build(BuildContext context) {
    return Selector<HardwareMonitor, SystemState>(
      selector: (_, m) => m.state,
      shouldRebuild: (prev, next) =>
          prev.dgpuDisabled != next.dgpuDisabled ||
          prev.gpuMux != next.gpuMux ||
          prev.nvBoost != next.nvBoost ||
          prev.nvTemp != next.nvTemp,
      builder: (_, state, __) {
        return RepaintBoundary(
          child: GpuCard(state: state),
        );
      },
    );
  }
}

class _BatterySection extends StatelessWidget {
  final VoidCallback onChanged;

  const _BatterySection({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Selector<HardwareMonitor, SystemState>(
      selector: (_, m) => m.state,
      shouldRebuild: (prev, next) =>
          prev.batteryPercent != next.batteryPercent ||
          prev.batteryStatus != next.batteryStatus ||
          prev.powerDraw != next.powerDraw ||
          prev.chargeLimit != next.chargeLimit,
      builder: (_, state, __) {
        return RepaintBoundary(
          child: BatteryCard(state: state, onChanged: onChanged),
        );
      },
    );
  }
}

class _DisplaySection extends StatelessWidget {
  final VoidCallback onChanged;

  const _DisplaySection({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Selector<HardwareMonitor, SystemState>(
      selector: (_, m) => m.state,
      shouldRebuild: (prev, next) => prev.panelOd != next.panelOd,
      builder: (_, state, __) {
        return RepaintBoundary(
          child: DisplayCard(state: state, onChanged: onChanged),
        );
      },
    );
  }
}

class _KeyboardSection extends StatelessWidget {
  final VoidCallback onChanged;

  const _KeyboardSection({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Selector<HardwareMonitor, SystemState>(
      selector: (_, m) => m.state,
      shouldRebuild: (prev, next) => prev.kbdBrightness != next.kbdBrightness,
      builder: (_, state, __) {
        return RepaintBoundary(
          child: KeyboardCard(state: state, onChanged: onChanged),
        );
      },
    );
  }
}

class _MonitorSection extends StatelessWidget {
  const _MonitorSection();

  @override
  Widget build(BuildContext context) {
    return Selector<HardwareMonitor, SystemState>(
      selector: (_, m) => m.state,
      shouldRebuild: (prev, next) =>
          prev.cpuTemp != next.cpuTemp ||
          prev.fan1Rpm != next.fan1Rpm ||
          prev.fan2Rpm != next.fan2Rpm ||
          prev.fan3Rpm != next.fan3Rpm,
      builder: (_, state, __) {
        return RepaintBoundary(
          child: MonitorCard(state: state),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final footerData = context.select(
      (HardwareMonitor m) => (
        m.state.powerDraw,
        m.state.thermalName,
        m.state.cpuFreqMhz,
        m.state.cpuTemp,
      ),
    );
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${footerData.$1.toStringAsFixed(1)}W',
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${footerData.$2} · ${footerData.$3} MHz · ${footerData.$4}°C',
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
