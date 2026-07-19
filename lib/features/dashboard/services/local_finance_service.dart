import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' hide Transaction;

import '../models/custom_category.dart';
import '../models/transaction.dart';

class LocalFinanceService {
  LocalFinanceService._();

  static final LocalFinanceService instance = LocalFinanceService._();

  Database? _database;

  Future<Database> get _db async {
    final existing = _database;
    if (existing != null) return existing;

    final databasePath = path.join(
      await getDatabasesPath(),
      'pocketwise_local.db',
    );
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, _) => _createTables(db),
    );
    _database = database;
    return database;
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE transactions (
        user_id TEXT NOT NULL,
        id TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        categoryLabel TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        note TEXT NOT NULL,
        isExpense INTEGER NOT NULL,
        PRIMARY KEY (user_id, id)
      )
    ''');
    await db.execute('''
      CREATE TABLE budgets (
        user_id TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        PRIMARY KEY (user_id, category)
      )
    ''');
    await db.execute('''
      CREATE TABLE custom_categories (
        user_id TEXT NOT NULL,
        label TEXT NOT NULL,
        is_expense INTEGER NOT NULL,
        PRIMARY KEY (user_id, label, is_expense)
      )
    ''');
  }

  Future<List<Transaction>> loadTransactions(String userId) async {
    final db = await _db;
    final rows = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<void> saveTransaction(String userId, Transaction transaction) async {
    final db = await _db;
    await db.insert('transactions', {
      ...transaction.toMap(),
      'user_id': userId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTransaction(String userId, String transactionId) async {
    final db = await _db;
    await db.delete(
      'transactions',
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, transactionId],
    );
  }

  Future<void> replaceTransactions(
    String userId,
    List<Transaction> transactions,
  ) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'transactions',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      for (final transaction in transactions) {
        await txn.insert('transactions', {
          ...transaction.toMap(),
          'user_id': userId,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<Map<String, double>> loadBudgets(String userId) async {
    final db = await _db;
    final rows = await db.query(
      'budgets',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return {
      for (final row in rows)
        row['category'] as String: (row['amount'] as num).toDouble(),
    };
  }

  Future<void> saveBudget(String userId, String category, double amount) async {
    final db = await _db;
    await db.insert('budgets', {
      'user_id': userId,
      'category': category,
      'amount': amount,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteBudget(String userId, String category) async {
    final db = await _db;
    await db.delete(
      'budgets',
      where: 'user_id = ? AND category = ?',
      whereArgs: [userId, category],
    );
  }

  Future<List<CustomCategory>> loadCustomCategories(String userId) async {
    final db = await _db;
    final rows = await db.query(
      'custom_categories',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'label COLLATE NOCASE',
    );
    return rows
        .map(
          (row) => CustomCategory(
            label: row['label'] as String,
            isExpense: (row['is_expense'] as int) == 1,
          ),
        )
        .toList();
  }

  Future<void> saveCustomCategory(
    String userId,
    CustomCategory category,
  ) async {
    final db = await _db;
    await db.insert('custom_categories', {
      'user_id': userId,
      'label': category.label,
      'is_expense': category.isExpense ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
