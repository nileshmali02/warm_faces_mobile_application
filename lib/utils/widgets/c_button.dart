import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Custom Button widget
class CButton extends StatelessWidget {
  final String text; // Text to display on the button
  final VoidCallback? onPressed; // Callback function when button is pressed
  final bool isEnabled; // Indicates if the button is enabled or disabled
  final Color enabledColor; // Color of the button when enabled
  final Color disabledColor; // Color of the button when disabled

  // Constructor for CButton
  const CButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.isEnabled,
    required this.enabledColor,
    required this.disabledColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // Full width of the screen
      decoration: BoxDecoration(
        color: isEnabled
            ? enabledColor
            : disabledColor, // Set color based on enabled state
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
      child: CupertinoButton(
        onPressed:
            isEnabled ? onPressed : null, // Enable or disable button action
        child: Text(
          text, // Display the button text
          style: const TextStyle(
            color: Colors.black, // Text color
            fontWeight: FontWeight.w600, // Bold text
            fontSize: 18, // Text size
          ),
        ),
      ),
    );
  }
}
