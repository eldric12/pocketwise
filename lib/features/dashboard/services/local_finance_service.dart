import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' hide Transaction;

import '../models/category_definition.dart';
import '../models/transaction.dart';
import '../utils/category_catalog.dart';

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
      version: 2,
      onCreate: (db, _) => _createTables(db),
      onUpgrade: _upgradeDatabase,
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
    await _createCategoriesTable(db);
  }

  Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        user_id TEXT NOT NULL,
        id TEXT NOT NULL,
        label TEXT NOT NULL,
        is_expense INTEGER NOT NULL,
        icon_key TEXT NOT NULL,
        color_key TEXT NOT NULL,
        is_custom INTEGER NOT NULL,
        PRIMARY KEY (user_id, id, is_expense),
        UNIQUE (user_id, label, is_expense)
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion >= 2) return;
    await _createCategoriesTable(db);

    final legacyTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'custom_categories'",
    );
    if (legacyTable.isEmpty) return;

    final rows = await db.query('custom_categories');
    for (final row in rows) {
      final label = row['label'] as String;
      await db.insert('categories', {
        'user_id': row['user_id'] as String,
        'id': legacyCategoryId(label),
        'label': label,
        'is_expense': row['is_expense'] as int,
        'icon_key': 'category',
        'color_key': 'slate',
        'is_custom': 1,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
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

  Future<List<CategoryDefinition>> loadCategories(String userId) async {
    final db = await _db;
    await db.transaction((txn) async {
      for (final category in defaultCategories) {
        await txn.insert('categories', {
          'user_id': userId,
          'id': category.id,
          'label': category.label,
          'is_expense': category.isExpense ? 1 : 0,
          'icon_key': category.iconKey,
          'color_key': category.colorKey,
          'is_custom': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
    final rows = await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'is_expense DESC, is_custom ASC, label COLLATE NOCASE',
    );
    return rows
        .map(
          (row) => CategoryDefinition(
            id: row['id'] as String,
            label: row['label'] as String,
            isExpense: (row['is_expense'] as int) == 1,
            iconKey: row['icon_key'] as String,
            colorKey: row['color_key'] as String,
            isCustom: (row['is_custom'] as int) == 1,
          ),
        )
        .toList();
  }

  Future<void> saveCategory(String userId, CategoryDefinition category) async {
    final db = await _db;
    await db.insert('categories', {
      'user_id': userId,
      'id': category.id,
      'label': category.label,
      'is_expense': category.isExpense ? 1 : 0,
      'icon_key': category.iconKey,
      'color_key': category.colorKey,
      'is_custom': category.isCustom ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearAllData(String userId) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('transactions', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('budgets', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('categories', where: 'user_id = ?', whereArgs: [userId]);
    });
  }
}