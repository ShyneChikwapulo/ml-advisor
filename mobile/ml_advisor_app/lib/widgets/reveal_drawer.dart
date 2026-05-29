// lib/widgets/reveal_drawer.dart
// 3D Scale-Down Reveal Drawer — Flutter equivalent of the HTML/CSS demo
// Drop this widget anywhere you want the sliding reveal menu effect.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/app_theme.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/home_screen.dart';

class RevealDrawer extends StatefulWidget {
  final Widget child;
  const RevealDrawer({super.key, required this.child});

  @override
  State<RevealDrawer> createState() => RevealDrawerState();

  /// Access the drawer state from anywhere in the subtree
  static RevealDrawerState of(BuildContext context) {
    return context.findAncestorStateOfType<RevealDrawerState>()!;
  }
}

class RevealDrawerState extends State<RevealDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _radiusAnim;

  bool get isOpen => _controller.value > 0.5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    // Slide: 0 → 65% of screen width
    _slideAnim = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.16, 1, 0.3, 1), // matches CSS cubic-bezier
    );

    // Scale: 1.0 → 0.82
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Border radius: 0 → 32
    _radiusAnim = Tween<double>(begin: 0, end: 32).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggle() {
    if (isOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  void close() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final slideDistance = size.width * 0.65;

    return Stack(
      children: [
        // ── LAYER 1: MENU PANEL (Back) ──────────────────────────────
        const _MenuPanel(),

        // ── LAYER 2: THE "GHOST" STACKED PAGE (Middle) ──────────────
        // This is the new part that peeks out
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()
                // Slide it slightly less than the main screen
                ..translate(_slideAnim.value * (slideDistance * 0.90))
                // Scale it slightly smaller than the main screen
                ..scale(_scaleAnim.value - 0.08), 
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_radiusAnim.value),
                child: Container(
                  // We use a semi-transparent version of your background 
                  // or a solid color to make it look like a "page"
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            );
          },
        ),

        // ── LAYER 3: MAIN SCREEN (Front) ────────────────────────────
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()
                ..translate(_slideAnim.value * slideDistance)
                ..scale(_scaleAnim.value),
              alignment: Alignment.centerLeft,
              child: Container(
                // Adding a subtle shadow makes the "stack" pop
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_controller.value * 0.2),
                      blurRadius: 20,
                      offset: const Offset(-10, 0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_radiusAnim.value),
                  child: Stack(
                    children: [
                      child!,
                      if (_controller.value > 0)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: close,
                            child: Container(
                              color: Colors.black.withOpacity(
                                  (_controller.value * 0.15).clamp(0, 0.15)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ],
    );
  }
}

// ── MENU PANEL ─────────────────────────────────────────────────────────────
// Replace the entire _MenuPanel class with this:
class _MenuPanel extends StatelessWidget {
  const _MenuPanel();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D2137), Color(0xFF1565C0)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Profile section
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        (user?.displayName != null && user!.displayName!.trim().isNotEmpty 
                            ? user!.displayName!.trim()[0] 
                            : 'U').toUpperCase(),
                          style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.role == 'admin'
                              ? 'Administrator'
                              : user?.role == 'developer'
                                  ? 'Developer'
                                  : 'University Student',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Menu items — these change the bottom nav index
              _MenuItem(
                icon: Icons.home_outlined,
                label: 'Home',
                onTap: () {
                  RevealDrawer.of(context).close();
                  context.findAncestorStateOfType<HomeNavigator>()?.navigateToTab(0);
                },
              ),
              _MenuItem(
                icon: Icons.psychology_outlined,
                label: 'Model Library',
                onTap: () {
                  RevealDrawer.of(context).close();
                  context.findAncestorStateOfType<HomeNavigator>()?.navigateToTab(1);
                },
              ),
              _MenuItem(
                icon: Icons.lightbulb_outline,
                label: 'Get Recommendation',
                onTap: () {
                  RevealDrawer.of(context).close();
                  context.findAncestorStateOfType<HomeNavigator>()?.navigateToTab(2);
                },
              ),
              _MenuItem(
                icon: Icons.chat_bubble_outline,
                label: 'AI Chat',
                onTap: () {
                  RevealDrawer.of(context).close();
                  context.findAncestorStateOfType<HomeNavigator>()?.navigateToTab(3);
                },
              ),
              _MenuItem(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () {
                  RevealDrawer.of(context).close();
                  context.findAncestorStateOfType<HomeNavigator>()?.navigateToTab(4);
                },
              ),
              if (auth.isAdmin)
                _MenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Admin Dashboard',
                  onTap: () {
                    RevealDrawer.of(context).close();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminDashboardScreen()),
                    );
                  },
                ),

              const Spacer(),

              // Divider(color: Colors.white.withOpacity(0.15)),
              const SizedBox(height: 8),

              _MenuItem(
                icon: Icons.logout,
                label: 'Logout',
                color: Colors.redAccent.shade100,
                onTap: () async {
                  context.read<FavoritesProvider>().clear();
                  await context.read<AuthProvider>().logout();
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white.withOpacity(0.85);
    return Material(
      color: Colors.transparent, // 2. KEEP IT TRANSPARENT
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: c,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}