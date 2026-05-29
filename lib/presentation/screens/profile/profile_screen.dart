import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_controller.dart';
import '../../widgets/module_page.dart';
import '../../widgets/section_panel.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_refreshProfile);
  }

  Future<void> _refreshProfile() {
    return ref.read(authControllerProvider.notifier).refreshCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: ModulePage(
        title: 'Profile',
        subtitle: 'Identity details synced from the active backend session.',
        actions: [
          IconButton.filledTonal(
            onPressed: authState.isRefreshingUser ? null : _refreshProfile,
            tooltip: 'Refresh profile',
            icon: authState.isRefreshingUser
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
        children: [
          if (authState.isRefreshingUser)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(),
            ),
          if (authState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Roles from backend',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (user?.resolvedRoles ?? const <String>['-'])
                        .map(
                          (role) => Chip(
                            label: Text(role.toUpperCase()),
                            avatar: const Icon(Icons.verified_user_rounded),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionPanel(
            title: 'Operator Details',
            child: Column(
              children: [
                _InfoRow(label: 'NIK', value: user?.nik ?? '-'),
                _InfoRow(
                  label: 'Primary Role',
                  value: user?.primaryRole.toUpperCase() ?? '-',
                ),
                _InfoRow(
                  label: 'All Roles',
                  value: user?.rolesLabel.toUpperCase() ?? '-',
                ),
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
      ),
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
