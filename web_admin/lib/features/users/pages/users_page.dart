import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/user_list_widget.dart';
import '../widgets/create_user_dialog.dart';
import '../../../shared/widgets/rbac/permission_widgets.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with actions
            Row(
              children: [
                Text(
                  'Users',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                PermissionGuard(
                  requiredRoles: Permissions.userCreate,
                  child: FilledButton.icon(
                    onPressed: () => _showCreateUserDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Users List
            const Expanded(
              child: UserListWidget(),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateUserDialog(),
    );
  }
}