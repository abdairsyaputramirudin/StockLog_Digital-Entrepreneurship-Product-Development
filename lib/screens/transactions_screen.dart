import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db/db.dart';
import 'package:stocklog2/lib/format.dart';
import '../models/tx.dart';
import '../ui/widgets.dart';

enum TxSortField { date, name, qty, price }

enum TxSortDir { asc, desc }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final searchCtrl = TextEditingController();
  String tab = 'IN';
  bool loading = true;
  List<TxRow> rows = [];
  TxSortField sortField = TxSortField.date;
  TxSortDir sortDir = TxSortDir.desc;

  @override
  void initState() {
    super.initState();
    load();
    searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final Database db = await AppDb.instance.db;
    String col;
    switch (sortField) {
      case TxSortField.date:
        col = 'date';
        break;
      case TxSortField.name:
        col = 'itemName';
        break;
      case TxSortField.qty:
        col = 'qty';
        break;
      case TxSortField.price:
        col = 'unitPrice';
        break;
    }
    final dir = sortDir == TxSortDir.asc ? 'ASC' : 'DESC';

    final data = await db.query('transactions', orderBy: '$col $dir');

    setState(() {
      rows = data.map((m) => TxRow.fromMap(m)).toList();
      loading = false;
    });
  }

  List<TxRow> get filtered {
    final q = searchCtrl.text.trim().toLowerCase();
    return rows.where((r) {
      if (r.type != tab) return false;
      if (q.isEmpty) return true;
      return r.itemName.toLowerCase().contains(q) ||
          r.itemId.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> openFilterSheet() async {
    TxSortField localField = sortField;
    TxSortDir localDir = sortDir;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Widget chip(String label, bool active, VoidCallback onTap) {
              return InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? Colors.blue : const Color(0xFFE9EEF9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.blue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "FILTER TRANSAKSI",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "URUTKAN BERDASARKAN",
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    chip("Tanggal", localField == TxSortField.date,
                        () => setLocal(() => localField = TxSortField.date)),
                    chip("Nama", localField == TxSortField.name,
                        () => setLocal(() => localField = TxSortField.name)),
                    chip("Jumlah", localField == TxSortField.qty,
                        () => setLocal(() => localField = TxSortField.qty)),
                    chip("Harga", localField == TxSortField.price,
                        () => setLocal(() => localField = TxSortField.price)),
                  ]),
                  const SizedBox(height: 12),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    chip("Terendah", localDir == TxSortDir.asc,
                        () => setLocal(() => localDir = TxSortDir.asc)),
                    chip("Tertinggi", localDir == TxSortDir.desc,
                        () => setLocal(() => localDir = TxSortDir.desc)),
                  ]),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() {
                          sortField = localField;
                          sortDir = localDir;
                        });
                        await load();
                      },
                      child: const Text("OK"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              "ID",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Text(
              "Nama Barang",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Text(
              "Jumlah",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Text(
              "Harga",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Text(
              "Tanggal",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(TxRow t) {
    final total = t.qty * t.unitPrice;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              t.itemId,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              t.itemName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              "${t.qty}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              rupiah(total),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              t.date,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMasuk = tab == 'IN';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                  hintText: "Cari",
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: openFilterSheet,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.tune),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const SectionTitle(
          title: "Transaksi",
          subtitle: "Silahkan pilih jenis transaksi yang ingin anda lihat",
        ),
        const SizedBox(height: 12),
        PillToggle(
          left: "Barang Masuk",
          right: "Barang Keluar",
          isLeftActive: isMasuk,
          onLeft: () => setState(() => tab = 'IN'),
          onRight: () => setState(() => tab = 'OUT'),
        ),
        const SizedBox(height: 12),
        _tableHeader(),
        const SizedBox(height: 10),
        if (loading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Belum ada transaksi.",
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          Column(
            children: filtered
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _row(t),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
