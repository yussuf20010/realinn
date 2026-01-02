class PaymentDocument {
  final int id;
  final int? paymentPlanId;
  final String documentUrl;
  final String? notes;
  final String status; // e.g., 'pending', 'approved', 'rejected'
  final String? createdAt;
  final String? updatedAt;

  PaymentDocument({
    required this.id,
    this.paymentPlanId,
    required this.documentUrl,
    this.notes,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentDocument.fromJson(Map<String, dynamic> json) {
    return PaymentDocument(
      id: json['id'] as int,
      paymentPlanId: json['payment_plan_id'] as int?,
      documentUrl: json['document_url'] as String? ?? json['document'] as String? ?? '',
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_plan_id': paymentPlanId,
      'document_url': documentUrl,
      'notes': notes,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

