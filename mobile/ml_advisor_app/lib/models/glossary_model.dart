class GlossaryModel {
  final String glossID;
  final String term;
  final String definition;
  final String category;

  GlossaryModel({
    required this.glossID,
    required this.term,
    required this.definition,
    required this.category,
  });

  factory GlossaryModel.fromJson(Map<String, dynamic> jsonData) {
    //Map<String, dynamic> jsonData, basically means it will get a map of type json from our database
    return GlossaryModel(
      glossID: jsonData['glossID'],
      term: jsonData['term'],
      definition: jsonData['definition'],
      category: jsonData['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'glossID': glossID,
      'term': term,
      'definition': definition,
      'category': category,
    };
  }
}
