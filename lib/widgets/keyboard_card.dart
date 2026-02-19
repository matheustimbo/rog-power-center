import 'dart:io';
import 'package:flutter/material.dart';
import '../models/system_state.dart';
import '../services/sysfs_service.dart';
import 'status_card.dart';

class KeyboardCard extends StatefulWidget {
  final SystemState state;
  final VoidCallback onChanged;

  const KeyboardCard({super.key, required this.state, required this.onChanged});

  @override
  State<KeyboardCard> createState() => _KeyboardCardState();
}

class _KeyboardCardState extends State<KeyboardCard> {
  bool _lightbarOn = false;
  bool _hasAsusctl = false;

  @override
  void initState() {
    super.initState();
    _checkAsusctl();
  }

  Future<void> _checkAsusctl() async {
    try {
      final result = await Process.run('which', ['asusctl']);
      if (mounted) {
        setState(() => _hasAsusctl = result.exitCode == 0);
      }
    } catch (_) {}
  }

  Future<void> _toggleLightbar(bool on) async {
    try {
      final args = on
          ? ['aura', 'power', 'lightbar', '--awake']
          : ['aura', 'power', 'lightbar'];
      await Process.run('asusctl', args);
      if (mounted) setState(() => _lightbarOn = on);
    } catch (_) {}
  }

  static final _sysfs = SysfsService();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    const levels = ['Off', 'Low', 'Med', 'High'];
    final currentLevel = widget.state.kbdBrightness.clamp(0, 3);

    return StatusCard(
      title: 'Keyboard',
      icon: Icons.keyboard,
      children: [
        Text('Brightness',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Row(
          children: List.generate(4, (i) {
            final isActive = i == currentLevel;
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
                      await _sysfs.setKbdBrightness(i);
                      widget.onChanged();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        levels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
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
        if (_hasAsusctl) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lightbar',
                  style: TextStyle(
                      fontSize: 13, color: scheme.onSurfaceVariant)),
              Switch(
                value: _lightbarOn,
                onChanged: _toggleLightbar,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
