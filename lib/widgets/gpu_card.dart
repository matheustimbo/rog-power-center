import 'package:flutter/material.dart';
import '../models/system_state.dart';
import 'status_card.dart';

class GpuCard extends StatelessWidget {
  final SystemState state;

  const GpuCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return StatusCard(
      title: 'GPU',
      icon: Icons.videogame_asset,
      children: [
        StatusRow(label: 'dGPU (RTX)', value: state.dgpuStatus),
        StatusRow(label: 'MUX Mode', value: state.gpuMuxName),
        if (state.nvBoost > 0)
          StatusRow(label: 'NV Boost', value: '${state.nvBoost}W'),
        if (state.nvTemp > 0)
          StatusRow(label: 'NV Temp Target', value: '${state.nvTemp}°C'),
      ],
    );
  }
}
