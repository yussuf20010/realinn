class SiteSettings {
  final String? logo;
  final String? logoTwo;
  final String? favicon;
  final String? websiteTitle;
  final String? primaryColor;
  final String? emailAddress;
  final String? contactNumber;
  final String? address;
  final int? whatsappStatus;
  final String? whatsappNumber;
  final String? whatsappHeaderTitle;
  final int? whatsappPopupStatus;
  final String? whatsappPopupMessage;
  final int? maintenanceStatus;
  final String? maintenanceImg;
  final String? maintenanceMsg;

  SiteSettings({
    this.logo,
    this.logoTwo,
    this.favicon,
    this.websiteTitle,
    this.primaryColor,
    this.emailAddress,
    this.contactNumber,
    this.address,
    this.whatsappStatus,
    this.whatsappNumber,
    this.whatsappHeaderTitle,
    this.whatsappPopupStatus,
    this.whatsappPopupMessage,
    this.maintenanceStatus,
    this.maintenanceImg,
    this.maintenanceMsg,
  });

  factory SiteSettings.fromJson(Map<String, dynamic> json) {
    return SiteSettings(
      logo: json['logo'],
      logoTwo: json['logo_two'],
      favicon: json['favicon'],
      websiteTitle: json['website_title'],
      primaryColor: json['primary_color'],
      emailAddress: json['email_address'],
      contactNumber: json['contact_number'],
      address: json['address'],
      whatsappStatus: json['whatsapp_status'] is int 
          ? json['whatsapp_status'] 
          : (json['whatsapp_status'] is String 
              ? int.tryParse(json['whatsapp_status']) 
              : null),
      whatsappNumber: json['whatsapp_number'],
      whatsappHeaderTitle: json['whatsapp_header_title'],
      whatsappPopupStatus: json['whatsapp_popup_status'] is int 
          ? json['whatsapp_popup_status'] 
          : (json['whatsapp_popup_status'] is String 
              ? int.tryParse(json['whatsapp_popup_status']) 
              : null),
      whatsappPopupMessage: json['whatsapp_popup_message'],
      maintenanceStatus: json['maintenance_status'] is int 
          ? json['maintenance_status'] 
          : (json['maintenance_status'] is String 
              ? int.tryParse(json['maintenance_status']) 
              : null),
      maintenanceImg: json['maintenance_img'],
      maintenanceMsg: json['maintenance_msg'],
    );
  }
} 