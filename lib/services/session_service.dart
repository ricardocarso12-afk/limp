import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _secure = FlutterSecureStorage();
  static const _tokenKey = 'tb_mobile_token';
  static const _apiUrlKey = 'tb_api_url';
  static const _languageKey = 'tb_language';

  Future<void> saveToken(String token) => _secure.write(key: _tokenKey, value: token);
  Future<String?> getToken() => _secure.read(key: _tokenKey);
  Future<void> clearToken() => _secure.delete(key: _tokenKey);

  Future<void> saveApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrlKey, url.trim());
  }

  Future<String> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiUrlKey) ?? 'https://tudominio.com/public/api.php';
  }

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'es';
  }

  Future<void> logout() async {
    await clearToken();
  }
}
