import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/paper_model.dart';
import '../models/glossary_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';

class ResearchGlossaryScreen extends StatelessWidget {
  const ResearchGlossaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Research & Glossary'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.article), text: 'Research Papers'),
              Tab(icon: Icon(Icons.menu_book), text: 'Glossary'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            _PapersTab(),
            _GlossaryTab(),
          ],
        ),
      ),
    );
  }
}

class _PapersTab extends StatefulWidget {
  const _PapersTab();

  @override
  State<_PapersTab> createState() => _PapersTabState();
}

class _PapersTabState extends State<_PapersTab> {
  final _service = FirestoreService();
  late Future<List<PaperModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getPapers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PaperModel>>(
      future: _future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final papers = snap.data ?? _defaultPapers;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: papers.length,
          itemBuilder: (_, i) {
            final p = papers[i];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text(
                    '${p.year}'.substring(2),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                title: Text(
                  p.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  p.authors,
                  style: const TextStyle(fontSize: 11),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Key Findings:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.keyFindings,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        if (p.modelsEvaluated.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Models Evaluated:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Wrap(
                            spacing: 6,
                            children: p.modelsEvaluated
                                .map(
                                  (m) => Chip(
                                    label: Text(
                                      m,
                                      style: const TextStyle(
                                        fontSize: 11,
                                      ),
                                    ),
                                    backgroundColor:
                                        AppTheme.primary.withOpacity(
                                      0.1,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static final _defaultPapers = [
    PaperModel(
      id: '1',
      title:
          'Software Defect Prediction Based on Machine Learning and Deep Learning Techniques',
      authors: 'Albattah & Alzahrani',
      year: 2024,
      keyFindings:
          'LSTM achieved 87% accuracy on the Unified Bug Dataset with 47,618 classes and 60 software metrics. XGBoost was the runner-up at 85% accuracy. Traditional models struggled with imbalance.',
      modelsEvaluated: [
        'LSTM',
        'XGBoost',
        'Random Forest',
        'SVM',
        'ANN',
        'DBN',
        'Autoencoder',
        'Logistic Regression'
      ],
    ),
    PaperModel(
      id: '2',
      title:
          'Industrial Adoption of ML for Early Identification of Invalid Bug Reports',
      authors: 'Laiq et al.',
      year: 2024,
      keyFindings:
          'Random Forest achieved 90% accuracy. SHAP improved interpretability. Concept drift remains a challenge.',
      modelsEvaluated: [
        'Random Forest',
        'SVM',
        'Logistic Regression',
        'BERT',
        'XGBoost'
      ],
    ),
    PaperModel(
      id: '3',
      title:
          'Machine Learning Techniques for Software Bug Prediction: A Systematic Review',
      authors: 'Saharudin et al.',
      year: 2020,
      keyFindings:
          'Neural Networks and Naïve Bayes are widely used. AUC is the most common metric.',
      modelsEvaluated: [
        'Neural Network',
        'Naïve Bayes',
        'SVM',
        'Random Forest',
        'Decision Tree'
      ],
    ),
  ];
}

class _GlossaryTab extends StatefulWidget {
  const _GlossaryTab();

  @override
  State<_GlossaryTab> createState() => _GlossaryTabState();
}

class _GlossaryTabState extends State<_GlossaryTab> {
  final _service = FirestoreService();
  late Future<List<GlossaryTerm>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = _service.getGlossary();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search terms...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<GlossaryTerm>>(
            future: _future,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final all = snap.data ?? _defaultGlossary;

              final terms = all.where((t) {
                final q = _search.toLowerCase();
                return t.term.toLowerCase().contains(q) ||
                    t.definition.toLowerCase().contains(q);
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                itemCount: terms.length,
                itemBuilder: (_, i) {
                  final t = terms[i];

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.secondary.withOpacity(0.15),
                        child: Text(
                          t.term[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ),
                      title: Text(
                        t.term,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        t.definition,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            6,
                          ),
                        ),
                        child: Text(
                          t.category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  static final _defaultGlossary = [
    GlossaryTerm(
      id: '1',
      term: 'F1-Score',
      definition: 'Harmonic mean of precision and recall.',
      category: 'Metrics',
    ),
    GlossaryTerm(
      id: '2',
      term: 'Precision',
      definition: 'Correct positive predictions ratio.',
      category: 'Metrics',
    ),
    GlossaryTerm(
      id: '3',
      term: 'Recall',
      definition: 'Correctly identified actual positives.',
      category: 'Metrics',
    ),
    GlossaryTerm(
      id: '4',
      term: 'LSTM',
      definition: 'Recurrent neural network for sequences.',
      category: 'Deep Learning',
    ),
    GlossaryTerm(
      id: '5',
      term: 'Random Forest',
      definition: 'Ensemble of decision trees.',
      category: 'Ensemble',
    ),
    GlossaryTerm(
      id: '6',
      term: 'XGBoost',
      definition: 'Gradient boosting ensemble method.',
      category: 'Ensemble',
    ),
    GlossaryTerm(
      id: '7',
      term: 'Class Imbalance',
      definition: 'Unequal class distribution problem.',
      category: 'Concepts',
    ),
    GlossaryTerm(
      id: '8',
      term: 'SMOTE',
      definition: 'Oversampling technique for imbalance.',
      category: 'Techniques',
    ),
    GlossaryTerm(
      id: '9',
      term: 'AUC-ROC',
      definition: 'Classification performance metric.',
      category: 'Metrics',
    ),
    GlossaryTerm(
      id: '10',
      term: 'Feature Selection',
      definition: 'Selecting relevant input features.',
      category: 'Techniques',
    ),
  ];
}
