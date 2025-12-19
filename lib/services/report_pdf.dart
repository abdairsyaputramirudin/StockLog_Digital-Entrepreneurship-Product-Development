import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfRow {
  final List<String> cells;
  PdfRow(this.cells);
}

class PdfReportConfig {
  final String title;
  final String userName;
  final String subtitle;
  final List<String> headers;
  final List<PdfRow> rows;
  final DateTime printedAt;

  PdfReportConfig({
    required this.title,
    required this.userName,
    required this.subtitle,
    required this.headers,
    required this.rows,
    DateTime? printedAt,
  }) : printedAt = printedAt ?? DateTime.now();
}

class ReportPdf {
  static final _dtf = DateFormat('dd/MM/yyyy HH:mm');

  static String fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  static Future<Uint8List> build(PdfReportConfig cfg) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 30),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Halaman ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ),
        build: (_) => [
          _header(cfg),
          pw.SizedBox(height: 14),
          _table(cfg),
          pw.SizedBox(height: 10),
          pw.Text(
            'Total baris: ${cfg.rows.length}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _header(PdfReportConfig cfg) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.blue, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            cfg.title,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(cfg.subtitle,
              style:
                  const pw.TextStyle(fontSize: 11, color: PdfColors.grey800)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Nama: ${cfg.userName}',
                  style: const pw.TextStyle(
                      fontSize: 11, color: PdfColors.grey800)),
              pw.Text('Dicetak: ${_dtf.format(cfg.printedAt)}',
                  style: const pw.TextStyle(
                      fontSize: 11, color: PdfColors.grey800)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _table(PdfReportConfig cfg) {
    final data = <List<String>>[
      cfg.headers,
      ...cfg.rows.map((r) => r.cells),
    ];

    final colCount = cfg.headers.length;
    final colWidths = <int, pw.TableColumnWidth>{};

    if (colCount == 5) {
      colWidths[0] = const pw.FlexColumnWidth(2);
      colWidths[1] = const pw.FlexColumnWidth(6);
      colWidths[2] = const pw.FlexColumnWidth(2);
      colWidths[3] = const pw.FlexColumnWidth(3);
      colWidths[4] = const pw.FlexColumnWidth(3);
    } else if (colCount == 4) {
      colWidths[0] = const pw.FlexColumnWidth(2);
      colWidths[1] = const pw.FlexColumnWidth(6);
      colWidths[2] = const pw.FlexColumnWidth(2);
      colWidths[3] = const pw.FlexColumnWidth(3);
    } else {
      for (var i = 0; i < colCount; i++) {
        colWidths[i] = const pw.FlexColumnWidth(1);
      }
    }

    return pw.TableHelper.fromTextArray(
      data: data,
      columnWidths: colWidths,
      headerStyle: pw.TextStyle(
          fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
      headerAlignment: pw.Alignment.center,
      cellAlignment: pw.Alignment.center,
      cellStyle: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
      cellHeight: 26,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }
}
