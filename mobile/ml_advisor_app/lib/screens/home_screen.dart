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
import '../services/firestore_service.dart';
// Remove the relative model imports and replace them with these absolute package routes:
import 'package:ml_advisor_app/models/paper_model.dart';
import 'package:ml_advisor_app/models/ml_model.dart';
import 'package:ml_advisor_app/services/firestore_service.dart';

import '../widgets/loading_overlay.dart';

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

// ── UPGRADED: DYNAMIC FEATURED DATASET DASHBOARD TAB ─────────────────────────
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  // Custom local Gold accent color definition
  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final FirestoreService _service = FirestoreService();
  
  PaperModel? _featuredPaper;
  MlModel? _topModel;
  int _linkedModelsCount = 0;
  bool _loadingSpotlight = true;

  @override
  void initState() {
    super.initState();
    _resolveFeaturedSpotlight();
  }

  Future<void> _resolveFeaturedSpotlight() async {
    try {
      // 1. Fetch all available academic publications safely from the server collection
      final papers = await _service.getPapers();
      if (papers.isEmpty) {
        setState(() => _loadingSpotlight = false);
        return;
      }

      // 2. Select one paper completely at random to anchor the snapshot feature row
      papers.shuffle();
      final selectedPaper = papers.first;

      // 3. Query all models and locate the ones evaluating this specific document ID
      final allModels = await _service.getModels();
      final linkedModels = allModels.where((m) => m.paperId == selectedPaper.id).toList();

      MlModel? bestPerformer;
      if (linkedModels.isNotEmpty) {
        // Sort descending by raw evaluation accuracy mapping parameters
        linkedModels.sort((a, b) => b.accuracy.compareTo(a.accuracy));
        bestPerformer = linkedModels.first;
      }

      setState(() {
        _featuredPaper = selectedPaper;
        _topModel = bestPerformer;
        _linkedModelsCount = linkedModels.length;
        _loadingSpotlight = false;
      });
    } catch (_) {
      setState(() => _loadingSpotlight = false);
    }
  }

  String _getAvatarPath(int? index) {
    if (index == null || index < 0 || index > 10) return 'assets/images/avatars/avatar1.png';
    return 'assets/images/avatars/avatar${index + 1}.png';
  }


  // Place this array structure inside your _DashboardTabState class:
  final List<Map<String, dynamic>> _quickAccessItems = [
    {
      'icon': Icons.psychology,
      'label': 'Browse Models',
      'imagePath': 'assets/images/browse_bg.jpg',
      'screen': const ModelLibraryScreen(),
    },
    {
      'icon': Icons.compare_arrows,
      'label': 'Compare',
      'imagePath': 'assets/images/compare_bg.jpg',
      'screen': const ComparisonScreen(),
    },
    {
      'icon': Icons.favorite,
      'label': 'Favourites',
      'imagePath': 'assets/images/favorites_bg.jpg',
      'screen': const FavoritesScreen(),
    },
    {
      'icon': Icons.menu_book,
      'label': 'Research',
      'imagePath': 'assets/images/research_bg.jpg',
      'screen': const ResearchGlossaryScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: AppTheme.primary.withOpacity(0.9),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => RevealDrawer.of(context).toggle(),
            ),
            actions: [
              if (auth.isAdmin)
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings, color: DashboardTab.goldAccent),
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
                    colors: [Color(0xFF0D2137), AppTheme.primary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(72, 12, 20, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Welcome back!!!,',
                                style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
                              ),
                              Text(
                                auth.user?.displayName ?? 'User',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
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
                        Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            color: DashboardTab.goldAccent.withOpacity(0.2), 
                            shape: BoxShape.circle,
                            border: Border.all(color: DashboardTab.goldAccent.withOpacity(0.4), width: 1),
                          ),
                          child: CircleAvatar(
                            radius: 26,
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
                
                // ── FUTURE-PROOF RESPONSIVE QUICK ACCESS GRID LAYER ─────────────────────────
                GridView.builder(
                  itemCount: _quickAccessItems.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180, // Dynamic max width target boundary allocation
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.25,  // Assures layout scale ratios remain proportional
                  ),
                  itemBuilder: (context, index) {
                    final item = _quickAccessItems[index];
                    
                    return QuickCard(
                      icon: item['icon'] as IconData,
                      label: item['label'] as String,
                      imagePath: item['imagePath'] as String,
                      accentColor: AppTheme.accent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => item['screen'] as Widget),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                
                const Text(
                  'Empirical Dataset Spotlight',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 14),
                
                // ── DYNAMIC SPOTLIGHT LAYER ENGINE ───────────────────────────
                if (_loadingSpotlight)
                  Container(
                    height: 150,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(DashboardTab.goldAccent)),
                  )
                else if (_featuredPaper == null)
                  _buildStaticFallbackCard()
                else ...[
                  // Dynamic Frosted Glass Dataset Overview Block
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
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
                                  Expanded(
                                    child: Text(
                                      _featuredPaper!.authors,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _featuredPaper!.title,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _featuredPaper!.keyFindings,
                                style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13, height: 1.5),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 18),

                              // ── UPDATED RESPONSIVE STAT CHIP ROW ───────────────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: StatChip(
                                      label: '$_linkedModelsCount Architectures', 
                                      icon: Icons.psychology
                                    ),
                                  ),
                                  Expanded(
                                    child: StatChip(
                                      label: '${_featuredPaper!.year}', 
                                      icon: Icons.calendar_today
                                    ),
                                  ),
                                  const Expanded(
                                    child: StatChip(
                                      label: 'Verified Corpus', 
                                      icon: Icons.verified_user
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Dynamic Premium Top Performer Ribbon Block
                  if (_topModel != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: DashboardTab.goldAccent.withOpacity(0.35)),
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
                                        'Top Performer for Dataset',
                                        style: TextStyle(color: DashboardTab.goldAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _topModel!.name,
                                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        // ⚡ FIXED: Dynamic evaluation dataset link injected right out of the schema model field
                                        'Target Dataset: ${_topModel!.datasetUsed.isNotEmpty ? _topModel!.datasetUsed : "Unified Corpus"}',
                                        style: TextStyle(color: DashboardTab.goldAccent.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        // ⚡ FIXED: Scales decimal fractions straight out of double parsing to tidy percentages
                                        'Accuracy: ${(_topModel!.accuracy <= 1.0 ? _topModel!.accuracy * 100 : _topModel!.accuracy).toStringAsFixed(1)}% · F1: ${_topModel!.f1Score}',
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
                                  child: Text(
                                    _topModel!.category,
                                    style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.01),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.04)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white38, size: 16),
                          SizedBox(width: 8),
                          // ── FIXED: Wrapped with Expanded to allow text wrapping inside constraints ──
                          Expanded(
                            child: Text(
                              'Architectural metrics pending assignment analysis.',
                              style: TextStyle(
                                color: Colors.white38, 
                                fontSize: 12, 
                                fontStyle: FontStyle.italic
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 120), 
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticFallbackCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white.withOpacity(0.02),
        child: const Text(
          'Compile research nodes inside the administrator dashboard tab panel to populate telemetry readout metrics.',
          style: TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
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

// ── GLASSMORPHIC STAT CHIP WIDGET (OVERFLOW PROOF) ───────────────────────────
class StatChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const StatChip({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, color: DashboardTab.goldAccent, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center, // Keeps alignment solid when truncated
          maxLines: 1, // Restricts horizontal expansion
          overflow: TextOverflow.ellipsis, // Truncates text with trailing dots safely
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