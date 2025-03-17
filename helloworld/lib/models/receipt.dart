class Receipt {
  final String userId;
  final String fullText;
  final double? total;
  final DateTime? date;
  final DateTime createdAt;

  Receipt({
    required this.userId,
    required this.fullText,
    this.total,
    this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullText': fullText,
      'total': total,
      'date': date,
      'createdAt': createdAt,
    };
  }
}
