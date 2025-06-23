class QAItem {
  final String id;
  final String question;
  final String askedBy;
  final DateTime askedAt;
  final String? answer;
  final String? answeredBy;
  final DateTime? answeredAt;
  final int upvotes;

  QAItem({
    required this.id,
    required this.question,
    required this.askedBy,
    required this.askedAt,
    this.answer,
    this.answeredBy,
    this.answeredAt,
    required this.upvotes,
  });

  QAItem copyWith({
    String? id,
    String? question,
    String? askedBy,
    DateTime? askedAt,
    String? answer,
    String? answeredBy,
    DateTime? answeredAt,
    int? upvotes,
  }) {
    return QAItem(
      id: id ?? this.id,
      question: question ?? this.question,
      askedBy: askedBy ?? this.askedBy,
      askedAt: askedAt ?? this.askedAt,
      answer: answer ?? this.answer,
      answeredBy: answeredBy ?? this.answeredBy,
      answeredAt: answeredAt ?? this.answeredAt,
      upvotes: upvotes ?? this.upvotes,
    );
  }
}
