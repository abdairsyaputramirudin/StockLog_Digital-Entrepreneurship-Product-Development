import 'package:sqflite/sqflite.dart';
import 'db.dart';

Future<void> initDb() async {
  final Database db = await AppDb.instance.db;

  await db.execute('''
    CREATE TABLE IF NOT EXISTS items (
      id TEXT PRIMARY KEY NOT NULL,
      name TEXT NOT NULL,
      qty INTEGER NOT NULL,
      costPrice INTEGER NOT NULL,
      note TEXT,
      updatedAt TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS transactions (
      id TEXT PRIMARY KEY NOT NULL,
      type TEXT NOT NULL,
      itemId TEXT NOT NULL,
      itemName TEXT NOT NULL,
      qty INTEGER NOT NULL,
      unitPrice INTEGER NOT NULL,
      costPriceAtThatTime INTEGER NOT NULL,
      date TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS profile (
      id INTEGER PRIMARY KEY NOT NULL,
      name TEXT NOT NULL,
      email TEXT,
      phone TEXT
    )
  ''');

  final rows = await db.query('profile', limit: 1);
  if (rows.isEmpty) {
    await db.insert(
        'profile', {'id': 1, 'name': 'Lisan', 'email': '', 'phone': ''});
  }
}
