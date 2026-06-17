import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../models/ml_model.dart';
import '../providers/model_provider.dart';
import '../utils/app_theme.dart';
import 'model_detail_screen.dart';

class ModelLibraryScreen extends StatefulWidget {
  const ModelLibraryScreen({super.key});

  @override
  State<ModelLibraryScreen> createState() => _ModelLibraryScreenState();
}

class _ModelLibraryScreenState extends State<ModelLibraryScreen> {
  String _search = '';
  String _filter = 'All';
  final _filters = ['All', 'Ensemble', 'Traditional', 'Deep Learning'];
  
  // Luxury UI Palette Cohesion Constants
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color matteBlackCanvas = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    final modelProvider = context.watch<ModelProvider>();
    final models = modelProvider.models.where((m) {
      final matchSearch = m.name.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filter == 'All' || m.category == _filter;
      return matchSearch && matchFilter;
    }).toList();

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
                  // Dynamically checks if screen can pop to prevent black screen crash bug
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                  ] else ...[
                    const SizedBox(width: 8), // Clean baseline alignment pad
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ARCHITECTURES',
                        style: TextStyle(
                          color: goldAccent.withOpacity(0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Model Library',
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

            // ── MODERN GLASSMORPHIC PILL SEARCH BAR ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), 
                  borderRadius: BorderRadius.circular(50), 
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500), 
                  cursorColor: AppTheme.primary,
                  decoration: InputDecoration(
                    hintText: 'Search algorithmic profiles...',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 14),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12.0, right: 4.0),
                      child: Icon(Icons.search, color: AppTheme.primary, size: 20),
                    ),
                    suffixIcon: _search.isNotEmpty 
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.black54, size: 16),
                              onPressed: () => setState(() { _search = ''; }),
                            ),
                          )
                        : null,
                    filled: false, 
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
              ),
            ),

            // ── HORIZONTAL CYBER-SEGMENTED FILTER ROW ───────────────────────────
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final filterItem = _filters[i];
                  final isSelected = _filter == filterItem;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = filterItem),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppTheme.primary.withOpacity(0.18) 
                            : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? AppTheme.accent.withOpacity(0.6) 
                              : Colors.white.withOpacity(0.08),
                          width: 1.2,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppTheme.accent.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ] : null,
                      ),
                      child: Text(
                        filterItem,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── MAIN CORE DATA MATRIX ARCHIVE ──────────────────────────────────
            Expanded(
              child: modelProvider.loading
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent)))
                  : models.isEmpty
                      ? Center(
                          child: Text(
                            'No matching neural frameworks found.',
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                          itemCount: models.length,
                          itemBuilder: (_, i) => _ModelCard(model: models[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CUSTOM HIGH-FIDELITY GLASS ARCHITECT CARD ────────────────────────────────
class _ModelCard extends StatelessWidget {
  final MlModel model;
  const _ModelCard({required this.model});

  Color get _categoryColor {
    switch (model.category) {
      case 'Ensemble': return const Color(0xFFD4AF37); 
      case 'Deep Learning': return AppTheme.accent;   
      default: return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            model.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _categoryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _categoryColor.withOpacity(0.3), width: 1),
                          ),
                          child: Text(
                            model.category.toUpperCase(),
                            style: TextStyle(
                              color: _categoryColor, 
                              fontSize: 9, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    Text(
                      model.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6), 
                        fontSize: 13, 
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    
                    Row(
                      children: [
                        _MetricPill(label: 'ACC', value: '${(model.accuracy * 100).toStringAsFixed(0)}%'),
                        const SizedBox(width: 8),
                        _MetricPill(label: 'F1', value: model.f1Score.toStringAsFixed(2)),
                        const Spacer(),
                        if (model.interpretable)
                          const _TagChip(label: 'INTERPRETABLE', color: AppTheme.success),
                        if (model.handlesImbalance)
                          const _TagChip(label: 'IMBALANCE OK', color: Color(0xFFD4AF37)), 
                      ],
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

class _MetricPill extends StatelessWidget {
  final String label, value;
  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(
              fontSize: 10, 
              color: Colors.white.withOpacity(0.4), 
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11, 
              color: AppTheme.accent, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color, 
          fontSize: 9, 
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}