import 'dart:async'; // ⚡ Import required for StreamSubscription tracking
import 'package:flutter/material.dart';
import '../models/ml_model.dart';
import '../services/firestore_service.dart';

class ModelProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<MlModel> _models = [];
  List<MlModel> _selected = [];
  bool _loading = false;
  StreamSubscription? _modelsSubscription; // ⚡ Tracks the active database listener

  List<MlModel> get models => _models;
  List<MlModel> get selectedForComparison => _selected;
  bool get loading => _loading;

  // ⚡ Constructor: Start listening to live Firestore changes immediately
  ModelProvider() {
    _initModelsStream();
  }

  void _initModelsStream() {
    _loading = true;
    // Delay slightly to prevent notifying parent widgets during their build phase
    scheduleMicrotask(() => notifyListeners());

    // Cancel any existing listener subscription gracefully before attaching a new one
    _modelsSubscription?.cancel();

    _modelsSubscription = _service.streamModels().listen(
      (freshModels) {
        if (freshModels.isEmpty) {
          _models = _defaultModels;
        } else {
          _models = freshModels;
        }
        _loading = false;
        notifyListeners(); // 🔥 This line re-renders ModelLibraryScreen automatically!
      },
      onError: (_) {
        _models = _defaultModels;
        _loading = false;
        notifyListeners();
      },
    );
  }

  // Ensure active listener streams are torn down cleanly when the provider is destroyed
  @override
  void dispose() {
    _modelsSubscription?.cancel();
    super.dispose();
  }

  // ── Comparison Control Matrix ───────────────────────────
  void toggleComparison(MlModel model) {
    if (_selected.any((m) => m.id == model.id)) {
      _selected.removeWhere((m) => m.id == model.id);
    } else if (_selected.length < 3) {
      _selected.add(model);
    }
    notifyListeners();
  }

  void clearComparison() {
    _selected.clear();
    notifyListeners();
  }

  // ⚡ MUTATIONS: Simplified because the collection stream updates everything automatically!
  Future<void> addModel(MlModel model) async {
    await _service.addModel(model);
  }

  Future<void> deleteModel(String id) async {
    await _service.deleteModel(id);
  }

  Future<void> updateModel(String id, MlModel model) async {
    await _service.updateModel(id, model);
  }

  // Built-in fallback data
  static final List<MlModel> _defaultModels = [
    MlModel(
      id: 'random_forest',
      name: 'Random Forest',
      paperId: '', 
      datasetUsed: 'NASA MDP / PROMISE Corpus', 
      accuracy: 0.84,
      f1Score: 0.58,
      precision: 0.62,
      recall: 0.55,
      description: 'An ensemble learning method that builds multiple decision trees and merges their predictions for improved accuracy and robustness.',
      strengths: ['Handles overfitting well', 'Works with high-dimensional data', 'Feature importance scores'],
      weaknesses: ['Slow for real-time prediction', 'Memory intensive', 'Less interpretable than single trees'],
      bestUseCases: ['Large datasets', 'When accuracy is priority', 'Imbalanced datasets with SMOTE'],
      category: 'Ensemble',
      handlesImbalance: true,
      interpretable: false,
    ),
    MlModel(
      id: 'xgboost',
      name: 'XGBoost',
      paperId: '',
      datasetUsed: 'Unified Bug Dataset',
      accuracy: 0.83,
      f1Score: 0.57,
      precision: 0.61,
      recall: 0.54,
      description: 'A gradient boosting framework that uses tree-based models in a sequential manner to minimize prediction errors.',
      strengths: ['High performance', 'Built-in regularization', 'Handles missing values'],
      weaknesses: ['Many hyperparameters to tune', 'Can overfit on small datasets'],
      bestUseCases: ['Structured/tabular data', 'Competitions and benchmarks'],
      category: 'Ensemble',
      handlesImbalance: true,
      interpretable: false,
    ),
    MlModel(
      id: 'svm',
      name: 'SVM',
      paperId: '',
      datasetUsed: 'NASA MDP (CM1, PC1)',
      accuracy: 0.82,
      f1Score: 0.57,
      precision: 0.60,
      recall: 0.54,
      description: 'Support Vector Machine finds the optimal hyperplane that best separates classes in high-dimensional space.',
      strengths: ['Effective in high dimensions', 'Robust to outliers', 'Works well with small datasets'],
      weaknesses: ['Slow on large datasets', 'Sensitive to feature scaling', 'Hard to interpret'],
      bestUseCases: ['Small to medium datasets', 'Binary classification', 'High-dimensional data'],
      category: 'Traditional',
      handlesImbalance: false,
      interpretable: false,
    ),
    MlModel(
      id: 'logistic_regression',
      name: 'Logistic Regression',
      paperId: '',
      datasetUsed: 'PROMISE Repository',
      accuracy: 0.82,
      f1Score: 0.56,
      precision: 0.59,
      recall: 0.53,
      description: 'A linear model that estimates the probability of a binary outcome using a logistic function.',
      strengths: ['Highly interpretable', 'Fast training', 'Probabilistic output'],
      weaknesses: ['Assumes linear relationship', 'Poor with complex patterns'],
      bestUseCases: ['Baseline model', 'When interpretability is critical', 'Small datasets'],
      category: 'Traditional',
      handlesImbalance: false,
      interpretable: true,
    ),
    MlModel(
      id: 'lstm',
      name: 'LSTM',
      paperId: '',
      datasetUsed: 'GitHub Open Source Commits',
      accuracy: 0.87,
      f1Score: 0.61,
      precision: 0.70,
      recall: 0.55,
      description: 'Long Short-Term Memory is a recurrent neural network capable of learning long-term dependencies in sequential data.',
      strengths: ['Best overall accuracy', 'Captures temporal patterns', 'Handles sequential bug data'],
      weaknesses: ['Requires large datasets', 'Computationally expensive', 'Black box'],
      bestUseCases: ['Large datasets', 'Sequential code metrics', 'When accuracy is paramount'],
      category: 'Deep Learning',
      handlesImbalance: false,
      interpretable: false,
    ),
    MlModel(
      id: 'ann',
      name: 'ANN',
      accuracy: 0.83,
      f1Score: 0.58,
      precision: 0.63,
      recall: 0.54,
      paperId: '',
      datasetUsed: 'AEEEM Baseline Matrix',
      description: 'Artificial Neural Network with multiple hidden layers that learns complex non-linear relationships.',
      strengths: ['Learns complex patterns', 'Flexible architecture', 'Good with large data'],
      weaknesses: ['Needs lots of data', 'Hard to interpret', 'Slow training'],
      bestUseCases: ['Large datasets', 'Complex feature interactions'],
      category: 'Deep Learning',
      handlesImbalance: false,
      interpretable: false,
    ),
    MlModel(
      id: 'autoencoder',
      name: 'Autoencoder',
      paperId: '',
      datasetUsed: 'PROMISE Repository',
      accuracy: 0.82,
      f1Score: 0.57,
      precision: 0.61,
      recall: 0.54,
      description: 'A neural network trained to reconstruct its input, useful for anomaly detection and dimensionality reduction.',
      strengths: ['Good for anomaly detection', 'Unsupervised feature learning'],
      weaknesses: ['Complex to tune', 'Slow inference'],
      bestUseCases: ['Anomaly/bug detection', 'Feature extraction'],
      category: 'Deep Learning',
      handlesImbalance: false,
      interpretable: false,
    ),
    MlModel(
      id: 'dbn',
      name: 'DBN',
      paperId: '',
      datasetUsed: 'NASA MDP Base',
      accuracy: 0.82,
      f1Score: 0.57,
      precision: 0.61,
      recall: 0.53,
      description: 'Deep Belief Network is a generative graphical model using multiple layers of stochastic variables.',
      strengths: ['Unsupervised pre-training', 'Good feature learning'],
      weaknesses: ['Slow to train', 'Difficult to tune', 'Rarely used today'],
      bestUseCases: ['Feature learning', 'Semi-supervised scenarios'],
      category: 'Deep Learning',
      handlesImbalance: false,
      interpretable: false,
    ),
  ];
}