import 'dart:io';

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

import '../../utils/basic_widget_imports.dart';

class CustomUploadFileWidget extends StatefulWidget {
  const CustomUploadFileWidget({
    super.key,
    required this.labelText,
    required this.onTap,
    this.hint = "",
    this.optional = "",
    this.allowCamera = true,
    this.allowGallery = true,
    this.allowFiles = true,
  });

  final String labelText, optional, hint;
  final ValueChanged<File> onTap;
  final bool allowCamera;
  final bool allowGallery;
  final bool allowFiles;

  @override
  State<CustomUploadFileWidget> createState() => _CustomUploadFileWidgetState();
}

class _CustomUploadFileWidgetState extends State<CustomUploadFileWidget> {
  File? file;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromCamera() async {
    final XFile? shot =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 92);
    if (shot == null) return;
    final f = File(shot.path);
    setState(() => file = f);
    widget.onTap(f);
  }

  Future<void> _pickFromGallery() async {
    final XFile? img =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
    if (img == null) return;
    final f = File(img.path);
    setState(() => file = f);
    widget.onTap(f);
  }

  Future<void> _pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles(withReadStream: false);
    if (result == null || result.files.single.path == null) return;
    final f = File(result.files.single.path!);
    setState(() => file = f);
    widget.onTap(f);
  }

  void _showPickerSheet() {
    final actions = <_PickerAction>[
      if (widget.allowCamera)
        _PickerAction(
            icon: Icons.photo_camera_outlined,
            label: 'Take photo',
            onTap: _pickFromCamera),
      if (widget.allowGallery)
        _PickerAction(
            icon: Icons.photo_library_outlined,
            label: 'Choose image',
            onTap: _pickFromGallery),
      if (widget.allowFiles)
        _PickerAction(
            icon: Icons.attach_file, label: 'Upload file', onTap: _pickAnyFile),
      if (file != null)
        _PickerAction(
            icon: Icons.delete_outline,
            label: 'Remove',
            onTap: () async {
              setState(() => file = null);
              Navigator.of(context).pop();
            }),
    ];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...actions.map((a) => ListTile(
                  leading: Icon(a.icon),
                  title: Text(a.label),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await a.onTap();
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(Dimensions.radius * .5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TitleHeading4Widget(
                text: widget.labelText.tr,
                fontWeight: FontWeight.w600,
                maxLines: 1,
              ),
            ),
            if (widget.optional.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TitleHeading4Widget(
                  text: widget.optional.tr,
                  opacity: .4,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                ),
              ),
          ],
        ),

        verticalSpace(Dimensions.marginBetweenInputTitleAndBox * 1),

        // --- Picker area (tap opens sheet with camera/upload options) ---
        InkWell(
          onTap: _showPickerSheet,
          child: ClipRRect(
            borderRadius: radius,
            child: Container(
              width: double.infinity,
              height: Dimensions.buttonHeight * 1.5,
              alignment: Alignment.center,
              decoration: DottedDecoration(
                shape: Shape.box,
                dash: const [3, 3],
                color: Theme.of(context).primaryColor.withOpacity(.2),
                borderRadius: radius,
              ),
              child: file == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.backup_outlined,
                            size: 30,
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(.25)),
                        verticalSpace(6),
                        TitleHeading3Widget(
                          text: Strings.upload, // e.g., "Upload / Take Photo"
                          color:
                              Theme.of(context).primaryColor.withOpacity(.25),
                        ),
                        verticalSpace(2),
                        TitleHeading4Widget(
                          text: 'Tap to choose (camera, gallery, file)'.tr,
                          opacity: .4,
                          fontWeight: FontWeight.w500,
                          fontSize: Dimensions.headingTextSize4 * .8,
                          maxLines: 1,
                        ),
                      ],
                    )
                  : isImage(file!)
                      ? Image.file(file!,
                          fit: BoxFit.cover, width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            getFileNameFromPath(file!),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
            ),
          ),
        ),

        verticalSpace(Dimensions.marginBetweenInputTitleAndBox * .7),

        if (widget.hint.isNotEmpty)
          TitleHeading4Widget(
            text: widget.hint.tr,
            opacity: .4,
            fontWeight: FontWeight.w500,
            fontSize: Dimensions.headingTextSize4 * .8,
            maxLines: 2,
          ),
      ],
    );
  }
}

class _PickerAction {
  final IconData icon;
  final String label;
  final Future<void> Function() onTap;
  _PickerAction({required this.icon, required this.label, required this.onTap});
}

// Helpers
bool isImage(File file) {
  final mimeType = lookupMimeType(file.path);
  return mimeType != null && mimeType.startsWith('image/');
}

String getFileNameFromPath(File file) => p.basename(file.path);
