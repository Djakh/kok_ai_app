class ApiConfig {
  ApiConfig.internal();

  static String get baseUrl {
    const value = String.fromEnvironment('API_BASE_URL');
    if (value.isNotEmpty) return value;
    return 'http://10.0.2.2:8000/api/v1';
  }
}
