class ProfileSettings {
  const ProfileSettings({
    required this.languageCode,
    required this.privacyProfilePublic,
    required this.notificationsEnabled,
  });

  final String languageCode;
  final bool privacyProfilePublic;
  final bool notificationsEnabled;

  factory ProfileSettings.fromJson(Map<String, dynamic> json) =>
      ProfileSettings(
        languageCode: '${json['language_code'] ?? 'en'}',
        privacyProfilePublic: json['privacy_profile_public'] == true,
        notificationsEnabled: json['notifications_enabled'] == true,
      );
}
