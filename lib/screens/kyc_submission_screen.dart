/// KYC Submission Screen - Full End-to-End Flow
/// 
/// MISSING COMPONENT FIX - From Mobile App Audit Report

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum KYCLevel { bronze, silver, gold }

enum DocumentType {
  nationalIdFront,
  nationalIdBack,
  selfie,
  wetSignature,
  addressProof,
}

class KYCSubmissionScreen extends StatefulWidget {
  final KYCLevel currentLevel;
  final KYCLevel targetLevel;

  const KYCSubmissionScreen({
    super.key,
    required this.currentLevel,
    required this.targetLevel,
  });

  @override
  State<KYCSubmissionScreen> createState() => _KYCSubmissionScreenState();
}

class _KYCSubmissionScreenState extends State<KYCSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  
  int _currentStep = 0;
  bool _isSubmitting = false;
  
  // Form fields
  final _nationalIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _selectedGovernorate;
  
  // Documents
  final Map<DocumentType, File?> _documents = {};

  List<DocumentType> get _requiredDocuments {
    if (widget.targetLevel == KYCLevel.silver) {
      return [
        DocumentType.nationalIdFront,
        DocumentType.nationalIdBack,
        DocumentType.selfie,
      ];
    } else {
      return [
        DocumentType.nationalIdFront,
        DocumentType.nationalIdBack,
        DocumentType.selfie,
        DocumentType.wetSignature,
        DocumentType.addressProof,
      ];
    }
  }

  String _getDocumentLabel(DocumentType type) {
    switch (type) {
      case DocumentType.nationalIdFront:
        return 'البطاقة الشخصية (الأمام)';
      case DocumentType.nationalIdBack:
        return 'البطاقة الشخصية (الخلف)';
      case DocumentType.selfie:
        return 'صورة شخصية';
      case DocumentType.wetSignature:
        return 'التوقيع الرطب';
      case DocumentType.addressProof:
        return 'إثبات العنوان';
    }
  }

  String _getDocumentHint(DocumentType type) {
    switch (type) {
      case DocumentType.nationalIdFront:
        return 'صورة واضحة للوجه الأمامي للبطاقة';
      case DocumentType.nationalIdBack:
        return 'صورة واضحة للوجه الخلفي للبطاقة';
      case DocumentType.selfie:
        return 'صورة شخصية واضحة للوجه';
      case DocumentType.wetSignature:
        return 'صورة لتوقيعك على ورقة بيضاء';
      case DocumentType.addressProof:
        return 'فاتورة مرافق أو كشف حساب بنكي';
    }
  }

  Future<void> _pickImage(DocumentType type) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _documents[type] = File(image.path);
      });
    }
  }

  bool get _allDocumentsUploaded {
    return _requiredDocuments.every((doc) => _documents[doc] != null);
  }

  Future<void> _submitKYC() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_allDocumentsUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى رفع جميع المستندات المطلوبة')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // API call to submit KYC
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('تم إرسال الطلب'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                SizedBox(height: 16),
                Text(
                  'تم إرسال طلب التحقق بنجاح.\nسيتم مراجعته خلال 24-48 ساعة.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ترقية إلى ${widget.targetLevel == KYCLevel.silver ? "الفضي" : "الذهبي"}',
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
        body: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _submitKYC();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isSubmitting && _currentStep == 2
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currentStep == 2 ? 'إرسال الطلب' : 'التالي',
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('السابق'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Personal Info
            Step(
              title: const Text('البيانات الشخصية'),
              content: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nationalIdController,
                      decoration: const InputDecoration(
                        labelText: 'الرقم القومي',
                        hintText: 'أدخل الرقم القومي المكون من 14 رقم',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 14,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'مطلوب';
                        if (v.length != 14) return 'يجب أن يكون 14 رقم';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الكامل',
                        hintText: 'كما هو مكتوب في البطاقة',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        _dateOfBirth == null
                            ? 'تاريخ الميلاد'
                            : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                      ),
                      leading: const Icon(Icons.calendar_today),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime(1990),
                          firstDate: DateTime(1920),
                          lastDate: DateTime.now().subtract(
                            const Duration(days: 18 * 365),
                          ),
                        );
                        if (date != null) {
                          setState(() => _dateOfBirth = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGovernorate,
                      decoration: const InputDecoration(
                        labelText: 'المحافظة',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'cairo', child: Text('القاهرة')),
                        DropdownMenuItem(value: 'giza', child: Text('الجيزة')),
                        DropdownMenuItem(value: 'alex', child: Text('الإسكندرية')),
                        DropdownMenuItem(value: 'other', child: Text('أخرى')),
                      ],
                      onChanged: (v) => setState(() => _selectedGovernorate = v),
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان التفصيلي',
                        prefixIcon: Icon(Icons.home),
                      ),
                      maxLines: 2,
                      validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
                    ),
                  ],
                ),
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),

            // Step 2: Documents
            Step(
              title: const Text('المستندات'),
              content: Column(
                children: _requiredDocuments.map((docType) {
                  final file = _documents[docType];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: file != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                file,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_photo_alternate),
                            ),
                      title: Text(_getDocumentLabel(docType)),
                      subtitle: Text(
                        file != null ? 'تم الرفع' : _getDocumentHint(docType),
                        style: TextStyle(
                          color: file != null ? Colors.green : Colors.grey,
                        ),
                      ),
                      trailing: file != null
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => setState(() => _documents.remove(docType)),
                            )
                          : null,
                      onTap: () => _pickImage(docType),
                    ),
                  );
                }).toList(),
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),

            // Step 3: Review
            Step(
              title: const Text('مراجعة وإرسال'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'يرجى مراجعة البيانات قبل الإرسال:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem('الرقم القومي', _nationalIdController.text),
                  _buildReviewItem('الاسم', _fullNameController.text),
                  _buildReviewItem('المحافظة', _selectedGovernorate ?? '-'),
                  _buildReviewItem('المستندات', '${_documents.length}/${_requiredDocuments.length}'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'سيتم مراجعة طلبك خلال 24-48 ساعة وسنرسل لك إشعاراً بالنتيجة.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
              state: StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nationalIdController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
