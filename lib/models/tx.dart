class TxRow {
  final String id;
  final String type;
  final String itemId;
  final String itemName;
  final int qty;
  final int unitPrice;
  final int costPriceAtThatTime;
  final String date;

  TxRow({
    required this.id,
    required this.type,
    required this.itemId,
    required this.itemName,
    required this.qty,
    required this.unitPrice,
    required this.costPriceAtThatTime,
    required this.date,
  });

  factory TxRow.fromMap(Map<String, Object?> m) {
    return TxRow(
      id: m['id'] as String,
      type: m['type'] as String,
      itemId: m['itemId'] as String,
      itemName: m['itemName'] as String,
      qty: (m['qty'] as num).toInt(),
      unitPrice: (m['unitPrice'] as num).toInt(),
      costPriceAtThatTime: (m['costPriceAtThatTime'] as num).toInt(),
      date: m['date'] as String,
    );
  }
}
