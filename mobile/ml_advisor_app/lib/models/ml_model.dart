class MLModel {
  final String id;
  final String name;
  final double accuracy;
  final double f1Score;
  final double precision;
  final double recall;
  final String description;

  // These should be LISTS because they contain multiple items
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> bestUseCases;

  final String category;
  final bool handlesImbalance;
  final bool interpretable;

  MLModel({
    required this.id,
    required this.name,
    required this.accuracy,
    required this.f1Score,
    required this.precision,
    required this.recall,
    required this.description,
    required this.strengths,
    required this.weaknesses,
    required this.bestUseCases,
    required this.category,
    required this.handlesImbalance,
    required this.interpretable,
  });

  // creating a MLModel object from Firestore / API JSON data
  // The factory method helps convert Map<String, dynamic> → MLModel object
  factory MLModel.fromJson(Map<String, dynamic> jsonData) {
    return MLModel(
      id: jsonData[
          'id'], // takes the value of id from Firestore and stores it in MLModel id
      name: jsonData[
          'name'], // fetching name from Firestore and assigning it to name variable

      accuracy: (jsonData['accuracy'] ?? 0).toDouble(),

      f1Score: (jsonData['f1Score'] ?? jsonData['f1_score'] ?? 0).toDouble(),

      precision: (jsonData['precision'] ?? 0).toDouble(),

      recall: (jsonData['recall'] ?? 0).toDouble(),

      description: jsonData['description'],

      // Convert Firestore arrays safely into List<String>
      strengths: List<String>.from(jsonData['strengths'] ??
          []), //?? meas if left side is null, no strenths, use thr right side as backup-that is, return an empty list

      weaknesses: List<String>.from(jsonData['weaknesses'] ?? []),

      bestUseCases: List<String>.from(jsonData['bestUseCases'] ?? []),

      category: jsonData['category'],

      handlesImbalance: jsonData['handlesImbalance'] ?? false,

      interpretable: jsonData['interpretable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'accuracy': accuracy,
      'f1Score': f1Score,
      'precision': precision,
      'recall': recall,
      'description': description,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'bestUseCases': bestUseCases,
      'category': category,
      'handlesImbalance': handlesImbalance,
      'interpretable': interpretable,
    };
  }
}
