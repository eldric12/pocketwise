import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../../dashboard/models/transaction.dart';

class TransactionService {
  TransactionService._internal();
  static final TransactionService instance = TransactionService._internal();

  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTransactions(String userId) {
    return _firestore.collection('users').doc(userId).collection('transactions');
  }

  DocumentReference<Map<String, dynamic>> _userBudgetsDoc(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('meta')
        .doc('budgets');
  }

  Future<List<Transaction>> getTransactionsForUser(String userId) async {
    final snapshot = await _userTransactions(userId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => Transaction.fromMap(doc.data())).toList();
  }

  Future<void> insertTransaction(String userId, Transaction transaction) async {
    await _userTransactions(userId).doc(transaction.id).set(transaction.toMap());
  }

  Future<void> updateTransaction(String userId, Transaction transaction) async {
    await _userTransactions(userId).doc(transaction.id).set(transaction.toMap());
  }

  Future<void> deleteTransaction(String userId, String id) async {
    await _userTransactions(userId).doc(id).delete();
  }

  Future<void> clearAllTransactions(String userId) async {
    final snapshot = await _userTransactions(userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<Map<String, double>> getBudgetsForUser(String userId) async {
    final snapshot = await _userBudgetsDoc(userId).get();
    final data = snapshot.data();
    if (data == null) return {};
    return data.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  Future<void> saveBudget(String userId, String category, double amount) async {
    await _userBudgetsDoc(
      userId,
    ).set({category: amount}, SetOptions(merge: true));
  }

  Future<void> deleteBudget(String userId, String category) async {
    await _userBudgetsDoc(userId).update({category: FieldValue.delete()});
  }

  Future<void> clearAllBudgets(String userId) async {
    await _userBudgetsDoc(userId).delete();
  }
}