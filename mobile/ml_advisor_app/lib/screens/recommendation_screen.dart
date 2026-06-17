import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../models/ml_model.dart';
import '../providers/model_provider.dart';
import '../utils/app_theme.dart';
import 'model_detail_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  int _step = 0;
  String? _datasetSize, _priority, _imbalance;
  MlModel? _result;

  // Luxury UI Palette Cohesion Constants
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
      'question': 'What is your core architectural priority?',
      'subtitle': 'Balancing model transparency limits against raw validation score yields.',
      'icon': Icons.tune,
      'options': ['Accuracy', 'Interpretability', 'Balanced'],
      'key': 'priority',
    },
    {
      'question': 'How severe is your target class imbalance?',
      'subtitle': 'Skewed distributions require specialized optimization capabilities.',
      'icon': Icons.balance,
      'options': ['Low', 'Medium', 'High'],
      'key': 'imbalance',
    },
  ];

  /// ── DYNAMIC MATRIX EVALUATION SCORING ENGINE ──
  /// Completely agnostic to hardcoded model IDs. Evaluates live telemetry properties.
  MlModel _recommend(List<MlModel> models) {
    if (models.isEmpty) {
      // Emergency failsafe to prevent runtime drops if database is completely wiped
      return MlModel(
        id: 'fallback',
        name: 'Baseline Engine',
        accuracy: 0.80,
        f1Score: 0.50,
        precision: 0.50,
        recall: 0.50,
        description: 'Generic database model fallback profile.',
        strengths: ['Failsafe recovery active'],
        weaknesses: ['Non-optimized telemetry metrics'],
        bestUseCases: ['System diagnostic triage'],
        category: 'Traditional',
        handlesImbalance: false,
        interpretable: true,
      );
    }

    MlModel? bestModel;
    double highestScore = -999.0;

    for (final m in models) {
      double score = 0.0;

      // 1. Evaluate Core Architectural Priority Match
      if (_priority == 'Interpretability') {
        if (m.interpretable) score += 15.0; // Massive preference boost for transparent architectures
      } else if (_priority == 'Accuracy') {
        score += m.accuracy * 10.0; // Strongly scale recommendation with raw accuracy bias
      } else if (_priority == 'Balanced') {
        score += (m.accuracy + m.f1Score) * 5.0; // Weigh harmonic metrics evenly
      }

      // 2. Evaluate Operational Dataset Volume Constraints
      if (_datasetSize == 'Small (<1000)') {
        if (m.category.toLowerCase().contains('deep')) {
          score -= 10.0; // Heavily penalize data-hungry deep learning architectures (overfitting risk)
        } else if (m.category.toLowerCase().contains('traditional')) {
          score += 5.0; // Favor lightweight traditional models (like SVM or LogReg)
        }
      } else if (_datasetSize == 'Large (>10000)') {
        if (m.category.toLowerCase().contains('deep')) {
          score += 8.0; // Reward deep neural nets optimized for heavy data parallelization
        }
      }

      // 3. Evaluate Target Component Class Imbalance Resilience
      if (_imbalance == 'High') {
        if (m.handlesImbalance) {
          score += 12.0; // Maximize weight matching for models designed for skewed data
        }
      } else if (_imbalance == 'Medium') {
        if (m.handlesImbalance) score += 4.0;
      }

      // 4. Micro-Stabilizer Tiebreaker
      // If two distinct architectural options score identically on criteria, favor the higher yield asset
      score += m.accuracy;

      if (score > highestScore) {
        highestScore = score;
        bestModel = m;
      }
    }

    return bestModel ?? models.first;
  }

  @override
  Widget build(BuildContext context) {
    final models = context.read<ModelProvider>().models;

    return Scaffold(
      backgroundColor: matteBlackCanvas,
      body: SafeArea(
        bottom: false,
        child: _result != null
            ? _ResultView(
                model: _result!,
                onReset: () => setState(() {
                  _step = 0;
                  _result = null;
                  _datasetSize = null;
                  _priority = null;
                  _imbalance = null;
                }),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── PREMIUM INTEGRATED STEPPER HEADER ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DECISION MATRIX ENGINE',
                          style: TextStyle(
                            color: goldAccent.withOpacity(0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ML Model Advisor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── ANCHORED CYBER NEON PROGRESS TRACKER ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Analyzing telemetry criteria...',
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                            ),
                            Text(
                              'Step ${_step + 1} of ${_questions.length}',
                              style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Container(
                                height: 6,
                                color: Colors.white.withOpacity(0.05),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOutCubic,
                                height: 6,
                                width: MediaQuery.of(context).size.width * ((_step + 1) / _questions.length) - 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.primary, AppTheme.accent],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── FLOATING WIZARD FRAMEWORK COMPONENT PANEL ──────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.06)),
                              ),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
                                        ),
                                        child: Icon(
                                          _questions[_step]['icon'] as IconData,
                                          size: 32,
                                          color: AppTheme.accent,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        _questions[_step]['question'] as String,
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _questions[_step]['subtitle'] as String,
                                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.48), height: 1.4),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── HIGH-FIDELITY OPTION CHIP SELECTORS ───────────────────────
                          ...(_questions[_step]['options'] as List<String>).map((opt) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_step == 0) _datasetSize = opt;
                                          if (_step == 1) _priority = opt;
                                          if (_step == 2) _imbalance = opt;
                                          if (_step < _questions.length - 1) {
                                            _step++;
                                          } else {
                                            _result = _recommend(models);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              opt,
                                              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white.withOpacity(0.25),
                                              size: 14,
                                            )
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

// ── CUSTOM HIGH-FIDELITY RECOMMENDATION DOSSIER VIEW ───────────────────────────
class _ResultView extends StatelessWidget {
  final MlModel model;
  final VoidCallback onReset;
  const _ResultView({required this.model, required this.onReset});

  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: goldAccent.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: goldAccent.withOpacity(0.35), width: 1.5),
            ),
            child: const Icon(Icons.verified_user, color: goldAccent, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'OPTIMAL MATCH FOUND',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.4), letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            model.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 24),

          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Architectural Rationale',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        model.description,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      
                      Container(height: 1, color: Colors.white.withOpacity(0.08)),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Evaluated Operational Strengths',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: goldAccent, letterSpacing: 0.3),
                      ),
                      const SizedBox(height: 12),
                      ...model.strengths.take(3).map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2.0),
                                  child: Icon(Icons.bolt, color: AppTheme.accent, size: 15),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    s,
                                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.75), height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 20),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.04)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _Metric('ACCURACY', '${(model.accuracy * 100).toStringAsFixed(0)}%'),
                            Container(width: 1, height: 28, color: Colors.white.withOpacity(0.1)),
                            _Metric('F1-SCORE', model.f1Score.toStringAsFixed(2)),
                            Container(width: 1, height: 28, color: Colors.white.withOpacity(0.1)),
                            _Metric('ENGINE', model.category.split(' ').first),
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

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: goldAccent.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book, color: goldAccent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dataset empirical source logic provided by Albattah & Alzahrani (2024) evaluation protocols.',
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          OutlinedButton.icon(
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('RESET MATRIX LOGIC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
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
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accent),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      );
}