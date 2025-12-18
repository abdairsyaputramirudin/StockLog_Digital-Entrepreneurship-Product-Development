import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db/db.dart';
import '../ui/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final Database db = await AppDb.instance.db;
    final rows = await db.query('profile', where: 'id = 1', limit: 1);
    if (rows.isNotEmpty) {
      nameCtrl.text = (rows.first['name'] as String?) ?? "Lisan";
      emailCtrl.text = (rows.first['email'] as String?) ?? "";
      phoneCtrl.text = (rows.first['phone'] as String?) ?? "";
    }
    setState(() => loading = false);
  }

  Future<void> _save() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      await showInfoModal(context,
          title: "Validasi", message: "Nama tidak boleh kosong.");
      return;
    }

    final Database db = await AppDb.instance.db;
    await db.update(
      'profile',
      {
        'name': name,
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
      },
      where: 'id = 1',
    );

    await showInfoModal(context,
        title: "NOTIFIKASI", message: "Profil berhasil disimpan.");
  }

  Future<void> _resetAllData() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white, // ✅ hilangkan pink
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          "Konfirmasi",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Colors.black, // ✅ judul tidak putih
          ),
        ),
        content: const Text(
          "Hapus semua data stok & transaksi?\n(Profil tetap tersimpan)",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Batal",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue, // ✅ tema biru
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Hapus",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final Database db = await AppDb.instance.db;
    await db.delete('transactions');
    await db.delete('items');

    await showInfoModal(context,
        title: "NOTIFIKASI",
        message: "Data stok & transaksi berhasil dikosongkan.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionTitle(title: "Profil", subtitle: "Ubah data pengguna"),
            const SizedBox(height: 12),
            if (loading)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator()))
            else ...[
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(hintText: "Nama")),
              const SizedBox(height: 10),
              TextField(
                  controller: emailCtrl,
                  decoration:
                      const InputDecoration(hintText: "Email (opsional)")),
              const SizedBox(height: 10),
              TextField(
                  controller: phoneCtrl,
                  decoration:
                      const InputDecoration(hintText: "No HP (opsional)")),
              const SizedBox(height: 14),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: _save, child: const Text("SIMPAN"))),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _resetAllData,
                  child: const Text("(Kosongkan Stok & Transaksi)"),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
