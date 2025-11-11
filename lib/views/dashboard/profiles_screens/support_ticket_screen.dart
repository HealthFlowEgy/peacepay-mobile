// lib/views/dashboard/profiles_screens/support_ticket_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/dashboard/btm_navs_controller/profile_controller.dart';
import '../../../utils/custom_color.dart';

class SupportTicketScreen extends GetView<ProfileController> {
  const SupportTicketScreen({super.key});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ---------------- validators ----------------
  String? _validateSubject(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Subject is required';
    if (s.length < 3) return 'Subject is too short';
    if (s.length > 100) return 'Subject is too long (max 100)';
    return null;
  }

  String? _validateDescription(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Description is required';
    if (s.length < 10) return 'Please provide more details (min 10 chars)';
    return null;
  }

  // ---------------- helpers ----------------
  String _fmtSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await controller.supportTicketProcess(
      subject: controller.subjectCtrl.text,
      description: controller.descCtrl.text,
      attachments: controller.attachments.toList(), // List<PlatformFile>
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Support Ticket'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ---------------- Subject ----------------
              Card(
                color: CustomColor.primaryLightColor.withOpacity(0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor.withOpacity(.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: controller.subjectCtrl,
                    textInputAction: TextInputAction.next,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      hintText: 'e.g., Refund issue for order #1234',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateSubject,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ---------------- Description ----------------
              Card(
                color: CustomColor.primaryLightColor.withOpacity(0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor.withOpacity(.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: controller.descCtrl,
                    minLines: 6,
                    maxLines: 12,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText:
                      'Describe the issue in detail. Include steps, expected vs actual, and any error messages.',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: _validateDescription,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ---------------- Attachments ----------------
              Obx(() {
                final files = controller.attachments;
                final totalSize =
                files.fold<int>(0, (sum, f) => sum + f.size);

                return Card(
                  color: CustomColor.primaryLightColor.withOpacity(0.2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.dividerColor.withOpacity(.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Attachments (optional)',
                                style: theme.textTheme.titleMedium),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: controller.pickAttachments,
                              icon: const Icon(Icons.attach_file),
                              label: const Text('Add'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (files.isEmpty)
                          Text('No files selected',
                              style: theme.textTheme.bodyMedium)
                        else ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: files.map((f) {
                              return _AttachmentChip(
                                name: f.name,
                                sizeLabel: _fmtSize(f.size),
                                onRemove: () => controller.removeAttachment(f),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Total: ${_fmtSize(totalSize)} (max 10 MB)',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // ---------------- Submit ----------------
              Obx(() {
                final busy = controller.isLoading.value;
                return SizedBox(
                  height: 48.h,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: CustomColor.primaryLightColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: busy ? null : _submit,
                    icon: busy
                        ?  SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: CircularProgressIndicator(strokeWidth: 1),
                    )
                        : const Icon(Icons.send),
                    label:
                    Text(busy ? 'Submitting...' : 'Submit Ticket'),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.name,
    required this.sizeLabel,
    required this.onRemove,
  });

  final String name;
  final String sizeLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(sizeLabel, style: theme.textTheme.bodySmall),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
