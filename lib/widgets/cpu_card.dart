import 'package:flutter/material.dart';
import '../models/system_state.dart';
import '../services/sysfs_service.dart';
import 'status_card.dart';

class CpuCard extends StatelessWidget {
  final SystemState state;
  final VoidCallback onChanged;

  const CpuCard({super.key, required this.state, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sysfs = SysfsService();

    return StatusCard(
      title: 'CPU',
      icon: Icons.memory,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Boost', style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            Switch(
              value: state.cpuBoost,
              onChanged: (v) async {
                await sysfs.setCpuBoost(v);
                onChanged();
              },
            ),
          ],
        ),
        StatusRow(label: 'Governor', value: state.governor),
        StatusRow(
          label: 'Frequency',
          value: '${state.cpuFreqMhz} MHz',
        ),
        const SizedBox(height: 8),
        _buildEppSelector(context, sysfs, scheme),
        const SizedBox(height: 8),
        _buildPptSlider(context, 'PL1', state.pptPl1, 5, 125, (v) async {
          await sysfs.setPptPl1(v.round());
          onChanged();
        }),
        _buildPptSlider(context, 'PL2', state.pptPl2, 5, 150, (v) async {
          await sysfs.setPptPl2(v.round());
          onChanged();
        }),
      ],
    );
  }

  Widget _buildEppSelector(
      BuildContext context, SysfsService sysfs, ColorScheme scheme) {
    const options = ['power', 'balance_power', 'balance_performance', 'performance'];
    const labels = ['Power', 'Bal-Pwr', 'Bal-Perf', 'Perf'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EPP', style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Row(
          children: List.generate(options.length, (i) {
            final isActive = state.epp == options[i];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Material(
                  color: isActive
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      await sysfs.setEpp(options[i]);
                      onChanged();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.w500,
                          color: isActive
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPptSlider(BuildContext context, String label, int value,
      double min, double max, ValueChanged<double> onChanged) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(label,
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: value.toDouble().clamp(min, max),
              min: min,
              max: max,
              divisions: ((max - min) / 5).round(),
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text('${value}W',
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface)),
        ),
      ],
    );
  }
}
