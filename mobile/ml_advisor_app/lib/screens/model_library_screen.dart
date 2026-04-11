import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final modelProvider = context.watch<ModelProvider>();
    final models = modelProvider.models.where((m) {
      final matchSearch =
          m.name.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filter == 'All' || m.category == _filter;
      return matchSearch && matchFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Model Library')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search models...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final selected = _filter == f;
                return FilterChip(
                  label: Text(f),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: AppTheme.primary.withOpacity(0.2),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: modelProvider.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: models.length,
                    itemBuilder: (_, i) => _ModelCard(model: models[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final MlModel model;
  const _ModelCard({required this.model});

  Color get _categoryColor {
    switch (model.category) {
      case 'Ensemble': return AppTheme.success;
      case 'Deep Learning': return AppTheme.secondary;
      default: return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ModelDetailScreen(model: model)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(model.name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(model.category,
                        style: TextStyle(color: _categoryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(model.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetricPill(label: 'Acc', value: '${(model.accuracy * 100).toStringAsFixed(0)}%'),
                  const SizedBox(width: 8),
                  _MetricPill(label: 'F1', value: model.f1Score.toStringAsFixed(2)),
                  const Spacer(),
                  if (model.interpretable)
                    const _TagChip(label: 'Interpretable', color: AppTheme.success),
                  if (model.handlesImbalance)
                    const _TagChip(label: 'Imbalance OK', color: AppTheme.warning),
                ],
              ),
            ],
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$label: $value',
            style: const TextStyle(
                fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
      );
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      );
}