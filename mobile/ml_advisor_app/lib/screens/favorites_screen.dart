import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../models/ml_model.dart'; 
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/model_provider.dart';
import '../utils/app_theme.dart';
import 'model_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // Luxury UI Palette Cohesion Constants
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color matteBlackCanvas = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final models = context.watch<ModelProvider>().models;
    final auth = context.watch<AuthProvider>();
    final favoriteModels = models.where((m) => favs.isFavorite(m.id)).toList();

    return Scaffold(
      backgroundColor: matteBlackCanvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PREMIUM INTEGRATED TITLE HEADER WITH CONDITIONAL BACK BUTTON ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 20, 8),
              child: Row(
                children: [
                  // Safe dynamic routing stack verification to eliminate black screen bugs
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                  ] else ...[
                    const SizedBox(width: 8), // Standard static side-margin compensation
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BOOKMARKED ARCHITECTURES',
                        style: TextStyle(
                          color: goldAccent.withOpacity(0.85),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'My Favourites',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── MAIN DATA CONTAINER MATRIX PANEL ────────────────────────────────
            Expanded(
              child: favoriteModels.isEmpty
                  ? const _EmptyFavoritesView()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                      itemCount: favoriteModels.length,
                      itemBuilder: (_, i) {
                        final m = favoriteModels[i];
                        return _GlassFavoriteCard(
                          model: m,
                          onRemove: () {
                            if (auth.user != null) {
                              favs.toggleFavorite(auth.user!.uid, m.id);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CUSTOM HIGH-FIDELITY GLASS FAVORITE TILED CARD ───────────────────────────
class _GlassFavoriteCard extends StatelessWidget {
  final MlModel model;
  final VoidCallback onRemove;

  const _GlassFavoriteCard({required this.model, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ModelDetailScreen(model: model)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Left Halo Avatar Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.psychology_outlined, color: AppTheme.accent, size: 22),
                    ),
                    const SizedBox(width: 16),
                    
                    // Main Core Text Information Fields
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Colors.white, 
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Accuracy: ${(model.accuracy * 100).toStringAsFixed(1)}% · ${model.category}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45), 
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Destructive Crimson Dismiss Bookmark Button
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 22),
                      splashRadius: 24,
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── CUSTOMIZED GLASS EMPTY STATE CONTAINER VIEW ──────────────────────────────
class _EmptyFavoritesView extends StatelessWidget {
  const _EmptyFavoritesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Icon(
                Icons.favorite_border_rounded, 
                size: 48, 
                color: const Color(0xFFD4AF37).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Dossier Archive Empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t benchmarked any favorite architectures yet. Tap the heart telemetry badge on any profile view screen to compile data points here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}