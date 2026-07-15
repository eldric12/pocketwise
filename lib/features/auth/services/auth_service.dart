import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path;
    if (kIsWeb) {
      path = 'pocketwise_auth.db';
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'pocketwise_auth.db');
    }

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            categoryId TEXT NOT NULL,
            categoryLabel TEXT NOT NULL,
            paymentMethod TEXT NOT NULL,
            note TEXT NOT NULL,
            isExpense INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
      },
    );
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;
    final normalizedEmail = email.trim().toLowerCase();

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    if (existing.isNotEmpty) {
      return 'An account with this email already exists.';
    }

    await db.insert('users', {
      'name': name.trim(),
      'email': normalizedEmail,
      'password_hash': _hashPassword(password),
    });
    return null;
  }

  Future<String?> login({
    required String userId,
    required String password,
  }) async {
    final db = await database;
    final normalizedEmail = userId.trim().toLowerCase();

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );

    if (result.isEmpty) {
      return 'No account found with that User ID.';
    }

    final storedHash = result.first['password_hash'] as String;
    if (storedHash != _hashPassword(password)) {
      return 'Incorrect password.';
    }
    return null;
  }

  Future<int?> getUserId(String email) async {
    final db = await database;
    final normalizedEmail = email.trim().toLowerCase();
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );
    if (result.isEmpty) return null;
    return result.first['id'] as int;
  }
}