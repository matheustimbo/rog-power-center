import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final monitor = context.watch<HardwareMonitor>();
    final state = monitor.state;
    final profileManager = ProfileManager();
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
            child: Chip(
              label: Text(
                state.profileName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              backgroundColor: scheme.primaryContainer,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            child: Column(
              children: [
                ProfileSelector(
                  currentThermal: state.thermalPolicy,
                  onProfileSelected: (profile) async {
                    await profileManager.applyProfile(profile);
                    monitor.refresh();
                  },
                ),
                const SizedBox(height: 12),
                if (constraints.maxWidth > 520)
                  _buildWideLayout(state, monitor)
                else
                  _buildNarrowLayout(state, monitor),
                const SizedBox(height: 8),
                _buildFooter(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(state, HardwareMonitor monitor) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: CpuCard(state: state, onChanged: monitor.refresh)),
              const SizedBox(width: 10),
              Expanded(child: GpuCard(state: state)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: BatteryCard(state: state, onChanged: monitor.refresh)),
              const SizedBox(width: 10),
              Expanded(child: DisplayCard(state: state, onChanged: monitor.refresh)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: KeyboardCard(state: state, onChanged: monitor.refresh)),
              const SizedBox(width: 10),
              Expanded(child: MonitorCard(state: state)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(state, HardwareMonitor monitor) {
    return Column(
      children: [
        CpuCard(state: state, onChanged: monitor.refresh),
        const SizedBox(height: 10),
        GpuCard(state: state),
        const SizedBox(height: 10),
        BatteryCard(state: state, onChanged: monitor.refresh),
        const SizedBox(height: 10),
        DisplayCard(state: state, onChanged: monitor.refresh),
        const SizedBox(height: 10),
        KeyboardCard(state: state, onChanged: monitor.refresh),
        const SizedBox(height: 10),
        MonitorCard(state: state),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, state) {
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
            '${state.powerDraw.toStringAsFixed(1)}W',
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${state.thermalName} · ${state.cpuFreqMhz} MHz · ${state.cpuTemp}°C',
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
