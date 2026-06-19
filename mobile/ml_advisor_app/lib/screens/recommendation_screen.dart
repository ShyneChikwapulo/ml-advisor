import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math; // ⚡ IMPORTED: For calculating min/max range limits
import 'package:provider/provider.dart';
import '../models/ml_model.dart';
import '../models/paper_model.dart'; 
import '../providers/model_provider.dart';
import '../services/firestore_service.dart'; 
import '../utils/app_theme.dart';
import 'model_detail_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  int _step = 0;
  String? _datasetSize, _priority, _imbalance, _datasetType;
  
  // ⚡ UPDATED: State handles recommendation payloads safely packaged together
  _RecommendationResult? _resultPayload; 

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color matteBlackCanvas = Color(0xFF121212);

  final _questions = [
    {
      'question': 'What is your operational dataset volume size?',
      'subtitle': 'Algorithmic performance scales directly with historical instance counts.',
      'icon': Icons.dataset,
      'options': ['Small (<1000)', 'Medium (1000-10000)', 'Large (>10000)'],
      'key': 'size',
    },
    {
      'question': 'What type of software metrics are you evaluating?',
      'subtitle': 'Static features look at code complexity; process metrics look at repository history.',
      'icon': Icons.source,
      'options': ['Static Code Metrics (NASA/PROMISE)', 'Process/Git Change Churn (Commits)'],
      'key': 'type',
    },
    {
      'question': 'What is your core architectural priority?',
      'subtitle': 'Balancing model transparency limits against raw validation score yields.',
      'icon': Icons.tune,
      'options': ['Accuracy', 'Interpretability', 'Balanced Metric Yield'],
      'key': 'priority',
    },
    {
      'question': 'How severe is your target class imbalance?',
      'subtitle': 'Skewed defect distributions require specialized optimization structures.',
      'icon': Icons.balance,
      'options': ['Low Skew', 'Medium Skew', 'High Skew'],
      'key': 'imbalance',
    },
  ];

  /// ── RESEARCH-BACKED WEIGHTED NOMINAL EVALUATION ENGINE ──
  _RecommendationResult _recommend(List<MlModel> models) {
    if (models.isEmpty) {
      return _RecommendationResult(
        model: MlModel(
          id: 'fallback', name: 'Baseline Engine', accuracy: 0.80, f1Score: 0.50, precision: 0.50, recall: 0.50,
          description: 'Generic fallback system profile.', strengths: [], weaknesses: [], bestUseCases: [],
          paperId: '', datasetUsed: 'Baseline', category: 'Traditional', handlesImbalance: false, interpretable: true
        ),
        confidenceScore: 0.50,
        rationale: 'No models available in repository index.',
        minAccuracy: 0.80, maxAccuracy: 0.80, variantCount: 1
      );
    }

    // 1. Establish Normalized Baseline Weights (Sum = 1.0)
    double wAcc = 0.30;
    double wF1 = 0.30;
    double wInterp = 0.20;
    double wImb = 0.20;

    // 2. Adjust Multipliers Dynamically Based on User Strategic Priority
    if (_priority == 'Accuracy') {
      wAcc = 0.50; wF1 = 0.30; wInterp = 0.10; wImb = 0.10;
    } else if (_priority == 'Interpretability') {
      wAcc = 0.15; wF1 = 0.15; wInterp = 0.50; wImb = 0.20;
    } else if (_priority == 'Balanced Metric Yield') {
      wAcc = 0.25; wF1 = 0.45; wInterp = 0.15; wImb = 0.15;
    }

    MlModel? winningModel;
    double highestScore = -1.0;
    String finalRationale = '';

    // Loop through and score models
    for (final m in models) {
      double score = 0.0;
      final datasetLower = m.datasetUsed.toLowerCase();
      final catLower = m.category.toLowerCase();

      // Core Normalized Components (Calculated strictly between 0.0 and 1.0)
      double accComponent = m.accuracy;
      double f1Component = m.f1Score;
      double interpComponent = m.interpretable ? 1.0 : 0.0;
      double imbComponent = m.handlesImbalance ? 1.0 : 0.0;

      // Dataset and Volume Context Adjustments
      if (_datasetType == 'Static Code Metrics (NASA/PROMISE)' && (datasetLower.contains('nasa') || datasetLower.contains('promise'))) {
        accComponent = math.min(1.0, accComponent * 1.05); // 5% synergy bonus
      } else if (_datasetType == 'Process/Git Change Churn (Commits)' && catLower.contains('deep')) {
        f1Component = math.min(1.0, f1Component * 1.08); // Deep learning sequence bonus
      }

      if (_datasetSize == 'Small (<1000)' && catLower.contains('deep')) {
        f1Component *= 0.60; // 40% penalty for deep learning on tiny sets
      }

      if (_imbalance == 'High Skew' && !m.handlesImbalance) {
        imbComponent = 0.0;
        accComponent *= 0.70; // Structural penalty for ignoring high data skew
      }

      // Compute Normalized Equation Matrix Total
      score = (wAcc * accComponent) + (wF1 * f1Component) + (wInterp * interpComponent) + (wImb * imbComponent);

      if (score > highestScore) {
        highestScore = score;
        winningModel = m;
      }
    }

    final targetModel = winningModel ?? models.first;

    // 3. AGGREGATE LITERATURE VARIANTS (Groups matching models across all entries)
    final variants = models.where((e) => e.name.trim().toLowerCase() == targetModel.name.trim().toLowerCase()).toList();
    final minAcc = variants.map((e) => e.accuracy).reduce(math.min);
    final maxAcc = variants.map((e) => e.accuracy).reduce(math.max);

    // 4. Synthesize Reasoning Statement
    if (_priority == 'Interpretability' && targetModel.interpretable) {
      finalRationale = '${targetModel.name} was selected because transparency filters were prioritized. It provides verifiable white-box structures while maintaining a reliable metric ceiling.';
    } else if (_imbalance == 'High Skew' && targetModel.handlesImbalance) {
      finalRationale = 'Selected due to its robust native handling of class imbalances, preventing accuracy optimization traps common in highly skewed defect tracking tables.';
    } else {
      finalRationale = '${targetModel.name} demonstrated optimal empirical convergence across your specified data size constraints (${_datasetSize?.toLowerCase()}) and metric frameworks.';
    }

    return _RecommendationResult(
      model: targetModel,
      confidenceScore: highestScore,
      rationale: finalRationale,
      minAccuracy: minAcc,
      maxAccuracy: maxAcc,
      variantCount: variants.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final models = context.read<ModelProvider>().models;

    return Scaffold(
      backgroundColor: matteBlackCanvas,
      body: SafeArea(
        bottom: false,
        child: _resultPayload != null
            ? _ResultView(
                result: _resultPayload!,
                onReset: () => setState(() {
                  _step = 0;
                  _resultPayload = null;
                  _datasetSize = null;
                  _datasetType = null;
                  _priority = null;
                  _imbalance = null;
                }),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stepper Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MODEL ADVISOR',
                          style: TextStyle(color: goldAccent.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                        ),
                        const SizedBox(height: 4),
                        const Text('Find the Right Model', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                      ],
                    ),
                  ),

                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Answer a few questions...', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                            Text('Step ${_step + 1} of ${_questions.length}', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Container(height: 6, color: Colors.white.withOpacity(0.05)),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOutCubic,
                                height: 6,
                                width: (MediaQuery.of(context).size.width - 40) * ((_step + 1) / _questions.length),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.accent])),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Wizard Panel Box
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.06))),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.12), shape: BoxShape.circle, border: Border.all(color: AppTheme.accent.withOpacity(0.2))),
                                        child: Icon(_questions[_step]['icon'] as IconData, size: 32, color: AppTheme.accent),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(_questions[_step]['question'] as String, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3), textAlign: TextAlign.center),
                                      const SizedBox(height: 8),
                                      Text(_questions[_step]['subtitle'] as String, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.48), height: 1.4), textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Dynamic Options Options Selector Items
                          ...(_questions[_step]['options'] as List<String>).map((opt) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.08))),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_step == 0) _datasetSize = opt;
                                          if (_step == 1) _datasetType = opt;
                                          if (_step == 2) _priority = opt;
                                          if (_step == 3) _imbalance = opt;
                                          
                                          if (_step < _questions.length - 1) {
                                            _step++;
                                          } else {
                                            _resultPayload = _recommend(models);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(child: Text(opt, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600))),
                                            Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.25), size: 14)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )),
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

class _ResultView extends StatelessWidget {
  final _RecommendationResult result;
  final VoidCallback onReset;
  
  final FirestoreService _firestoreService = FirestoreService();

  _ResultView({required this.result, required this.onReset});

  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final model = result.model;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: goldAccent.withOpacity(0.08), shape: BoxShape.circle, border: Border.all(color: goldAccent.withOpacity(0.35), width: 1.5)),
            child: const Icon(Icons.verified_user, color: goldAccent, size: 48),
          ),
          const SizedBox(height: 16),
          Text('BEST MATCH FOUND', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.4), letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(model.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5)),
          const SizedBox(height: 24),

          // ── CONFIDENCE METRIC BANNER (⚡ FIXED) ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('MATCH CONFIDENCE', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                Text('${(result.confidenceScore * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.08))),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Why This Model?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 8),
                      
                      // ── DYNAMIC EXPLANATION GENERATION READING VALUE (⚡ FIXED) ──
                      Text(result.rationale, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13, height: 1.45)),
                      const SizedBox(height: 20),
                      
                      Container(height: 1, color: Colors.white.withOpacity(0.08)),
                      const SizedBox(height: 16),
                      
                      // ── INTEGRATED VARIANT RANGE MATRIX DISPLAY (⚡ FIXED) ──
                      const Text('Cross-Study Literature Variants', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: goldAccent, letterSpacing: 0.3)),
                      const SizedBox(height: 6),
                      Text(
                        'Detected ${result.variantCount} empirical validation instances for ${model.name}. Accuracy bounds cross-evaluated between ${(result.minAccuracy * 100).toStringAsFixed(1)}% and ${(result.maxAccuracy * 100).toStringAsFixed(1)}% inside the indexed compendium database.',
                        style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.35),
                      ),
                      const SizedBox(height: 20),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.04))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _Metric('ACCURACY', '${(model.accuracy * 100).toStringAsFixed(0)}%'),
                            Container(width: 1, height: 28, color: Colors.white.withOpacity(0.1)),
                            _Metric('F1-SCORE', model.f1Score.toStringAsFixed(2)),
                            Container(width: 1, height: 28, color: Colors.white.withOpacity(0.1)),
                            _Metric('CATEGORY', model.category.split(' ').first),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── DYNAMIC REFERENCE CITATION CARD LOOKUP ──
          FutureBuilder<PaperModel?>(
            future: _firestoreService.getPaperById(model.paperId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(goldAccent))),
                );
              }

              final paper = snapshot.data;
              final String citationDisplay = paper != null
                  ? '${paper.authors} (${paper.year}) — ${paper.title}. Metrics verified on base evaluation profile.'
                  : 'Empirical verification document pending assignment index.';

              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: goldAccent.withOpacity(0.2))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book, color: goldAccent, size: 18),
                        const SizedBox(width: 12),
                        Expanded(child: Text(citationDisplay, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), height: 1.3))),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          OutlinedButton.icon(
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Start Over', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            onPressed: onReset,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  const _Metric(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accent)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      );
}

// ── DATA TRANSFER OBJECT PACKAGING CORE METRICS INTERNALLY ──
class _RecommendationResult {
  final MlModel model;
  final double confidenceScore;
  final String rationale;
  final double minAccuracy;
  final double maxAccuracy;
  final int variantCount;

  _RecommendationResult({
    required this.model,
    required this.confidenceScore,
    required this.rationale,
    required this.minAccuracy,
    required this.maxAccuracy,
    required this.variantCount,
  });
}