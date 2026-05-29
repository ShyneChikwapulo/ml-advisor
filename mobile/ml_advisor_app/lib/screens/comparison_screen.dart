import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/ml_model.dart';
import '../providers/model_provider.dart';
import '../utils/app_theme.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModelProvider>();
    final selected = provider.selectedForComparison;
    final all = provider.models;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Models'),
        actions: [
          if (selected.isNotEmpty)
            TextButton(
              onPressed: () => provider.clearComparison(),
              child: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: selected.isEmpty
          ? _SelectModelsView(models: all)
          : _ComparisonView(models: selected),
    );
  }
}

class _SelectModelsView extends StatelessWidget {
  final List<MlModel> models;
  const _SelectModelsView({required this.models});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModelProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Select 2-3 models to compare (${provider.selectedForComparison.length}/3)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: models.length,
            itemBuilder: (_, i) {
              final m = models[i];
              final isSelected =
                  provider.selectedForComparison.any((s) => s.id == m.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => provider.toggleComparison(m),
                  title: Text(m.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('Accuracy: ${(m.accuracy * 100).toStringAsFixed(0)}%'),
                  secondary: CircleAvatar(
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: const Icon(Icons.psychology, color: AppTheme.primary),
                  ),
                ),
              );
            },
          ),
        ),
        if (provider.selectedForComparison.length >= 2)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('View Comparison'),
            ),
          ),
      ],
    );
  }
}

class _ComparisonView extends StatelessWidget {
  final List<MlModel> models;
  const _ComparisonView({required this.models});

  static const _metrics = ['accuracy', 'f1Score', 'precision', 'recall'];
  static const _metricLabels = ['Accuracy', 'F1-Score', 'Precision', 'Recall'];
  static const _colors = [AppTheme.primary, AppTheme.success, AppTheme.warning];

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table
          const Text('Metrics Comparison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(
                  color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
              defaultColumnWidth: const FixedColumnWidth(110),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1)),
                  children: [
                    const _TCell('Metric', header: true),
                    ...models.map((m) => _TCell(m.name, header: true)),
                  ],
                ),
                ...List.generate(_metrics.length, (i) => TableRow(
                      children: [
                        _TCell(_metricLabels[i]),
                        ...models.map((m) => _TCell(
                            '${(_getValue(m, _metrics[i]) * 100).toStringAsFixed(1)}%')),
                      ],
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Bar Chart
          const Text('Visual Comparison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1.0,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final labels = ['Acc', 'F1', 'Prec', 'Rec'];
                        if (v.toInt() < labels.length) {
                          return Text(labels[v.toInt()],
                              style: const TextStyle(fontSize: 11));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) =>
                          Text('${(v * 100).toInt()}%', style: const TextStyle(fontSize: 10)),
                      reservedSize: 36,
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
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            spacing: 16,
            children: List.generate(models.length, (i) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: _colors[i % _colors.length],
                            borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 4),
                    Text(models[i].name, style: const TextStyle(fontSize: 12)),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

class _TCell extends StatelessWidget {
  final String text;
  final bool header;
  const _TCell(this.text, {this.header = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: header ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      );
}