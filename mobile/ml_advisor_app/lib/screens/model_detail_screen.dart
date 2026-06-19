import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../models/ml_model.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/app_theme.dart';
import 'comparison_screen.dart';
import '../providers/model_provider.dart';
import '../services/firestore_service.dart';
import '../models/paper_model.dart';

class ModelDetailScreen extends StatelessWidget {
  final MlModel model;

  final FirestoreService _firestoreService = FirestoreService();

  ModelDetailScreen({super.key, required this.model});

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color matteBlackCanvas = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final favs = context.watch<FavoritesProvider>();
    final isFav = favs.isFavorite(model.id);

    return Scaffold(
      backgroundColor: matteBlackCanvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MODEL DETAILS',
                                style: TextStyle(
                                  color: goldAccent.withOpacity(0.85),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                model.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isFav ? Colors.pink.withOpacity(0.08) : Colors.white.withOpacity(0.03),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isFav ? Colors.pinkAccent.withOpacity(0.3) : Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.pinkAccent : Colors.white60,
                        size: 20,
                      ),
                      onPressed: () {
                        if (auth.user != null) {
                          favs.toggleFavorite(auth.user!.uid, model.id);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── SCROLLABLE CONTENT ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── METRICS ──
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'PERFORMANCE METRICS',
                        style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ),
                    
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _MetricCard('Accuracy', model.accuracy, AppTheme.primary),
                        _MetricCard('F1-Score', model.f1Score, AppTheme.accent),
                        _MetricCard('Precision', model.precision, const Color(0xFF673AB7)),
                        _MetricCard('Recall', model.recall, goldAccent),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── DESCRIPTION ──
                    _Section('Description', model.description),
                    const SizedBox(height: 24),

                    // ── STRENGTHS ──
                    if (model.strengths.isNotEmpty) ...[
                      _ListSection('Strengths', model.strengths, Icons.check_circle_outline, AppTheme.accent),
                      const SizedBox(height: 24),
                    ],

                    // ── WEAKNESSES ──
                    if (model.weaknesses.isNotEmpty) ...[
                      _ListSection('Limitations', model.weaknesses, Icons.cancel_outlined, Colors.redAccent.withOpacity(0.8)),
                      const SizedBox(height: 24),
                    ],

                    // ── USE CASES ──
                    if (model.bestUseCases.isNotEmpty) ...[
                      _ListSection('Best Use Cases', model.bestUseCases, Icons.radar_outlined, goldAccent),
                      const SizedBox(height: 28),
                    ],

                    // ── TAGS ──
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Tag('Category: ${model.category}', AppTheme.primary),
                        _Tag('Dataset: ${model.datasetUsed}', const Color(0xFF00E676)),
                        if (model.interpretable) _Tag('Interpretable', AppTheme.accent),
                        if (model.handlesImbalance) _Tag('Handles Imbalance', goldAccent),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── CITATION ──
                    FutureBuilder<PaperModel?>(
                      future: _firestoreService.getPaperById(model.paperId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 70,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(goldAccent)),
                          );
                        }

                        final paper = snapshot.data;
                        
                        final String citationDisplay = paper != null
                            ? '${paper.authors} (${paper.year}) — ${paper.title}'
                            : 'Research paper not found.';

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.06)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: goldAccent.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.menu_book_outlined, color: goldAccent, size: 18),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'RESEARCH PAPER',
                                          style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          citationDisplay,
                                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), height: 1.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── COMPARE BUTTON ──
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [AppTheme.primary.withOpacity(0.8), AppTheme.accent.withOpacity(0.8)],
                          ),
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.compare_arrows_outlined, color: Colors.white, size: 18),
                          label: const Text(
                            'ADD TO COMPARISON',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                          onPressed: () {
                            context.read<ModelProvider>().toggleComparison(model);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF1E1E1E),
                                content: Text(
                                  '${model.name} added to comparison.',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── METRIC CARD ──
class _MetricCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MetricCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 9, color: color.withOpacity(0.8), fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(value * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                value: value,
                backgroundColor: Colors.white.withOpacity(0.03),
                valueColor: AlwaysStoppedAnimation(color),
                strokeWidth: 3.5,
              ),
            ),
          ],
        ),
      );
}

// ── SECTION ──
class _Section extends StatelessWidget {
  final String title, content;
  const _Section(this.title, this.content);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.01),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Text(
              content,
              style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.5, fontSize: 13),
            ),
          ),
        ],
      );
}

// ── LIST SECTION ──
class _ListSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;
  const _ListSection(this.title, this.items, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.01),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              children: items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Icon(icon, color: color.withOpacity(0.8), size: 14),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item, 
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85), height: 1.3)
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
            ),
          ),
        ],
      );
}

// ── TAG ──
class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(color: color.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );
}