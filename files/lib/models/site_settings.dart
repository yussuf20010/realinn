class SiteSettings {
  final String? logo;
  final String? websiteTitle;
  final String? primaryColor;

  SiteSettings({
    this.logo,
    this.websiteTitle,
    this.primaryColor,
  });

  factory SiteSettings.fromJson(Map<String, dynamic> json) {
    return SiteSettings(
      logo: json['logo'],
      websiteTitle: json['website_title'],
      primaryColor: json['primary_color'],
    );
  }
} 