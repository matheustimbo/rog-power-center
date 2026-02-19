import 'package:flutter/material.dart';
import '../models/system_state.dart';
import '../services/sysfs_service.dart';
import 'status_card.dart';

class BatteryCard extends StatelessWidget {
  final SystemState state;
  final VoidCallback onChanged;

  const BatteryCard({super.key, required this.state, required this.onChanged});

  static final _sysfs = SysfsService();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color batColor;
    if (state.batteryPercent > 60) {
      batColor = Colors.green;
    } else if (state.batteryPercent > 20) {
      batColor = Colors.orange;
    } else {
      batColor = Colors.red;
    }

    return StatusCard(
      title: 'Battery',
      icon: Icons.battery_std,
      children: [
        StatusRow(
          label: 'Charge',
          value: '${state.batteryPercent}%  ${state.batteryStatus}',
          valueColor: batColor,
        ),
        if (state.powerDraw > 0)
          StatusRow(
            label: 'Power Draw',
            value: '${state.powerDraw.toStringAsFixed(1)}W',
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Limit',
                style: TextStyle(
                    fontSize: 11, color: scheme.onSurfaceVariant)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                ),
                child: Slider(
                  value: state.chargeLimit.toDouble().clamp(20, 100),
                  min: 20,
                  max: 100,
                  divisions: 16,
                  onChanged: (v) async {
                    await _sysfs.setChargeLimit(v.round());
                    onChanged();
                  },
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text('${state.chargeLimit}%',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface)),
            ),
          ],
        ),
      ],
    );
  }
}
