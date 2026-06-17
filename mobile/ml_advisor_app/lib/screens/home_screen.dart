import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/reveal_drawer.dart';
import '../widgets/fluid_tab_bar.dart';
import 'model_library_screen.dart';
import 'comparison_screen.dart';
import 'recommendation_screen.dart';
import 'favorites_screen.dart';
import 'research_glossary_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'admin/admin_dashboard_screen.dart';

mixin HomeNavigator on State<HomeScreen> {
  void navigateToTab(int index);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with HomeNavigator {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<FavoritesProvider>().loadFavorites(auth.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RevealDrawer(
      child: Scaffold(
        extendBody: true, 
        backgroundColor: const Color(0xFF121212), // Grainy Matte Black base canvas
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: const [
            DashboardTab(),          
            ModelLibraryScreen(),    
            RecommendationScreen(),  
            ChatScreen(),            
            ProfileScreen(),         
          ],
        ),
        bottomNavigationBar: FluidTabBar(
          currentTab: _currentIndex,
          onTabChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.jumpToPage(index);
          },
        ),
      ),
    );
  }
}

// ── DASHBOARD TAB ───────────────────────────────────────────────────────────
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  // Custom local Gold accent color definition for easy manual tweaking
  static const Color goldAccent = Color(0xFFD4AF37); 

  // 🛠️ ADDED: Maps the current index safely to the correct local directory link
  String _getAvatarPath(int? index) {
    if (index == null || index < 0 || index > 10) return 'assets/images/avatars/avatar1.png';
    return 'assets/images/avatars/avatar${index + 1}.png';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Grainy Matte Black canvas
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: AppTheme.primary.withOpacity(0.9), // Reverted to theme blue background
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => RevealDrawer.of(context).toggle(),
            ),
            actions: [
              if (auth.isAdmin)
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings, color: goldAccent), // Highlighted Admin icon in gold
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  ),
                ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D2137), // Dark Navy
                      AppTheme.primary,  // Reverted back to App Theme Blue
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(72, 12, 20, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // ── Left Column: Welcome Metadata Text ──
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
                              ),
                              Text(
                                auth.user?.displayName ?? 'User',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24, // Slightly scaled down from 26 to fit layout cleanly
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                                ),
                                child: Text(
                                  (auth.user?.role ?? 'student').toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // ── Right Column: Dynamic System Avatar Node ──
                        Container(
                          margin: const EdgeInsets.only(bottom: 2), // Aligns perfectly along baseline bounds
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            color: goldAccent.withOpacity(0.2), 
                            shape: BoxShape.circle,
                            border: Border.all(color: goldAccent.withOpacity(0.4), width: 1),
                          ),
                          child: CircleAvatar(
                            radius: 26, // Gives a clean, polished 52px top-bar footprint
                            backgroundColor: Colors.white10,
                            backgroundImage: AssetImage(_getAvatarPath(auth.user?.avatarIndex)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'Quick Access',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 14),
                
                // Grid System mapping visual context cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero, // 👈 ADD THIS LINE to eliminate the hidden layout gap!
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.25,
                  children: [
                    QuickCard(
                      icon: Icons.psychology,
                      label: 'Browse Models',
                      imagePath: 'assets/images/browse_bg.jpg',
                      accentColor: AppTheme.accent, // Theme Bright Cyan Blue
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ModelLibraryScreen()),
                      ),
                    ),
                    QuickCard(
                      icon: Icons.compare_arrows,
                      label: 'Compare',
                      imagePath: 'assets/images/compare_bg.jpg',
                      accentColor: AppTheme.accent, // Gold Accent
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ComparisonScreen()),
                      ),
                    ),
                    QuickCard(
                      icon: Icons.favorite,
                      label: 'Favourites',
                      imagePath: 'assets/images/favorites_bg.jpg',
                      accentColor: AppTheme.accent, // Soft Magenta-Pink Pop
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                      ),
                    ),
                    QuickCard(
                      icon: Icons.menu_book,
                      label: 'Research',
                      imagePath: 'assets/images/research_bg.jpg',
                      accentColor: AppTheme.accent, // Gold Accent
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ResearchGlossaryScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'About the Dataset',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 14),
                
                // Glassmorphic Dataset Panel Layout
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04), // Soft frosted sheet transparency
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.article, color: AppTheme.accent, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Albattah & Alzahrani (2024)',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '8 ML models evaluated on the Unified Bug Dataset with 47,618 classes and 60 software metrics. LSTM achieves the highest accuracy at 87%.',
                              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13, height: 1.5),
                            ),
                            const SizedBox(height: 18),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                StatChip(label: '8 Models', icon: Icons.psychology),
                                StatChip(label: '47K Samples', icon: Icons.dataset),
                                StatChip(label: '60 Metrics', icon: Icons.analytics),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Premium Blue & Gold Top Performer Block Row
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: goldAccent.withOpacity(0.35)), // Gold Specular Border Trim
                    ),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Top Performer',
                                    style: TextStyle(color: goldAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'LSTM',
                                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '87% accuracy · F1: 0.61',
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                              ),
                              child: const Text(
                                'Deep Learning',
                                style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 11), // 👈 FIXED: Removed widgetAlignment parameter
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120), 
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── GLASSMORPHIC IMAGE QUICK CARD WIDGET ────────────────────────────────────
class QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String imagePath;
  final Color accentColor;
  final VoidCallback onTap;

  const QuickCard({
    super.key,
    required this.icon,
    required this.label,
    required this.imagePath,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Stack(
            children: [
              // 1. Background Context Image
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              // 2. Dark Vignette Overlay Mask
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.78),
                      ],
                    ),
                  ),
                ),
              ),
              // 3. Subtle Frosted Glass Sheet Blur
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                  child: Container(color: Colors.transparent),
                ),
              ),
              // 4. Content Foreground Interface Layer
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Accent Mini Icon Window Container
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor.withOpacity(0.35)),
                      ),
                      child: Icon(icon, color: accentColor, size: 22),
                    ),
                    // Bottom Core Label Text
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 1.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── GLASSMORPHIC STAT CHIP WIDGET ───────────────────────────────────────────
class StatChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const StatChip({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, color: DashboardTab.goldAccent, size: 18), // 👈 FIXED: Removed invalid const keyword
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}