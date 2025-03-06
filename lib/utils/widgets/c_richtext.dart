import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:warm_faces/utils/constant/colors.dart';

// Custom Rich Text widget that displays normal and action text
class CRichtext extends StatelessWidget {
  final String normalText; // The regular text to display
  final String actionText; // The text that users can interact with
  final VoidCallback
      onTapAction; // The function to call when action text is tapped

  // Constructor for CRichtext
  const CRichtext({
    super.key,
    required this.normalText,
    required this.actionText,
    required this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center, // Center the text
      text: TextSpan(
        style: const TextStyle(
          color: greyColor, // Color of the normal text
          fontSize: 16, // Font size for normal text
          fontWeight: FontWeight.w500, // Weight for normal text
        ),
        children: [
          TextSpan(text: normalText), // Add normal text
          TextSpan(
            text: actionText, // Add action text
            style: const TextStyle(
              color: blackColor, // Color for action text
              fontSize: 16, // Font size for action text
              fontWeight: FontWeight.bold, // Bold weight for action text
            ),
            recognizer: TapGestureRecognizer() // Make action text tappable
              ..onTap = onTapAction, // Set the tap action
          ),
        ],
      ),
    );
  }
}
