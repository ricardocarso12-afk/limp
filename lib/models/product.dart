class Product {
  final int id;
  final String trackingCode;
  final String name;
  final String typeName;
  final String status;
  final String address;
  final double? latitude;
  final double? longitude;
  final int? storageDays;

  const Product({
    required this.id,
    required this.trackingCode,
    required this.name,
    required this.typeName,
    required this.status,
    required this.address,
    this.latitude,
    this.longitude,
    this.storageDays,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      trackingCode: '${json['tracking_code'] ?? json['code'] ?? ''}',
      name: '${json['name'] ?? ''}',
      typeName: '${json['type_name'] ?? json['product_type_name'] ?? json['type'] ?? ''}',
      status: '${json['status'] ?? ''}',
      address: '${json['address_text'] ?? json['address'] ?? ''}',
      latitude: double.tryParse('${json['latitude'] ?? ''}'),
      longitude: double.tryParse('${json['longitude'] ?? ''}'),
      storageDays: int.tryParse('${json['storage_days'] ?? ''}'),
    );
  }
}
