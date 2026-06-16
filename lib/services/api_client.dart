import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/product.dart';
import '../models/product_type.dart';
import '../models/user.dart';
import 'session_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiClient {
  final SessionService session;
  ApiClient(this.session);

  Future<Uri> _uri(String route, [Map<String, String>? params]) async {
    final base = await session.getApiUrl();
    final map = <String, String>{'r': route, ...?params};
    final uri = Uri.parse(base);
    return uri.replace(queryParameters: {...uri.queryParameters, ...map});
  }

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await session.getToken();
    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response response) {
    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode >= 400 || decoded is Map && decoded['ok'] == false) {
      throw ApiException(decoded is Map ? '${decoded['message'] ?? decoded['error'] ?? 'API error'}' : 'API error', statusCode: response.statusCode);
    }
    return decoded;
  }

  Future<bool> ping() async {
    final response = await http.get(await _uri('mobile/ping'));
    final data = _decode(response);
    return data['ok'] == true;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String deviceName,
    required String platform,
    required String appVersion,
  }) async {
    final deviceUuid = const Uuid().v4();
    final response = await http.post(
      await _uri('mobile/login'),
      headers: await _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_uuid': deviceUuid,
        'device_name': deviceName,
        'platform': platform,
        'app_version': appVersion,
      }),
    );
    final data = _decode(response) as Map<String, dynamic>;
    final token = '${data['token'] ?? ''}';
    if (token.isEmpty) throw ApiException('Token not returned');
    await session.saveToken(token);
    return data;
  }

  Future<User> me() async {
    final response = await http.get(await _uri('mobile/me'), headers: await _headers(json: false));
    final data = _decode(response) as Map<String, dynamic>;
    return User.fromJson(Map<String, dynamic>.from(data['user'] ?? data));
  }

  Future<void> logout() async {
    try {
      await http.post(await _uri('mobile/logout'), headers: await _headers());
    } finally {
      await session.logout();
    }
  }

  Future<List<ProductType>> productTypes() async {
    final response = await http.get(await _uri('mobile/product-types'), headers: await _headers(json: false));
    final data = _decode(response);
    final items = data is Map ? (data['items'] ?? data['data'] ?? []) : data;
    return List<Map<String, dynamic>>.from(items).map(ProductType.fromJson).toList();
  }

  Future<List<User>> pickupUsers() async {
    final response = await http.get(await _uri('mobile/users/pickup'), headers: await _headers(json: false));
    final data = _decode(response);
    final items = data is Map ? (data['items'] ?? data['data'] ?? []) : data;
    return List<Map<String, dynamic>>.from(items).map(User.fromJson).toList();
  }

  Future<List<Product>> products() async {
    final response = await http.get(await _uri('mobile/products'), headers: await _headers(json: false));
    final data = _decode(response);
    final items = data is Map ? (data['items'] ?? data['data'] ?? []) : data;
    return List<Map<String, dynamic>>.from(items).map(Product.fromJson).toList();
  }

  Future<Product> scanProduct(String code) async {
    final response = await http.get(await _uri('mobile/scan', {'code': code}), headers: await _headers(json: false));
    final data = _decode(response) as Map<String, dynamic>;
    return Product.fromJson(Map<String, dynamic>.from(data['product'] ?? data['item'] ?? data));
  }

  Future<Map<String, dynamic>> productExit({
    required String trackingCode,
    required int pickedByUserId,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    final response = await http.post(
      await _uri('mobile/product-exit'),
      headers: await _headers(),
      body: jsonEncode({
        'tracking_code': trackingCode,
        'picked_by_user_id': pickedByUserId,
        'latitude': latitude,
        'longitude': longitude,
        'notes': notes ?? '',
      }),
    );
    return Map<String, dynamic>.from(_decode(response));
  }

  Future<Map<String, dynamic>> productEntry({
    required String name,
    required int productTypeId,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required List<File> photos,
  }) async {
    if (photos.length != 5) throw ApiException('5 photos required');
    final request = http.MultipartRequest('POST', await _uri('mobile/product-entry'));
    request.headers.addAll(await _headers(json: false));
    request.fields.addAll({
      'name': name,
      'product_type_id': '$productTypeId',
      'description': description,
      'address_text': address,
      'latitude': '$latitude',
      'longitude': '$longitude',
    });
    for (var i = 0; i < 5; i++) {
      request.files.add(await http.MultipartFile.fromPath('photo_${i + 1}', photos[i].path));
    }
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return Map<String, dynamic>.from(_decode(response));
  }

  Future<List<Product>> storageAlerts() async {
    final response = await http.get(await _uri('mobile/storage-alerts'), headers: await _headers(json: false));
    final data = _decode(response);
    final items = data is Map ? (data['items'] ?? data['data'] ?? []) : data;
    return List<Map<String, dynamic>>.from(items).map(Product.fromJson).toList();
  }

  Future<Map<String, dynamic>> syncOperations(List<Map<String, dynamic>> operations) async {
    final response = await http.post(
      await _uri('mobile/sync'),
      headers: await _headers(),
      body: jsonEncode({'operations': operations}),
    );
    return Map<String, dynamic>.from(_decode(response));
  }
}
