import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../../dashboard/models/transaction.dart';

class TransactionService {
  TransactionService._internal();
  static final TransactionService instance = TransactionService._internal();

  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTransactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  Future<List<Transaction>> getTransactionsForUser(String userId) async {
    final snapshot = await _userTransactions(
      userId,
    ).orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => Transaction.fromMap(doc.data())).toList();
  }

  Future<void> insertTransaction(String userId, Transaction transaction) async {
    await _userTransactions(
      userId,
    ).doc(transaction.id).set(transaction.toMap());
  }

  Future<void> updateTransaction(String userId, Transaction transaction) async {
    await _userTransactions(
      userId,
    ).doc(transaction.id).update(transaction.toMap());
  }

  Future<void> deleteTransaction(String userId, String id) async {
    await _userTransactions(userId).doc(id).delete();
  }
}
