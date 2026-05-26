class PaperModel {
  final String paperId;
  final String title;
  final List<String> authors;
  final int year;
  final String keyFindings;
  final List<String> modelsEvaluated;

  PaperModel({
    required this.paperId,
    required this.title,
    required this.authors,
    required this.year,
    required this.keyFindings,
    required this.modelsEvaluated,
  });

  factory PaperModel.fromJson(Map<String, dynamic> jsonData) {
    return PaperModel(
      paperId: jsonData['paperId'],
      title: jsonData['title'],
      authors: List<String>.from(jsonData['authors']),
      year: jsonData['year'],
      keyFindings: jsonData['keyFindings'],
      modelsEvaluated: List<String>.from(jsonData['modelsEvaluated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paperId': paperId,
      'title': title,
      'authors': authors,
      'year': year,
      'keyFindings': keyFindings,
      'modelsEvaluated': modelsEvaluated
    };
  }
}
