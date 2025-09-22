import 'dart:io';

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  });

  final String labelText, optional, hint;
  final ValueChanged<File> onTap; // <— be specific

  @override
  State<CustomUploadFileWidget> createState() => _CustomUploadFileWidgetState();
}

class _CustomUploadFileWidgetState extends State<CustomUploadFileWidget> {
  File? file;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header (no overflow, no unused space) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: TitleHeading4Widget(
                text: widget.labelText.tr,
                fontWeight: FontWeight.w600,
                // Make sure TitleHeading4Widget passes these to Text:
                maxLines: 1,
                // overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.optional.isNotEmpty) ...[
              const SizedBox(width: 8), // avoid fractional px spacing
              Flexible(
                child: TitleHeading4Widget(
                  text: widget.optional.tr,
                  opacity: .4,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  // overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),

        verticalSpace(Dimensions.marginBetweenInputTitleAndBox * 1),

        // --- Picker area ---
        InkWell(
          onTap: () async {
            final result = await FilePicker.platform.pickFiles();
            if (result != null && result.files.single.path != null) {
              final picked = File(result.files.single.path!);
              setState(() => file = picked);
              debugPrint("Picked ${picked.path}");
              widget.onTap(picked);
            }
          },
          child: ClipRRect( // clip children (e.g. image) to rounded dotted border
            borderRadius: BorderRadius.circular(Dimensions.radius * .5),
            child: Container(
              width: double.infinity,
              height: Dimensions.buttonHeight * 1.5,
              alignment: Alignment.center,
              decoration: DottedDecoration(
                shape: Shape.box,
                dash: const [3, 3],
                color: Theme.of(context).primaryColor.withOpacity(.2),
                borderRadius: BorderRadius.circular(Dimensions.radius * .5),
              ),
              child: file == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Animate(
                    effects: const [FadeEffect(), ScaleEffect()],
                    child: Icon(
                      Icons.backup_outlined,
                      size: 30,
                      color: CustomColor.primaryLightTextColor.withOpacity(.2),
                    ),
                  ),
                  verticalSpace(3),
                  TitleHeading3Widget(
                    text: Strings.upload,
                    color: CustomColor.primaryLightTextColor.withOpacity(.2),
                  ),
                ],
              )
                  : isImage(file!)
                  ? Image.file(
                file!,
                fit: BoxFit.cover,
                width: double.infinity,
                // height is constrained by parent Container
              )
                  : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  getFileNameFromPath(file!),
                  textAlign: TextAlign.center,
                  maxLines: 1, // <— prevent vertical overflow
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
        ),

        verticalSpace(Dimensions.marginBetweenInputTitleAndBox * .7),

        // --- Hint (collapses fully when empty) ---
        if (widget.hint.isNotEmpty)
          TitleHeading4Widget(
            text: widget.hint.tr,
            opacity: .4,
            fontWeight: FontWeight.w500,
            fontSize: Dimensions.headingTextSize4 * .8,
            maxLines: 2,
            // overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

// Helpers
bool isImage(File file) {
  final mimeType = lookupMimeType(file.path);
  return mimeType != null && mimeType.split('/').first == 'image';
}

String getFileNameFromPath(File file) => p.basename(file.path);
