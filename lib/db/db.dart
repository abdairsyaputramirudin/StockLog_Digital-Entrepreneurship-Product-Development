import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final basePath = await getDatabasesPath();
    final path = p.join(basePath, 'stocklog2.db');
    _db = await openDatabase(path, version: 1);
    return _db!;
  }
}
