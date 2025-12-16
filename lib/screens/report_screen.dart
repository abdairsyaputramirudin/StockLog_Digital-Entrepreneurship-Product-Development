import 'package:flutter/material.dart';
import '../ui/app_theme.dart';
import '../ui/widgets.dart';

enum ReportType { stok, masuk, keluar }

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportType type = ReportType.stok;
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();

  Future<void> pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: from,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => from = picked);
  }

  Future<void> pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: to,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => to = picked);
  }

  @override
  Widget build(BuildContext context) {
    String label(ReportType t) {
      switch (t) {
        case ReportType.stok:
          return "Cetak Laporan Barang Tersedia";
        case ReportType.masuk:
          return "Cetak Laporan Transaksi Masuk";
        case ReportType.keluar:
          return "Cetak Laporan Transaksi Keluar";
      }
    }

    Widget pickBtn(String text, bool active, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppTheme.blue : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: active ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w900)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
            title: "LAPORAN",
            subtitle: "Silahkan pilih jenis laporan yang ingin anda cetak"),
        const SizedBox(height: 12),
        pickBtn(label(ReportType.stok), type == ReportType.stok,
            () => setState(() => type = ReportType.stok)),
        const SizedBox(height: 10),
        pickBtn(label(ReportType.masuk), type == ReportType.masuk,
            () => setState(() => type = ReportType.masuk)),
        const SizedBox(height: 10),
        pickBtn(label(ReportType.keluar), type == ReportType.keluar,
            () => setState(() => type = ReportType.keluar)),
        const SizedBox(height: 14),
        const Text("Pilih Rentang Tanggal :",
            style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: pickFrom,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(14)),
                  child: Text("Dari: ${from.day}/${from.month}/${from.year}",
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: pickTo,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(14)),
                  child: Text("Sampai: ${to.day}/${to.month}/${to.year}",
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              if (from.isAfter(to)) {
                await showInfoModal(context,
                    title: "Validasi", message: "Rentang tanggal tidak valid.");
                return;
              }
              await showInfoModal(context,
                  title: "NOTIFIKASI", message: "Laporan Berhasi DI Cetak");
            },
            child: const Text("CETAK"),
          ),
        ),
      ],
    );
  }
}
