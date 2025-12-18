import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db/db.dart';
import 'package:stocklog2/lib/uid.dart';
import '../models/item.dart';
import '../ui/widgets.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final costCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    costCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  void reset() {
    nameCtrl.clear();
    qtyCtrl.clear();
    costCtrl.clear();
    noteCtrl.clear();
    selectedDate = DateTime.now();
    setState(() {});
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  String _dateIso(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<String> _nextItemId(Database db) async {
    // ambil id terbesar, misal "007" -> 7 -> jadi 8 -> "008"
    final rows = await db.rawQuery(
      "SELECT id FROM items ORDER BY id DESC LIMIT 1",
    );
    if (rows.isEmpty) return "001";
    final last = (rows.first['id'] as String?) ?? "000";
    final n = int.tryParse(last) ?? 0;
    final next = n + 1;
    return next.toString().padLeft(3, '0');
  }

  Future<void> submit() async {
    final name = nameCtrl.text.trim();
    final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
    final cost = int.tryParse(costCtrl.text.trim()) ?? 0;
    final note = noteCtrl.text.trim();

    if (name.isEmpty) {
      await showInfoModal(
        context,
        title: "Validasi",
        message: "Nama Barang wajib diisi.",
      );
      return;
    }
    if (qty <= 0) {
      await showInfoModal(
        context,
        title: "Validasi",
        message: "Jumlah harus > 0.",
      );
      return;
    }
    if (cost <= 0) {
      await showInfoModal(
        context,
        title: "Validasi",
        message: "Harga harus > 0.",
      );
      return;
    }

    final dateIso = _dateIso(selectedDate);
    final Database db = await AppDb.instance.db;
    final now = DateTime.now().toIso8601String();

    // cek existing by name (MVP)
    final existRows = await db.query(
      'items',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    final existing =
        existRows.isEmpty ? null : ItemRow.fromMap(existRows.first);

    if (existing != null) {
      await db.transaction((txn) async {
        await txn.update(
          'items',
          {
            'qty': existing.qty + qty,
            'costPrice': cost,
            'note': note.isEmpty ? (existing.note ?? '') : note,
            'updatedAt': now,
          },
          where: 'id = ?',
          whereArgs: [existing.id],
        );

        await txn.insert('transactions', {
          'id': uid('tx_'),
          'type': 'IN',
          'itemId': existing.id,
          'itemName': name,
          'qty': qty,
          'unitPrice': cost,
          'costPriceAtThatTime': cost,
          'date': dateIso,
        });
      });

      await showInfoModal(
        context,
        title: "NOTIFIKASI",
        message: "Barang Baru Sukses Di Tambahkan",
      );
      reset();
      return;
    }

    // ✅ NEW: id urut 001
    final itemId = await _nextItemId(db);

    await db.transaction((txn) async {
      await txn.insert('items', {
        'id': itemId,
        'name': name,
        'qty': qty,
        'costPrice': cost,
        'note': note,
        'updatedAt': now,
      });

      await txn.insert('transactions', {
        'id': uid('tx_'),
        'type': 'IN',
        'itemId': itemId,
        'itemName': name,
        'qty': qty,
        'unitPrice': cost,
        'costPriceAtThatTime': cost,
        'date': dateIso,
      });
    });

    await showInfoModal(
      context,
      title: "NOTIFIKASI",
      message: "Barang Baru Sukses Di Tambahkan",
    );
    reset();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: "Input Barang",
          subtitle: "Silahkan input barang baru yang ingin anda tambahkan",
        ),
        const SizedBox(height: 12),
        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(hintText: "Nama Barang"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: qtyCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Jumlah"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: costCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Harga"),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: pickDate,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              "Tanggal: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black54,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(hintText: "Catatan"),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: submit, child: const Text("KIRIM")),
        ),
      ],
    );
  }
}
