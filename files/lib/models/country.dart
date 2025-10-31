class Country {
  final String name;
  final String code; // ISO 3166-1 alpha-2 code (e.g., "US", "AE")
  final String dialCode; // Phone dial code (e.g., "+1", "+971")
  final String flag; // Emoji flag or flag image URL
  final String? flagUrl; // Optional flag image URL

  Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    this.flagUrl,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final code = json['cca2'] ?? json['alpha2Code'] ?? json['code'] ?? '';
    final name = json['name'] is Map
        ? (json['name']?['common'] ?? json['name']?['official'] ?? '')
        : (json['name']?.toString() ?? '');

    return Country(
      name: name,
      code: code,
      dialCode: _extractDialCode(json, code),
      flag: _getFlagEmoji(code),
      flagUrl: json['flags'] is Map
          ? (json['flags']?['png'] ?? json['flags']?['svg'])
          : (json['flagImageUrl']?.toString()),
    );
  }

  static String _extractDialCode(
      Map<String, dynamic> json, String countryCode) {
    // Try different possible fields for dial code
    if (json['idd'] is Map && json['idd']?['root'] != null) {
      final root = json['idd']?['root'].toString();
      final suffixes = json['idd']?['suffixes'] as List?;
      if (suffixes != null && suffixes.isNotEmpty) {
        return '$root${suffixes[0]}';
      }
      return root ?? _getDefaultDialCode(countryCode);
    }
    if (json['callingCode'] != null) {
      final codes = json['callingCode'] is List
          ? json['callingCode']
          : [json['callingCode']];
      if (codes.isNotEmpty) return '+${codes[0]}';
    }
    if (json['callingCodes'] != null) {
      final codes = json['callingCodes'] as List;
      if (codes.isNotEmpty) return '+${codes[0]}';
    }
    if (json['dialCode'] != null) {
      final code = json['dialCode'].toString();
      return code.startsWith('+') ? code : '+$code';
    }
    // Fallback: generate from common codes
    return _getDefaultDialCode(countryCode);
  }

  static String _getDefaultDialCode(String code) {
    // Common dial codes mapping
    final Map<String, String> commonCodes = {
      'AE': '+971',
      'SA': '+966',
      'EG': '+20',
      'US': '+1',
      'GB': '+44',
      'FR': '+33',
      'DE': '+49',
      'IT': '+39',
      'ES': '+34',
      'CA': '+1',
      'AU': '+61',
      'JP': '+81',
      'CN': '+86',
      'IN': '+91',
      'BR': '+55',
      'MX': '+52',
      'RU': '+7',
      'KR': '+82',
      'TR': '+90',
      'NL': '+31',
    };
    return commonCodes[code.toUpperCase()] ?? '+1';
  }

  static String _getFlagEmoji(String countryCode) {
    if (countryCode.isEmpty || countryCode.length != 2) return '🏳️';

    final codePoints = countryCode
        .toUpperCase()
        .codeUnits
        .map((char) => 127397 + char)
        .toList();

    return String.fromCharCodes(codePoints);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'dialCode': dialCode,
      'flag': flag,
      'flagUrl': flagUrl,
    };
  }
}
