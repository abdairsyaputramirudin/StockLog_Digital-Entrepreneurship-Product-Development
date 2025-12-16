class ItemRow {
  final String id;
  final String name;
  final int qty;
  final int costPrice;
  final String? note;
  final String updatedAt;

  ItemRow({
    required this.id,
    required this.name,
    required this.qty,
    required this.costPrice,
    required this.note,
    required this.updatedAt,
  });

  factory ItemRow.fromMap(Map<String, Object?> m) {
    return ItemRow(
      id: m['id'] as String,
      name: m['name'] as String,
      qty: (m['qty'] as num).toInt(),
      costPrice: (m['costPrice'] as num).toInt(),
      note: m['note'] as String?,
      updatedAt: m['updatedAt'] as String,
    );
  }
}
