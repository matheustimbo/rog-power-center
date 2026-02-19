import 'package:flutter/material.dart';
import '../models/system_state.dart';
import '../services/sysfs_service.dart';
import 'status_card.dart';

class DisplayCard extends StatelessWidget {
  final SystemState state;
  final VoidCallback onChanged;

  const DisplayCard({super.key, required this.state, required this.onChanged});

  static final _sysfs = SysfsService();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return StatusCard(
      title: 'Display',
      icon: Icons.monitor,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Panel Overdrive',
                style:
                    TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            Switch(
              value: state.panelOd,
              onChanged: (v) async {
                await _sysfs.setPanelOd(v);
                onChanged();
              },
            ),
          ],
        ),
        StatusRow(
          label: 'Mode',
          value: state.panelOd ? '165Hz Fast' : 'Standard',
        ),
      ],
    );
  }
}
