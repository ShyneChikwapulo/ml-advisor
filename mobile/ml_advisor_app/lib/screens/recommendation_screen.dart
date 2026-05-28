import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ml_model.dart';
import '../providers/model_provider.dart';
import '../utils/app_theme.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  int _step = 0;

  String? _datasetSize;
  String? _priority;
  String? _imbalance;

  MlModel? _result;

  final _questions = [
    {
      'question': 'What is your dataset size?',
      'icon': Icons.dataset,
      'options': ['Small (<1000)', 'Medium (1000-10000)', 'Large (>10000)'],
      'key': 'size',
    },
    {
      'question': 'What is your priority?',
      'icon': Icons.tune,
      'options': ['Accuracy', 'Interpretability', 'Balanced'],
      'key': 'priority',
    },
    {
      'question': 'How severe is your class imbalance?',
      'icon': Icons.balance,
      'options': ['Low', 'Medium', 'High'],
      'key': 'imbalance',
    },
  ];

  MlModel _recommend(List<MlModel> models) {
    if (_priority == 'Interpretability') {
      return models.firstWhere(
        (m) => m.interpretable,
        orElse: () => models.firstWhere(
          (m) => m.id == 'logistic_regression',
          orElse: () => models.first,
        ),
      );
    }

    if (_datasetSize == 'Small (<1000)') {
      return models.firstWhere(
        (m) => m.id == 'svm',
        orElse: () => models.first,
      );
    }

    if (_imbalance == 'High') {
      return models.firstWhere(
        (m) => m.handlesImbalance,
        orElse: () => models.firstWhere(
          (m) => m.id == 'random_forest',
          orElse: () => models.first,
        ),
      );
    }

    if (_datasetSize == 'Large (>10000)' && _priority == 'Accuracy') {
      return models.firstWhere(
        (m) => m.id == 'lstm',
        orElse: () => models.first,
      );
    }

    return models.reduce(
      (a, b) => a.accuracy > b.accuracy ? a : b,
    );
  }

  @override
  Widget build(BuildContext context) {
    final models = context.read<ModelProvider>().models;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Recommendation'),
      ),
      body: _result != null
          ? _ResultView(
              model: _result!,
              onReset: () {
                setState(() {
                  _step = 0;
                  _result = null;
                  _datasetSize = null;
                  _priority = null;
                  _imbalance = null;
                });
              },
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_step + 1) / _questions.length,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(
                      AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Question ${_step + 1} of ${_questions.length}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Icon(
                    _questions[_step]['icon'] as IconData,
                    size: 48,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _questions[_step]['question'] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ...(_questions[_step]['options'] as List<String>).map(
                    (opt) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            if (_step == 0) {
                              _datasetSize = opt;
                            }
                            if (_step == 1) {
                              _priority = opt;
                            }
                            if (_step == 2) {
                              _imbalance = opt;
                            }

                            if (_step < _questions.length - 1) {
                              _step++;
                            } else {
                              _result = _recommend(
                                models,
                              );
                            }
                          });
                        },
                        child: Text(
                          opt,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
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
  final MlModel model;
  final VoidCallback onReset;

  const _ResultView({
    required this.model,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.success,
            size: 72,
          ),
          const SizedBox(height: 16),
          const Text(
            'We Recommend',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            model.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why this model?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    model.description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Key Strengths:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...model.strengths.take(3).map(
                        (s) => Row(
                          children: [
                            const Icon(
                              Icons.check,
                              color: AppTheme.success,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Metric(
                        'Accuracy',
                        '${(model.accuracy * 100).toStringAsFixed(0)}%',
                      ),
                      _Metric(
                        'F1-Score',
                        model.f1Score.toStringAsFixed(2),
                      ),
                      _Metric(
                        'Category',
                        model.category,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: AppTheme.primary.withOpacity(0.05),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Source: Albattah & Alzahrani (2024) — Empirical benchmark on Unified Bug Dataset (47,618 classes)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Start Over'),
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
