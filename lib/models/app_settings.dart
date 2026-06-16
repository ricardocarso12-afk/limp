class AppSettings {
  final String appName;
  final String language;
  final int maxStorageDays;
  final String primaryColor;

  const AppSettings({
    required this.appName,
    required this.language,
    required this.maxStorageDays,
    required this.primaryColor,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      appName: '${json['app_name'] ?? 'T&B Custom Clean'}',
      language: '${json['default_language'] ?? json['language'] ?? 'es'}',
      maxStorageDays: int.tryParse('${json['storage_max_days'] ?? json['max_storage_days'] ?? 3}') ?? 3,
      primaryColor: '${json['primary_color'] ?? '#234F35'}',
    );
  }
}
