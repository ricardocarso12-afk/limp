class ProductType {
  final int id;
  final String name;

  const ProductType({required this.id, required this.name});

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: '${json['name'] ?? ''}',
    );
  }
}
