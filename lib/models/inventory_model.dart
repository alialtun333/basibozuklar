class InventoryModel {
  String id, name, category, owner;

  InventoryModel({
    required this.id,
    required this.name,
    required this.category,
    this.owner = '-',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'owner': owner,
  };

  static InventoryModel fromMap(Map<String, dynamic> m) => InventoryModel(
    id: m['id'] ?? '',
    name: m['name'] ?? '',
    category: m['category'] ?? '',
    owner: m['owner'] ?? '-',
  );
}
