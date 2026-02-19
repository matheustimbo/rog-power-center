import 'package:flutter/material.dart';
import '../models/power_profile.dart';

class ProfileSelector extends StatelessWidget {
  final int currentThermal;
  final ValueChanged<PowerProfile> onProfileSelected;

  const ProfileSelector({
    super.key,
    required this.currentThermal,
    required this.onProfileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PowerProfile.profiles.map((profile) {
        final isActive = profile.thermalPolicy == currentThermal;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _ProfileButton(
              label: profile.name,
              icon: _iconFor(profile.name),
              isActive: isActive,
              onTap: () => onProfileSelected(profile),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'Silent':
        return Icons.battery_saver;
      case 'Daily':
        return Icons.balance;
      case 'Gaming':
        return Icons.sports_esports;
      default:
        return Icons.settings;
    }
  }
}

class _ProfileButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: isActive ? scheme.primaryContainer : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: isActive
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
