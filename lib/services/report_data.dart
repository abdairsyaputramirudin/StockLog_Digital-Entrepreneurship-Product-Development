import '../db/db.dart';
import 'package:stocklog2/lib/format.dart';
import 'report_pdf.dart';

class ReportData {
  // Nama user (profil)
  static Future<String> getUserName() async {
    final db = await AppDb.instance.db;
    final rows = await db.query('profile', where: 'id = 1', limit: 1);
    final name =
        (rows.isNotEmpty ? (rows.first['name'] as String?) : null) ?? 'User';
    return name.trim().isEmpty ? 'User' : name.trim();
  }

  // Stok tersedia
  static Future<List<PdfRow>> stockRows() async {
    final db = await AppDb.instance.db;
    final rows = await db.query('items', orderBy: 'id ASC');

    return rows.map((m) {
      final id = (m['id'] ?? '').toString();
      final name = (m['name'] ?? '').toString();
      final qty = (m['qty'] ?? 0).toString();
      final price = rupiah((m['costPrice'] ?? 0) as int);
      final total =
          rupiah(((m['costPrice'] ?? 0) as int) * ((m['qty'] ?? 0) as int));
      return PdfRow([id, name, qty, price, total]);
    }).toList();
  }

  // Parsing tanggal yang ada di transaksi kamu (dukung MM/DD/YYYY dan DD/MM/YYYY)
  static DateTime? _parseAppDate(String s) {
    final parts = s.split('/');
    if (parts.length != 3) return null;
    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    final c = int.tryParse(parts[2]);
    if (a == null || b == null || c == null) return null;

    if (a > 12) return DateTime(c, b, a); // DD/MM/YYYY
    return DateTime(c, a, b); // MM/DD/YYYY
  }

  static bool _inRange(DateTime d, DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day, 23, 59, 59);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  // Transaksi masuk/keluar
  static Future<List<PdfRow>> txRows({
    required String type, // "IN" / "OUT"
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await AppDb.instance.db;
    final rows = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );

    final out = <PdfRow>[];
    for (final m in rows) {
      final dateStr = (m['date'] ?? '').toString();
      final parsed = _parseAppDate(dateStr);
      if (parsed == null) continue;
      if (!_inRange(parsed, from, to)) continue;

      final id = (m['itemId'] ?? '').toString();
      final name = (m['itemName'] ?? '').toString();
      final qty = (m['qty'] ?? 0).toString();
      final unit = (m['unitPrice'] ?? 0) as int;
      final total = unit * ((m['qty'] ?? 0) as int);

      out.add(PdfRow([id, name, qty, rupiah(total), dateStr]));
    }

    return out;
  }
}
