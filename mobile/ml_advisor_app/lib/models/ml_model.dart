class MlModel {
  final String id;
  final String name;
  final double accuracy;
  final double f1Score;
  final double precision;
  final double recall;
  final String description;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> bestUseCases;
  final String category;
  final bool handlesImbalance;
  final bool interpretable;

  MlModel({
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

  factory MlModel.fromJson(Map<String, dynamic> json) => MlModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        accuracy: (json['accuracy'] ?? 0).toDouble(),
        f1Score: (json['f1Score'] ?? json['f1_score'] ?? 0).toDouble(),
        precision: (json['precision'] ?? 0).toDouble(),
        recall: (json['recall'] ?? 0).toDouble(),
        description: json['description'] ?? '',
        strengths: List<String>.from(json['strengths'] ?? []),
        weaknesses: List<String>.from(json['weaknesses'] ?? []),
        bestUseCases: List<String>.from(json['bestUseCases'] ?? json['best_use_cases'] ?? []),
        category: json['category'] ?? 'Traditional',
        handlesImbalance: json['handlesImbalance'] ?? json['handles_imbalance'] ?? false,
        interpretable: json['interpretable'] ?? false,
      );

  Map<String, dynamic> toJson() => {
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