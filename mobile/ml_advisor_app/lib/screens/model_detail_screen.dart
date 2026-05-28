import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ml_model.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/model_provider.dart';
import '../utils/app_theme.dart';
import 'comparison_screen.dart';

class ModelDetailScreen extends StatelessWidget {
  final MLModel model;

  const ModelDetailScreen({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthDataProvider>();
    final favs = context.watch<FavoritesProvider>();

    final isFav = favs.isFavorite(model.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(model.name),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.white,
            ),
            onPressed: () {
              if (auth.user != null) {
                favs.toggleFavorite(
                  auth.user!.uid,
                  model.id,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Performance metrics
            const Text(
              'Performance Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _MetricCard(
                  'Accuracy',
                  model.accuracy,
                  AppWideTheme.primaryColour,
                ),
                _MetricCard(
                  'F1-Score',
                  model.f1Score,
                  AppWideTheme.successColour,
                ),
                _MetricCard(
                  'Precision',
                  model.precision,
                  AppWideTheme.secondaryColour,
                ),
                _MetricCard(
                  'Recall',
                  model.recall,
                  AppWideTheme.warningColour,
                ),
              ],
            ),

            const SizedBox(height: 20),

            _Section(
              'Description',
              model.description,
            ),

            const SizedBox(height: 16),

            _ListSection(
              'Strengths',
              model.strengths,
              Icons.check_circle,
              AppWideTheme.successColour,
            ),

            const SizedBox(height: 16),

            _ListSection(
              'Weaknesses',
              model.weaknesses,
              Icons.cancel,
              AppWideTheme.errorColour,
            ),

            const SizedBox(height: 16),

            _ListSection(
              'Best Use Cases',
              model.bestUseCases,
              Icons.star,
              AppWideTheme.warningColour,
            ),

            const SizedBox(height: 16),

            // Tags
            Wrap(
              spacing: 8,
              children: [
                _Tag(
                  'Category: ${model.category}',
                  AppWideTheme.secondaryColour,
                ),
                if (model.interpretable)
                  _Tag(
                    'Interpretable',
                    AppWideTheme.successColour,
                  ),
                if (model.handlesImbalance)
                  _Tag(
                    'Handles Imbalance',
                    AppWideTheme.warningColour,
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Citation
            Card(
              color: AppWideTheme.primaryColour.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.article,
                      color: AppWideTheme.primaryColour,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Albattah & Alzahrani (2024) — Unified Bug Dataset, 47,618 classes',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppWideTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(
                  Icons.compare_arrows,
                ),
                label: const Text(
                  'Add to Comparison',
                ),
                onPressed: () {
                  context.read<ModelDataProvider>().toggleomparison(model);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${model.name} added to comparison',
                      ),
                    ),
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

class _MetricCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MetricCard(
    this.label,
    this.value,
    this.color,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1)
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(value * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          CircularProgressIndicator(
            value: value,
            backgroundColor: color.withValues(alpha: 0.2)
            valueColor: AlwaysStoppedAnimation(color),
            strokeWidth: 4,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section(this.title, this.content);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(
            color: AppWideTheme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  const _ListSection(
    this.title,
    this.items,
    this.icon,
    this.color,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 3,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(
        color: color.withValues(alpha: 0.3),
      ),
    );
  }
}
