class PaperModel {
  final String id;
  final String title;
  final String authors;
  final int year;
  final String keyFindings;
  final List<String> modelsEvaluated;

  PaperModel({
    required this.id,
    required this.title,
    required this.authors,
    required this.year,
    required this.keyFindings,
    required this.modelsEvaluated,
  });

  factory PaperModel.fromJson(Map<String, dynamic> json) => PaperModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        authors: json['authors'] ?? '',
        year: json['year'] ?? 0,
        keyFindings: json['keyFindings'] ?? json['key_findings'] ?? '',
        modelsEvaluated: List<String>.from(json['modelsEvaluated'] ?? json['models_evaluated'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'authors': authors,
        'year': year,
        'keyFindings': keyFindings,
        'modelsEvaluated': modelsEvaluated,
      };
}