class GlossaryTerm {
  final String id;
  final String term;
  final String definition;
  final String category;

  GlossaryTerm({
    required this.id,
    required this.term,
    required this.definition,
    required this.category,
  });

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) => GlossaryTerm(
        id: json['id'] ?? '',
        term: json['term'] ?? '',
        definition: json['definition'] ?? '',
        category: json['category'] ?? 'General',
      );

  Map<String, dynamic> toJson() => {
        'term': term,
        'definition': definition,
        'category': category,
      };
}