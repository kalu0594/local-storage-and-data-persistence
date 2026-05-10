// lib/services/expenses_db.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';

class ExpensesDb {
  ExpensesDb._();
  static final ExpensesDb instance = ExpensesDb._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expenses.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE expenses (
          id       INTEGER PRIMARY KEY AUTOINCREMENT,
          amount   REAL    NOT NULL,
          category TEXT    NOT NULL,
          note     TEXT    NOT NULL,
          date     TEXT    NOT NULL
        )
      '''),
    );
  }

  // ---- CREATE ----
  Future<int> insert(Expense e) async {
    final db = await database;
    final map = e.toMap()..remove('id');
    return db.insert('expenses', map);
  }

  // ---- READ ----
  Future<List<Expense>> getAll() async {
    final db = await database;
    final rows = await db.query('expenses', orderBy: 'date DESC');
    return rows.map(Expense.fromMap).toList();
  }

  // ---- UPDATE ----
  Future<int> update(Expense e) async {
    final db = await database;
    return db.update('expenses', e.toMap(),
        where: 'id = ?', whereArgs: [e.id]);
  }

  // ---- DELETE ----
  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('expenses');
  }

  // ---- AGGREGATE ----
  Future<double> getTotalByMonth(int year, int month) async {
    final db = await database;
    final firstDay = DateTime(year, month, 1).toIso8601String();
    final firstDayNext = DateTime(year, month + 1, 1).toIso8601String();
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date < ?',
      [firstDay, firstDayNext],
    );
    final total = result.first['total'];
    return total == null ? 0.0 : (total as num).toDouble();
  }
}
