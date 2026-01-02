import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/constants/app_colors.dart';
import '../../models/payment_document.dart';
import '../../services/payment_document_service.dart';

class PaymentDocumentsPage extends ConsumerStatefulWidget {
  const PaymentDocumentsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PaymentDocumentsPage> createState() => _PaymentDocumentsPageState();
}

class _PaymentDocumentsPageState extends ConsumerState<PaymentDocumentsPage> {
  List<PaymentDocument> _documents = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final documents = await PaymentDocumentService.getDocuments();
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadDocument() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.single.path == null) {
        return; // User cancelled
      }

      final filePath = result.files.single.path!;
      final file = File(filePath);

      // Show dialog for notes
      final notes = await _showNotesDialog();

      setState(() {
        _isUploading = true;
      });

      try {
        await PaymentDocumentService.uploadDocument(
          documentFile: file,
          notes: notes,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('document_uploaded_successfully'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Reload documents
        await _loadDocuments();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('upload_failed'.tr() + ': ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('file_picker_error'.tr() + ': ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showNotesDialog() async {
    String? notes;
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('add_notes'.tr()),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'notes_optional'.tr(),
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                notes = controller.text.trim().isEmpty ? null : controller.text.trim();
                Navigator.pop(context);
              },
              child: Text('continue'.tr()),
            ),
          ],
        );
      },
    );
    return notes;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('extra_payment'.tr()),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _errorMessage!,
                        style: TextStyle(fontSize: 16.sp),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadDocuments,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Upload button
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadDocument,
                        icon: _isUploading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(Icons.upload_file),
                        label: Text(
                          _isUploading ? 'uploading'.tr() : 'upload_document'.tr(),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),

                    // Documents list
                    Expanded(
                      child: _documents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 64.sp,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'no_documents'.tr(),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadDocuments,
                              color: primaryColor,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                itemCount: _documents.length,
                                itemBuilder: (context, index) {
                                  final document = _documents[index];
                                  return _buildDocumentCard(document, primaryColor, isTablet);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDocumentCard(PaymentDocument document, Color primaryColor, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Show document details or open document
          _showDocumentDetails(document);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.description,
                      color: primaryColor,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document #${document.id}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _getStatusColor(document.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            document.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(document.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              if (document.notes != null && document.notes!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note,
                        size: 16.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          document.notes!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (document.createdAt != null) ...[
                SizedBox(height: 8.h),
                Text(
                  'uploaded_on'.tr() + ': ${_formatDate(document.createdAt!)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showDocumentDetails(PaymentDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('document_details'.tr()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('id'.tr(), document.id.toString()),
              if (document.paymentPlanId != null)
                _buildDetailRow('payment_plan_id'.tr(), document.paymentPlanId.toString()),
              _buildDetailRow('status'.tr(), document.status.toUpperCase()),
              if (document.notes != null && document.notes!.isNotEmpty)
                _buildDetailRow('notes'.tr(), document.notes!),
              if (document.createdAt != null)
                _buildDetailRow('created_at'.tr(), _formatDate(document.createdAt!)),
              if (document.updatedAt != null)
                _buildDetailRow('updated_at'.tr(), _formatDate(document.updatedAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
          if (document.documentUrl.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                // Open document URL
                // You can use url_launcher here if needed
                Navigator.pop(context);
              },
              child: Text('view_document'.tr()),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}

