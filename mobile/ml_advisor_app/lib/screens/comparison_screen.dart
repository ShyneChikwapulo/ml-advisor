import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/ml_model.dart';
import '../providers/model_provider.dart';
import '../utils/app_theme.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  // Local latch tracking whether the admin has actively deployed the matrix
  bool _showComparison = false;

  // Luxury UI Palette Cohesion Constants
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color matteBlackCanvas = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModelProvider>();
    final selected = provider.selectedForComparison;
    final all = provider.models;

    // Safety fallback: if elements are cleared, automatically reset visual view mode
    final displayComparison = _showComparison && selected.isNotEmpty;

    return Scaffold(
      backgroundColor: matteBlackCanvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── PREMIUM INTEGRATED TITLE HEADER WITH CONDITIONAL BACK NAVIGATION ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Back button acts as view-toggle if deep inside matrix evaluation
                        if (Navigator.canPop(context) || displayComparison) ...[
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                            onPressed: () {
                              if (displayComparison) {
                                setState(() => _showComparison = false);
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                          const SizedBox(width: 4),
                        ] else ...[
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayComparison ? 'METRIC CROSS-EVALUATION' : 'EMPIRICAL BENCHMARKS',
                                style: TextStyle(
                                  color: goldAccent.withOpacity(0.85),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayComparison ? 'Matrix Analysis' : 'Compare Models',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
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
                  if (selected.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.clear_all, color: goldAccent, size: 16),
                      label: const Text('RESET', style: TextStyle(color: goldAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      onPressed: () {
                        provider.clearComparison();
                        setState(() => _showComparison = false);
                      },
                    ),
                ],
              ),
            ),

            // ── CONDITIONAL SUB-VIEW MANAGER ────────────────────────────────────
            Expanded(
              child: !displayComparison
                  ? _SelectModelsView(models: all)
                  : _ComparisonView(models: selected),
            ),
          ],
        ),
      ),
      
      // ── LAUNCH COMPARISON SUB-OVERLAY SHINY BUTTON ────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selected.length >= 2 && !displayComparison
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.bolt_outlined, color: Colors.white, size: 18),
                label: Text(
                  'LAUNCH MATRIX BENCHMARK (${selected.length})',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                onPressed: () => setState(() => _showComparison = true),
              ),
            )
          : null,
    );
  }
}

// ── SUB-VIEW A: EMPIRICAL TELEMETRY MODEL MATRIX SELECTOR ─────────────────────
class _SelectModelsView extends StatelessWidget {
  final List<MlModel> models;
  const _SelectModelsView({required this.models});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModelProvider>();
    final currentCount = provider.selectedForComparison.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accent.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics_outlined, size: 16, color: AppTheme.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Select 2 to 3 architectural models to deploy inside the matrix evaluation profile ($currentCount/3 chosen).',
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120), // 120 padding clears the FAB overlay seamlessly
            itemCount: models.length,
            itemBuilder: (_, i) {
              final m = models[i];
              final isSelected = provider.selectedForComparison.any((s) => s.id == m.id);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.01),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.accent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                  ),
                ),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => provider.toggleComparison(m),
                  activeColor: AppTheme.accent,
                  checkColor: Colors.black,
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: Text(
                    m.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Baseline Test Validation Yield: ${(m.accuracy * 100).toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.white.withOpacity(0.03),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.psychology_outlined, 
                      color: isSelected ? AppTheme.accent : Colors.white38, 
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── SUB-VIEW B: HIGH FIDELITY CHART DATA INTERACTION MATRIX PANEL ──────────────
class _ComparisonView extends StatelessWidget {
  final List<MlModel> models;
  const _ComparisonView({required this.models});

  static const _metrics = ['accuracy', 'f1Score', 'precision', 'recall'];
  static const _metricLabels = ['Accuracy', 'F1-Score', 'Precision', 'Recall'];
  
  static const _colors = [AppTheme.primary, AppTheme.accent, Color(0xFFD4AF37)];

  double _getValue(MlModel m, String metric) {
    switch (metric) {
      case 'accuracy': return m.accuracy;
      case 'f1Score': return m.f1Score;
      case 'precision': return m.precision;
      case 'recall': return m.recall;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── SECTION 1: METRICS GLASS MATRIX TABLE ─────────────────────────
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'TABULAR TELEMETRY MATRIX',
              style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Table(
                  border: TableBorder.symmetric(
                    inside: BorderSide(color: Colors.white.withOpacity(0.04), width: 1),
                  ),
                  defaultColumnWidth: const FixedColumnWidth(115),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02)),
                      children: [
                        const _TCell('Evaluation Metric', header: true, isLabel: true),
                        ...models.map((m) => _TCell(m.name, header: true)),
                      ],
                    ),
                    ...List.generate(_metrics.length, (i) => TableRow(
                          children: [
                            _TCell(_metricLabels[i], isLabel: true),
                            ...models.map((m) => _TCell(
                                '${(_getValue(m, _metrics[i]) * 100).toStringAsFixed(1)}%')),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── SECTION 2: BAR CHART DISTRIBUTIONS OVERLAY PANEL ──────────────────
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'DYNAMIC MULTI-VARIABLE METRIC READOUTS',
              style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 230,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 1.0,
                        minY: 0.0,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: const Color(0xFF1E1E1E),
                            tooltipBorder: BorderSide(color: Colors.white.withOpacity(0.1)),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${_metricLabels[groupIndex]}\n',
                                const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11),
                                children: [
                                  TextSpan(
                                    text: '${(rod.toY * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(color: _colors[rodIndex % _colors.length], fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withOpacity(0.03),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final labels = ['Accuracy', 'F1-Score', 'Precision', 'Recall'];
                                if (v.toInt() >= 0 && v.toInt() < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(labels[v.toInt()],
                                        style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold)),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) => Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: Text('${(v * 100).toInt()}%', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.3))),
                              ),
                              reservedSize: 28,
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: List.generate(4, (metricIndex) {
                          return BarChartGroupData(
                            x: metricIndex,
                            barRods: List.generate(models.length, (modelIndex) {
                              return BarChartRodData(
                                toY: _getValue(models[modelIndex], _metrics[metricIndex]),
                                color: _colors[modelIndex % _colors.length],
                                width: 10,
                                borderRadius: BorderRadius.circular(4),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 1.0,
                                  color: Colors.white.withOpacity(0.02),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Dynamic Legend Row Map
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: List.generate(models.length, (i) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: _colors[i % _colors.length],
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: _colors[i % _colors.length].withOpacity(0.4), blurRadius: 4)
                                      ])),
                              const SizedBox(width: 8),
                              Text(
                                models[i].name, 
                                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CUSTOMIZED TABULAR MATRIX CELL ELEMENT ────────────────────────────────────
class _TCell extends StatelessWidget {
  final String text;
  final bool header;
  final bool isLabel;
  const _TCell(this.text, {this.header = false, this.isLabel = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: header ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
            color: header 
                ? (isLabel ? Colors.white70 : const Color(0xFFD4AF37)) 
                : (isLabel ? Colors.white60 : Colors.white),
          ),
        ),
      );
}