class SupportedLanguage {
  const SupportedLanguage({required this.code, required this.name});

  final String code;
  final String name;

  static SupportedLanguage fromJsonValue(dynamic value) {
    if (value is String) {
      return SupportedLanguage(code: value, name: _fallbackName(value));
    }
    if (value is Map) {
      final code = '${value['code'] ?? value['language_code'] ?? ''}';
      return SupportedLanguage(
        code: code,
        name:
            '${value['name'] ?? value['display_name'] ?? _fallbackName(code)}',
      );
    }
    throw const FormatException('Invalid localization language payload');
  }

  static String _fallbackName(String code) => switch (code) {
    'en' => 'English',
    'ru' => 'Русский',
    'uz' => 'O‘zbek',
    _ => code.toUpperCase(),
  };
}
