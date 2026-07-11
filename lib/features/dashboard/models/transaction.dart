class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String categoryLabel;
  final String paymentMethod;
  final String note;
  final bool isExpense;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.categoryLabel,
    this.paymentMethod = 'Cash',
    this.note = '',
    required this.isExpense,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'categoryLabel': categoryLabel,
      'paymentMethod': paymentMethod,
      'note': note,
      'isExpense': isExpense ? 1 : 0,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
      categoryId: map['categoryId'] as String,
      categoryLabel: map['categoryLabel'] as String? ?? map['categoryId'] as String,
      paymentMethod: map['paymentMethod'] as String? ?? 'Cash',
      note: map['note'] as String? ?? '',
      isExpense: (map['isExpense'] as int) == 1,
    );
  }
}
