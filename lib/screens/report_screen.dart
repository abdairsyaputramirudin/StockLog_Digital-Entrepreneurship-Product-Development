import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../ui/app_theme.dart';
import '../ui/widgets.dart';
import '../services/report_data.dart';
import '../services/report_pdf.dart';

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
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Future<void> _printReport() async {
    if (from.isAfter(to)) {
      await showInfoModal(context,
          title: "Validasi", message: "Rentang tanggal tidak valid.");
      return;
    }

    final userName = await ReportData.getUserName();

    // 1) STOCK
    if (type == ReportType.stok) {
      final rows = await ReportData.stockRows();
      final bytes = await ReportPdf.build(
        PdfReportConfig(
          title: "Laporan Barang Tersedia",
          userName: userName,
          subtitle: "Berisi daftar stok barang tersedia saat ini.",
          headers: const ["ID", "Nama Barang", "Jumlah", "Harga", "Total"],
          rows: rows,
        ),
      );

      await Printing.layoutPdf(onLayout: (_) async => bytes);
      return;
    }

    // 2) TRANSAKSI MASUK/KELUAR
    final txType = (type == ReportType.masuk) ? "IN" : "OUT";
    final rows = await ReportData.txRows(type: txType, from: from, to: to);

    final bytes = await ReportPdf.build(
      PdfReportConfig(
        title: type == ReportType.masuk
            ? "Laporan Transaksi Masuk"
            : "Laporan Transaksi Keluar",
        userName: userName,
        subtitle:
            "Periode: ${ReportPdf.fmtDate(from)} - ${ReportPdf.fmtDate(to)}",
        headers: const ["ID", "Nama Barang", "Jumlah", "Total", "Tanggal"],
        rows: rows,
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: "LAPORAN",
          subtitle: "Silahkan pilih jenis laporan yang ingin anda cetak",
        ),
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
                  child: Text(
                    "Dari: ${from.day}/${from.month}/${from.year}",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
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
                  child: Text(
                    "Sampai: ${to.day}/${to.month}/${to.year}",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _printReport,
            child: const Text("CETAK"),
          ),
        ),
      ],
    );
  }
}
