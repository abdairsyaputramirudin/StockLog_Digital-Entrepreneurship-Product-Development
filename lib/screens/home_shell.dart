import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db/db.dart';
import '../ui/app_theme.dart';
import '../ui/widgets.dart';

import 'stock_screen.dart';
import 'input_screen.dart';
import 'transactions_screen.dart';
import 'finance_screen.dart';
import 'report_screen.dart';

enum TopMenu { stok, input, transaksi, keuangan, laporan }

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  TopMenu menu = TopMenu.stok;
  String name = "Lisan";

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final Database db = await AppDb.instance.db;
    final rows = await db.query('profile', where: 'id = 1', limit: 1);
    if (rows.isNotEmpty) {
      setState(() => name =
          (rows.first['name'] as String?)?.trim().isNotEmpty == true
              ? rows.first['name'] as String
              : "Lisan");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (menu) {
      case TopMenu.stok:
        body = const StockScreen();
        break;
      case TopMenu.input:
        body = const InputScreen();
        break;
      case TopMenu.transaksi:
        body = const TransactionsScreen();
        break;
      case TopMenu.keuangan:
        body = const FinanceScreen();
        break;
      case TopMenu.laporan:
        body = const ReportScreen();
        break;
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadName, // pull-to-refresh update nama
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            children: [
              _Header(name: name),
              const SizedBox(height: 14),
              AppCard(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: MenuIconButton(
                        icon: Icons.inventory_2_outlined,
                        label: "Stok\nTersedia",
                        active: menu == TopMenu.stok,
                        onTap: () => setState(() => menu = TopMenu.stok),
                      ),
                    ),
                    Expanded(
                      child: MenuIconButton(
                        icon: Icons.add_to_photos_outlined,
                        label: "Input\nBarang",
                        active: menu == TopMenu.input,
                        onTap: () => setState(() => menu = TopMenu.input),
                      ),
                    ),
                    Expanded(
                      child: MenuIconButton(
                        icon: Icons.receipt_long_outlined,
                        label: "Transaksi",
                        active: menu == TopMenu.transaksi,
                        onTap: () => setState(() => menu = TopMenu.transaksi),
                      ),
                    ),
                    Expanded(
                      child: MenuIconButton(
                        icon: Icons.account_balance_wallet_outlined,
                        label: "Keuangan",
                        active: menu == TopMenu.keuangan,
                        onTap: () => setState(() => menu = TopMenu.keuangan),
                      ),
                    ),
                    Expanded(
                      child: MenuIconButton(
                        icon: Icons.description_outlined,
                        label: "Laporan",
                        active: menu == TopMenu.laporan,
                        onTap: () => setState(() => menu = TopMenu.laporan),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              body,
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Selamat Datang, $name",
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text("Silahkan pilih menu yang anda ingin gunakan",
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w600)),
          ]),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
            ],
            image: const DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage("https://i.pravatar.cc/100?img=12")),
          ),
        ),
      ],
    );
  }
}
