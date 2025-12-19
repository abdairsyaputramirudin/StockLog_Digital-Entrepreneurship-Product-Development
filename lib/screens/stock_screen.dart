import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db/db.dart';
import 'package:stocklog2/lib/format.dart';
import 'package:stocklog2/lib/uid.dart';
import '../models/item.dart';
import '../ui/app_theme.dart';
import '../ui/widgets.dart';

enum SortField { id, name, qty, price }

enum SortDir { low, high }

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  Widget _miniTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text("ID",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          Expanded(
            flex: 5,
            child: Text("Nama Barang",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          Expanded(
            flex: 3,
            child: Text("Jumlah",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          Expanded(
            flex: 4,
            child: Text("Harga",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _miniTableRow({
    required String id,
    required String name,
    required String qty,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(id,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          Expanded(
            flex: 5,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(qty,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          Expanded(
            flex: 4,
            child: Text(price,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  final searchCtrl = TextEditingController();

  List<ItemRow> items = [];
  bool loading = true;

  SortField sortField = SortField.id;
  SortDir sortDir = SortDir.low;

  @override
  void initState() {
    super.initState();
    load();
    searchCtrl.addListener(() => load());
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  String _orderBy(SortField f, SortDir d) {
    String col;
    switch (f) {
      case SortField.id:
        col = 'id';
        break;
      case SortField.name:
        col = 'name';
        break;
      case SortField.qty:
        col = 'qty';
        break;
      case SortField.price:
        col = 'costPrice';
        break;
    }
    final dir = d == SortDir.low ? 'ASC' : 'DESC';
    return '$col $dir';
  }

  Future<void> load() async {
    setState(() => loading = true);
    final Database db = await AppDb.instance.db;
    final q = searchCtrl.text.trim();

    final rows = await db.query(
      'items',
      where: q.isEmpty ? null : 'name LIKE ?',
      whereArgs: q.isEmpty ? null : ['%$q%'],
      orderBy: _orderBy(sortField, sortDir),
    );

    setState(() {
      items = rows.map((m) => ItemRow.fromMap(m)).toList();
      loading = false;
    });
  }

  Future<void> openSortSheet() async {
    SortField localField = sortField;
    SortDir localDir = sortDir;

    await showModalBottomSheet(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
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

            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      surface: Colors.white,
                      surfaceTint: Colors.white,
                    ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "URUTKAN",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "BERDASARKAN",
                        style: TextStyle(
                            fontWeight: FontWeight.w900, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(spacing: 10, runSpacing: 10, children: [
                      chip("ID", localField == SortField.id,
                          () => setLocal(() => localField = SortField.id)),
                      chip("Nama", localField == SortField.name,
                          () => setLocal(() => localField = SortField.name)),
                      chip("Jumlah", localField == SortField.qty,
                          () => setLocal(() => localField = SortField.qty)),
                      chip("Harga", localField == SortField.price,
                          () => setLocal(() => localField = SortField.price)),
                    ]),
                    const SizedBox(height: 12),
                    Wrap(spacing: 10, runSpacing: 10, children: [
                      chip("Terendah", localDir == SortDir.low,
                          () => setLocal(() => localDir = SortDir.low)),
                      chip("Tertinggi", localDir == SortDir.high,
                          () => setLocal(() => localDir = SortDir.high)),
                    ]),
                    const SizedBox(height: 16),
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _sortChip(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  Future<void> showProcessSheet(ItemRow item) async {
    final qtyCtrl = TextEditingController();
    final sellCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    String dateIso(DateTime d) =>
        "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    Future<void> pickDate(StateSetter setLocal) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2035),
      );
      if (picked != null) setLocal(() => selectedDate = picked);
    }

    Future<void> submit() async {
      final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
      final sell = int.tryParse(sellCtrl.text.trim()) ?? 0;

      if (qty <= 0) {
        await showInfoModal(
          context,
          title: "Validasi",
          message: "Jumlah harus > 0.",
        );
        return;
      }
      if (qty > item.qty) {
        await showInfoModal(
          context,
          title: "Validasi",
          message: "Jumlah keluar melebihi stok.",
        );
        return;
      }
      if (sell <= 0) {
        await showInfoModal(
          context,
          title: "Validasi",
          message: "Harga jual harus > 0.",
        );
        return;
      }

      final db = await AppDb.instance.db;
      final nowIso = DateTime.now().toIso8601String();

      await db.transaction((txn) async {
        await txn.update(
          'items',
          {'qty': item.qty - qty, 'updatedAt': nowIso},
          where: 'id = ?',
          whereArgs: [item.id],
        );
        await txn.insert('transactions', {
          'id': uid('tx_'),
          'type': 'OUT',
          'itemId': item.id,
          'itemName': item.name,
          'qty': qty,
          'unitPrice': sell,
          'costPriceAtThatTime': item.costPrice,
          'date': dateIso(selectedDate),
        });
      });

      if (!mounted) return;
      Navigator.pop(context);
      await showInfoModal(
        context,
        title: "NOTIFIKASI",
        message: "Barang keluar berhasil diproses.",
      );
      await load();
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        final pad = MediaQuery.of(context).viewInsets.bottom;
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      surface: Colors.white,
                      surfaceTint: Colors.white,
                    ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + pad),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "PROSES BARANG",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Card tabel mini (rata kolom)
                    AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _miniTableHeader(),
                          const SizedBox(height: 8),
                          _miniTableRow(
                            id: item.id,
                            name: item.name,
                            qty: "${item.qty}",
                            price: rupiah(item.costPrice),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Silahkan tentukan berapa yang ingin anda keluarkan ?",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: "Jumlah"),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: sellCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: "Harga Jual"),
                    ),
                    const SizedBox(height: 10),

                    // Tanggal (date picker)
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setLocal(() => selectedDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          "Tanggal: ${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: submit,
                        child: const Text("KELUARKAN"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> openEditSheet(ItemRow item) async {
    final nameCtrl = TextEditingController(text: item.name);
    final qtyCtrl = TextEditingController(text: item.qty.toString());
    final priceCtrl = TextEditingController(text: item.costPrice.toString());
    final noteCtrl = TextEditingController(text: item.note ?? "");

    Future<void> save() async {
      final name = nameCtrl.text.trim();
      final qty = int.tryParse(qtyCtrl.text.trim());
      final price = int.tryParse(priceCtrl.text.trim());
      final note = noteCtrl.text.trim();

      if (name.isEmpty ||
          qty == null ||
          qty < 0 ||
          price == null ||
          price < 0) {
        await showInfoModal(context,
            title: "Validasi", message: "Data tidak valid.");
        return;
      }

      final db = await AppDb.instance.db;
      await db.update(
        'items',
        {
          'name': name,
          'qty': qty,
          'costPrice': price,
          'note': note,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [item.id],
      );

      if (!mounted) return;
      Navigator.pop(context);
      await load();
      await showInfoModal(context,
          title: "NOTIFIKASI", message: "Produk berhasil diubah.");
    }

    Future<void> deleteItem() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Hapus Produk",
              style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text("Produk ini akan dihapus permanen."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal")),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Hapus")),
          ],
        ),
      );

      if (confirm != true) return;

      final db = await AppDb.instance.db;

      await db.delete('items', where: 'id = ?', whereArgs: [item.id]);

      await db
          .delete('transactions', where: 'itemId = ?', whereArgs: [item.id]);

      if (!mounted) return;
      Navigator.pop(context);
      await load();
      await showInfoModal(context,
          title: "NOTIFIKASI", message: "Produk berhasil dihapus.");
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        final pad = MediaQuery.of(context).viewInsets.bottom;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  surface: Colors.white,
                  surfaceTint: Colors.white,
                ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + pad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle manual (biar mirip HiFi)
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "UBAH PRODUK",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(hintText: "Nama Barang")),
                const SizedBox(height: 10),
                TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "Jumlah")),
                const SizedBox(height: 10),
                TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(hintText: "Harga (Modal)")),
                const SizedBox(height: 10),
                TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(hintText: "Catatan")),

                const SizedBox(height: 14),
                SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                        onPressed: save, child: const Text("SIMPAN"))),
                const SizedBox(height: 8),
                SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: deleteItem,
                        child: const Text("HAPUS PRODUK"))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tableHeader(List<String> cols) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Row(
        children: cols
            .map(
              (c) => Expanded(
                child: Text(
                  c,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _tableRow(List<String> cols, {Widget? opsi}) {
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
              cols[0],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              cols[1],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              cols[2],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              cols[3],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(child: opsi ?? const SizedBox.shrink()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: openSortSheet,
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
        const SectionTitle(title: "Stok Tersedia"),
        const SizedBox(height: 10),
        _tableHeader(["ID", "Nama Barang", "Jumlah", "Harga", "Opsi"]),
        const SizedBox(height: 10),
        if (loading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Belum ada stok. Tambahkan via menu Input Barang.",
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          Column(
            children: items.map((it) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _tableRow(
                  [it.id, it.name, "${it.qty}", rupiah(it.costPrice)],
                  opsi: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => openEditSheet(it),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppTheme.blue,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text(
                            "Ubah",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppTheme.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => showProcessSheet(it),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text("Proses"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
