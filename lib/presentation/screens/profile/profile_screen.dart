import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_controller.dart';
import '../../widgets/module_page.dart';
import '../../widgets/section_panel.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).user;

    return ModulePage(
      title: 'Profile',
      subtitle: 'Identity details for the current warehouse operator.',
      children: [
        SectionPanel(
          title: 'Account Overview',
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 38,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(user?.name ?? '-', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(user?.email ?? '-', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionPanel(
          title: 'Operator Details',
          child: Column(
            children: [
              _InfoRow(label: 'NIK', value: user?.nik ?? '-'),
              _InfoRow(label: 'Role', value: user?.role.toUpperCase() ?? '-'),
              _InfoRow(label: 'Email', value: user?.email ?? '-'),
              _InfoRow(label: 'Status', value: 'Active Session'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionPanel(
          title: 'Session Controls',
          child: FilledButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
