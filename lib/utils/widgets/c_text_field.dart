import 'package:flutter/cupertino.dart';
import 'package:warm_faces/utils/constant/colors.dart';

// Custom text field widget that provides a styled input field
class CTextField extends StatelessWidget {
  final TextEditingController controller; // Controller for managing text input
  final String label; // Label text for the input field
  final String placeholder; // Placeholder text when the input is empty
  final String? errorText; // Error message displayed below the field, if any
  final bool obscureText; // Whether to obscure the text (for passwords)
  final ValueChanged<String> onChanged; // Callback for when the text changes
  final Widget? prefixIcon; // Optional icon to display before the input
  final Widget? suffixIcon; // Optional icon to display after the input
  final VoidCallback? onTap; // Optional callback when the text field is tapped
  final bool readOnly; // Whether the field is read-only (disabled for input)
  // Constructor for CTextField
  const CTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.placeholder,
    this.errorText,
    required this.obscureText,
    required this.onChanged,
    this.prefixIcon, // New prefixIcon parameter
    this.suffixIcon,
    this.onTap, // New suffixIcon parameter
    this.readOnly = false, // Default is false (editable)
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align children to the start
      children: [
        Text(
          label, // Display the label
          style: const TextStyle(fontSize: 18, color: blackColor),
        ),
        const SizedBox(height: 8), // Space between label and text field
        CupertinoTextField(
          controller: controller, // Bind the controller to the text field
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          placeholder: placeholder, // Set the placeholder text
          placeholderStyle: TextStyle(
            color: textFieldTextColor.withOpacity(0.5), // Style for placeholder
          ),
          decoration: BoxDecoration(
            color: textFieldColor, // Background color of the text field
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
            border: Border.all(
              color:
                  errorText != null // Change border color if there's an error
                      ? CupertinoColors.destructiveRed
                      : CupertinoColors.lightBackgroundGray,
            ),
          ),
          obscureText: obscureText, // Set text visibility for passwords
          prefix: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(
                      left: 18), // Add padding for prefix icon
                  child: prefixIcon,
                )
              : null, // Show prefix icon if provided
          suffix: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(
                      right: 0), // Add padding for suffix icon
                  child: suffixIcon,
                )
              : null, // Show suffix icon if provided
          onChanged: onChanged, // Handle text changes
          onTap: onTap, // Trigger onTap if provided
          readOnly: readOnly, // Make the text field read-only if specified
        ),
        if (errorText != null) // Display error message if present
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorText!, // Display the error text
              style: const TextStyle(color: CupertinoColors.destructiveRed),
            ),
          ),
        const SizedBox(height: 20), // Space after the text field
      ],
    );
  }
}
