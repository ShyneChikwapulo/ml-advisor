import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/app_theme.dart';
import 'admin/admin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: Text(
                  (user?.displayName != null && user!.displayName!.trim().isNotEmpty 
                      ? user!.displayName!.trim()[0] 
                      : 'U').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(user?.displayName ?? 'User',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user?.email ?? '',
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user?.role.toUpperCase() ?? '',
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 24),
            // Options
            Card(
              child: Column(
                children: [
                  if (auth.isAdmin)
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings,
                          color: AppTheme.primary),
                      title: const Text('Admin Dashboard'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminDashboardScreen())),
                    ),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppTheme.primary),
                    title: const Text('About ML Advisor'),
                    subtitle: const Text('Version 1.0.0'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout',
                        style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      context.read<FavoritesProvider>().clear();
                      await context.read<AuthProvider>().logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}