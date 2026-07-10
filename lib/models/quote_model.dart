class QuoteModel {
  final String text;
  final String author;
  final String category;

  const QuoteModel({
    required this.text,
    required this.author,
    required this.category,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      text: json['text'] as String,
      author: json['author'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'author': author,
      'category': category,
    };
  }
}
