import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ml_advisor_app/models/ml_model.dart';

class ModelDataProvider extends ChangeNotifier {
  List<MLModel> _models = []; // a list of model objects
  bool _loading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MLModel> get models => _models; // access models safely
  bool get loading => _loading;

  static final List<MLModel> _defaultModels = [
    // backup hardcoded data if Firebase fails or is empty
    MLModel(
      id: "1",
      name: "SVM",
      accuracy: 0.84,
      f1Score: 0.61,
      recall: 0.61,
      description: "Best for separating data into clear group using a boundary",
      precision: 0.83,
      strengths: [
        "Works well with complex data",
        "Effective with clear separation between classes",
        "Good for small to medium datasets"
      ],
      weaknesses: [
        "Slow with large datasets",
        "Needs careful tuning to work well",
      ],
      bestUseCases: ["Sorting Text(spam emails)", "Recognizing images"],
      category: "Margin Classifier",
      handlesImbalance: false,
      interpretable: false,
    ),
    MLModel(
      id: "2",
      name: "Random Forest",
      accuracy: 0.84,
      f1Score: 0.61,
      precision: 0.60,
      recall: 0.62,
      description:
          "Commonly used machine learning model that is best for making accurate predictions by combining many decision trees to reduce errors.",
      strengths: [
        "Accurate",
        "Works well with big data",
      ],
      weaknesses: ["Slow to run", "Hard to understand decision-making process"],
      bestUseCases: [
        "Finding Fraud",
        "Medical Predictions",
        "Sorting data into groups"
      ],
      category: "Ensemble Trees",
      handlesImbalance: true,
      interpretable: false,
    )
  ];

  Future<void> loadModels() async {
    // get the data without freezing the app

    _loading = true;
    notifyListeners();

    try {
      _models = await _service.getModels();

      if (_models.isEmpty) {
        _models = _defaultModels;
      }
    } catch (e) {
      _models = _defaultModels;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
