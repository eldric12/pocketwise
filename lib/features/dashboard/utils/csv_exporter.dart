import '../models/transaction.dart';

String buildTransactionsCsv(List<Transaction> transactions) {
  final buffer = StringBuffer();
  buffer.writeln('Date,Title,Category,Payment Method,Type,Amount,Note');

  for (final t in transactions) {
    final row = [
      t.date.toIso8601String().split('T').first,
      t.title,
      t.categoryLabel,
      t.paymentMethod,
      t.isExpense ? 'Expense' : 'Income',
      t.amount.toStringAsFixed(2),
      t.note,
    ].map(_escapeCsvField).join(',');
    buffer.writeln(row);
  }

  return buffer.toString();
}

String _escapeCsvField(String field) {
  if (field.contains(',') || field.contains('"') || field.contains('\n')) {
    return '"${field.replaceAll('"', '""')}"';
  }
  return field;
}