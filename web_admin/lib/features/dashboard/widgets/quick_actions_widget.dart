import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _QuickActionButton(
                  icon: Icons.person_add,
                  label: 'Add User',
                  color: Colors.blue,
                  onTap: () => context.go('/users'),
                ),
                const SizedBox(height: 12),
                _QuickActionButton(
                  icon: Icons.location_on,
                  label: 'Add Site',
                  color: Colors.green,
                  onTap: () => context.go('/sites'),
                ),
                const SizedBox(height: 12),
                _QuickActionButton(
                  icon: Icons.route,
                  label: 'Create Patrol',
                  color: Colors.orange,
                  onTap: () => context.go('/patrols'),
                ),
                const SizedBox(height: 12),
                _QuickActionButton(
                  icon: Icons.check_circle,
                  label: 'Add Checkpoint',
                  color: Colors.purple,
                  onTap: () => context.go('/checkpoints'),
                ),
                const SizedBox(height: 12),
                _QuickActionButton(
                  icon: Icons.monitor,
                  label: 'Live Monitor',
                  color: Colors.teal,
                  onTap: () => context.go('/monitoring'),
                ),
                const SizedBox(height: 12),
                _QuickActionButton(
                  icon: Icons.message,
                  label: 'Send Message',
                  color: Colors.indigo,
                  onTap: () => context.go('/messaging'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }
}
