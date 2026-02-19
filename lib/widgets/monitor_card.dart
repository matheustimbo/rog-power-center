import 'package:flutter/material.dart';
import '../models/system_state.dart';
import 'status_card.dart';

class MonitorCard extends StatelessWidget {
  final SystemState state;

  const MonitorCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color tempColor;
    if (state.cpuTemp < 60) {
      tempColor = Colors.green;
    } else if (state.cpuTemp < 80) {
      tempColor = Colors.orange;
    } else {
      tempColor = Colors.red;
    }

    return StatusCard(
      title: 'Temps & Fans',
      icon: Icons.thermostat,
      children: [
        StatusRow(
          label: 'CPU Package',
          value: '${state.cpuTemp}°C',
          valueColor: tempColor,
        ),
        const Divider(height: 16),
        StatusRow(label: 'Fan 1 (CPU)', value: '${state.fan1Rpm} RPM'),
        StatusRow(label: 'Fan 2 (GPU)', value: '${state.fan2Rpm} RPM'),
        StatusRow(label: 'Fan 3 (Aux)', value: '${state.fan3Rpm} RPM'),
      ],
    );
  }
}
