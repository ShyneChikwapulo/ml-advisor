import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/paper_model.dart';
import '../models/glossary_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';

class ResearchGlossaryScreen extends StatelessWidget {
  const ResearchGlossaryScreen({super.key});

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color matteBlackCanvas = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: matteBlackCanvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RESEARCH',
                          style: TextStyle(
                            color: goldAccent.withOpacity(0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Research & Glossary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── TAB BAR ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Theme(
                    data: ThemeData(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      labelColor: goldAccent,
                      unselectedLabelColor: Colors.white.withOpacity(0.4),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.article_outlined, size: 16),
                              const SizedBox(width: 8),
                              Text('PAPERS'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.menu_book_outlined, size: 16),
                              const SizedBox(width: 8),
                              Text('GLOSSARY'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── TAB VIEWS ──
              const Expanded(
                child: TabBarView(
                  children: [_PapersTab(), _GlossaryTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PAPERS TAB ──
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
          return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.accent)));
        }
        final papers = snap.data ?? _defaultPapers;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
          itemCount: papers.length,
          itemBuilder: (_, i) {
            final p = papers[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.01),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  expansionTileTheme: ExpansionTileThemeData(
                    iconColor: ResearchGlossaryScreen.goldAccent,
                    collapsedIconColor: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                    ),
                    child: Center(
                      child: Text(
                        '\'${'${p.year}'.substring(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent, fontSize: 13),
                      ),
                    ),
                  ),
                  title: Text(
                    p.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13, height: 1.3),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      p.authors,
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                    ),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 1, color: Colors.white.withOpacity(0.04), margin: const EdgeInsets.only(bottom: 12)),
                          const Text(
                            'KEY FINDINGS',
                            style: TextStyle(color: ResearchGlossaryScreen.goldAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.keyFindings,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.5, fontSize: 12),
                          ),
                          if (p.modelsEvaluated.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'MODELS EVALUATED',
                              style: TextStyle(color: AppTheme.accent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: p.modelsEvaluated
                                  .map((m) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.03),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                                        ),
                                        child: Text(m, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w500)),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
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
      title: 'Software Defect Prediction Based on Machine Learning and Deep Learning Techniques',
      authors: 'Albattah & Alzahrani',
      year: 2024,
      keyFindings: 'LSTM achieved 87% accuracy on the Unified Bug Dataset with 47,618 classes and 60 software metrics. XGBoost was the runner-up at 85% accuracy. Traditional models like SVM and Logistic Regression struggled with imbalanced high-dimensional data.',
      modelsEvaluated: ['LSTM', 'XGBoost', 'Random Forest', 'SVM', 'ANN', 'DBN', 'Autoencoder', 'Logistic Regression'],
    ),
    PaperModel(
      id: '2',
      title: 'Industrial Adoption of ML for Early Identification of Invalid Bug Reports',
      authors: 'Laiq et al.',
      year: 2024,
      keyFindings: 'Random Forest achieved 90% accuracy in industrial bug triage. SHAP was used to increase model trustability. Concept drift over time remains a major challenge for deployed models.',
      modelsEvaluated: ['Random Forest', 'SVM', 'Logistic Regression', 'BERT', 'XGBoost'],
    ),
    PaperModel(
      id: '3',
      title: 'Machine Learning Techniques for Software Bug Prediction: A Systematic Review',
      authors: 'Saharudin et al.',
      year: 2020,
      keyFindings: 'Neural Networks and Naïve Bayes are the most widely used techniques. PROMISE and NASA MDP are the most frequently used datasets (43.3% each). AUC was used as evaluation metric in 76.7% of reviewed studies.',
      modelsEvaluated: ['Neural Network', 'Naïve Bayes', 'SVM', 'Random Forest', 'Decision Tree'],
    ),
  ];
}

// ── GLOSSARY TAB ──
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
        // ── SEARCH ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            cursorColor: ResearchGlossaryScreen.goldAccent,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search terms...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.3), size: 18),
              filled: true,
              fillColor: Colors.white.withOpacity(0.01),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppTheme.accent.withOpacity(0.4)),
              ),
            ),
          ),
        ),
        
        Expanded(
          child: FutureBuilder<List<GlossaryTerm>>(
            future: _future,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.accent)));
              }
              final all = snap.data ?? _defaultGlossary;
              final terms = all
                  .where((t) =>
                      t.term.toLowerCase().contains(_search.toLowerCase()) ||
                      t.definition.toLowerCase().contains(_search.toLowerCase()))
                  .toList();
              
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                itemCount: terms.length,
                itemBuilder: (_, i) {
                  final t = terms[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.06),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accent.withOpacity(0.15)),
                        ),
                        child: Center(
                          child: Text(
                            t.term[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                      title: Text(
                        t.term,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          t.definition,
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.4),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ResearchGlossaryScreen.goldAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ResearchGlossaryScreen.goldAccent.withOpacity(0.2)),
                        ),
                        child: Text(
                          t.category.toUpperCase(),
                          style: const TextStyle(fontSize: 8, color: ResearchGlossaryScreen.goldAccent, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
    GlossaryTerm(id: '1', term: 'F1-Score', definition: 'The harmonic mean of precision and recall. Balances the trade-off between false positives and false negatives.', category: 'Metrics'),
    GlossaryTerm(id: '2', term: 'Precision', definition: 'The proportion of positive predictions that are actually correct. High precision = fewer false alarms.', category: 'Metrics'),
    GlossaryTerm(id: '3', term: 'Recall', definition: 'The proportion of actual positives that were correctly identified. High recall = fewer missed bugs.', category: 'Metrics'),
    GlossaryTerm(id: '4', term: 'LSTM', definition: 'Long Short-Term Memory. A recurrent neural network that can learn long-term dependencies in sequential data.', category: 'Deep Learning'),
    GlossaryTerm(id: '5', term: 'Random Forest', definition: 'An ensemble of decision trees trained on random subsets of data. Reduces overfitting and improves generalisation.', category: 'Ensemble'),
    GlossaryTerm(id: '6', term: 'XGBoost', definition: 'Extreme Gradient Boosting. A sequential ensemble method that corrects errors of previous trees.', category: 'Ensemble'),
    GlossaryTerm(id: '7', term: 'Class Imbalance', definition: 'When one class significantly outnumbers another in the dataset. Common in bug prediction (few buggy files vs many clean files).', category: 'Concepts'),
    GlossaryTerm(id: '8', term: 'SMOTE', definition: 'Synthetic Minority Over-sampling Technique. Creates synthetic samples of the minority class to balance datasets.', category: 'Techniques'),
    GlossaryTerm(id: '9', term: 'AUC-ROC', definition: 'Area Under the Receiver Operating Characteristic curve. Measures the model\'s ability to distinguish between classes.', category: 'Metrics'),
    GlossaryTerm(id: '10', term: 'Feature Selection', definition: 'Process of selecting the most relevant input variables to reduce dimensionality and improve model performance.', category: 'Techniques'),
  ];
}