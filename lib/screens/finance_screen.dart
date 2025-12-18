import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db/db.dart';
import 'package:stocklog2/lib/format.dart';
import '../models/tx.dart';
import '../ui/app_theme.dart';
import '../ui/widgets.dart';

enum FinanceMode { all, date, month, year }

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  bool loading = true;
  List<TxRow> rows = [];

  FinanceMode mode = FinanceMode.all;
  DateTime selected = DateTime.now();

  int revenue = 0;
  int profit = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final Database db = await AppDb.instance.db;
    final data = await db.query('transactions', orderBy: 'date DESC');
    setState(() {
      rows = data.map((m) => TxRow.fromMap(m)).toList();
      loading = false;
    });
    // default hitung keseluruhan
    compute();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => selected = picked);
  }

  Future<void> pickMonth() async {
    // MVP cepat: pakai datePicker juga, lalu ambil month-nya
    await pickDate();
  }

  Future<void> pickYear() async {
    // MVP cepat: pakai datePicker juga, lalu ambil year-nya
    await pickDate();
  }

  void compute() {
    final outOnly = rows.where((r) => r.type == 'OUT');
    int rev = 0;
    int prof = 0;

    bool match(TxRow r) {
      if (mode == FinanceMode.all) return true;
      final parts = r.date.split('-'); // YYYY-MM-DD
      if (parts.length < 2) return true;
      final y = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final d = int.tryParse(parts[2]) ?? 0;

      if (mode == FinanceMode.year) return y == selected.year;
      if (mode == FinanceMode.month) {
        return y == selected.year && m == selected.month;
      }
      if (mode == FinanceMode.date) {
        return y == selected.year && m == selected.month && d == selected.day;
      }
      return true;
    }

    for (final r in outOnly.where(match)) {
      rev += r.qty * r.unitPrice;
      prof += r.qty * (r.unitPrice - r.costPriceAtThatTime);
    }

    setState(() {
      revenue = rev;
      profit = prof;
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = (mode == FinanceMode.all)
        ? "Keseluruhan"
        : (mode == FinanceMode.date)
            ? "Tanggal: ${selected.day}/${selected.month}/${selected.year}"
            : (mode == FinanceMode.month)
                ? "Bulan: ${selected.month}/${selected.year}"
                : "Tahun: ${selected.year}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
            title: "KEUANGAN",
            subtitle:
                "Silahkan pilih periode keuangan yang ingin anda ketahui"),
        const SizedBox(height: 12),
        if (loading)
          const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()))
        else ...[
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Text("Keuntungan\n= ${rupiah(profit)}",
                style: const TextStyle(
                    color: AppTheme.blue,
                    fontWeight: FontWeight.w900,
                    fontSize: 18)),
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Text("Total Pendapatan\n= ${rupiah(revenue)}",
                style: const TextStyle(
                    color: AppTheme.blue,
                    fontWeight: FontWeight.w900,
                    fontSize: 18)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _modeBtn("Keseluruhan", mode == FinanceMode.all,
                  () => setState(() => mode = FinanceMode.all)),
              _modeBtn("Berdasarkan Tanggal", mode == FinanceMode.date,
                  () => setState(() => mode = FinanceMode.date)),
              _modeBtn("Berdasarkan Bulan", mode == FinanceMode.month,
                  () => setState(() => mode = FinanceMode.month)),
              _modeBtn("Berdasarkan Tahun", mode == FinanceMode.year,
                  () => setState(() => mode = FinanceMode.year)),
            ],
          ),
          const SizedBox(height: 12),
          Text(label,
              style: const TextStyle(
                  color: Colors.black54, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                if (mode == FinanceMode.date) await pickDate();
                if (mode == FinanceMode.month) await pickMonth();
                if (mode == FinanceMode.year) await pickYear();
                compute();
              },
              child: const Text("CEK"),
            ),
          ),
        ],
      ],
    );
  }

  Widget _modeBtn(String text, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppTheme.blue : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            style: TextStyle(
                color: active ? Colors.white : Colors.black,
                fontWeight: FontWeight.w900)),
      ),
    );
  }
}
