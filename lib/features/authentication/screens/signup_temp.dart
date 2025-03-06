// import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:warm_faces/features/authentication/screens/signin_screen.dart';
// import 'package:warm_faces/utils/constant/colors.dart';
// import 'package:warm_faces/utils/widgets/c_text_field.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   String? _nameError;
//   String? _emailError;
//   String? _passwordError;
//   String? _confirmPasswordError;

//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;

//   bool _isChecked = false; // State for checkbox

//   void _validateName(String value) {
//     // Capitalize first letter
//     if (value.isNotEmpty) {
//       value = value[0].toUpperCase() + value.substring(1);
//       _nameController.text = value; // Update the controller text
//       _nameController.selection = TextSelection.fromPosition(
//         TextPosition(offset: value.length),
//       );
//     }

//     // Check for empty value
//     if (value.isEmpty) {
//       setState(() {
//         _nameError = 'Please enter your name';
//       });
//     }
//     // Ensure the first character is a letter
//     else if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
//       setState(() {
//         _nameError = 'The first character must be a letter';
//       });
//     }
//     // Check for allowed characters (letters, spaces, and dots)
//     else if (RegExp(r'[^a-zA-Z\s\.]').hasMatch(value)) {
//       setState(() {
//         _nameError = 'Only letters, spaces, and dots are allowed';
//       });
//     }
//     // Disallow multiple consecutive spaces or dots
//     else if (RegExp(r'\s\s+').hasMatch(value) ||
//         RegExp(r'\.\.+').hasMatch(value)) {
//       setState(() {
//         _nameError = 'Only single spaces and dots are allowed';
//       });
//     }
//     // Check for leading or trailing spaces
//     else if (value.trim() != value) {
//       setState(() {
//         _nameError = 'Name cannot have leading or trailing spaces';
//       });
//     }
//     // Ensure the length is within valid bounds
//     else if (value.length < 3) {
//       setState(() {
//         _nameError = 'Name must be at least 3 characters';
//       });
//     } else if (value.length > 255) {
//       setState(() {
//         _nameError = 'Character length must be less than 255';
//       });
//     }
//     // If all checks pass, clear error
//     else {
//       setState(() {
//         _nameError = null; // Clear error if valid
//       });
//     }
//   }

//   void _validateEmail(String value) {
//     if (value.isEmpty) {
//       setState(() {
//         _emailError = 'Please enter your email';
//       });
//     } else if (value.contains(' ')) {
//       setState(() {
//         _emailError = 'Email cannot contain spaces';
//       });
//     } else {
//       final emailRegex = RegExp(
//         r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//       );
//       if (!emailRegex.hasMatch(value)) {
//         setState(() {
//           _emailError = 'Please enter a valid email';
//         });
//       } else if (value.length > 255) {
//         setState(() {
//           _emailError = 'Character length must be less than 255';
//         });
//       } else {
//         setState(() {
//           _emailError = null; // Clear error if valid
//         });
//       }
//     }
//   }

//   void _validatePassword(String value) {
//     if (value.isEmpty) {
//       setState(() {
//         _passwordError = 'Please enter your password';
//       });
//     } else if (value.length < 8) {
//       setState(() {
//         _passwordError = 'Password must be at least 8 characters';
//       });
//     } else if (value.length > 255) {
//       setState(() {
//         _passwordError = 'Character length must be less than 255';
//       });
//     } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
//       setState(() {
//         _passwordError = 'Password must contain at least one uppercase letter';
//       });
//     } else if (!RegExp(r'[a-z]').hasMatch(value)) {
//       setState(() {
//         _passwordError = 'Password must contain at least one lowercase letter';
//       });
//     } else if (!RegExp(r'[0-9]').hasMatch(value)) {
//       setState(() {
//         _passwordError = 'Password must contain at least one number';
//       });
//     } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
//       setState(() {
//         _passwordError = 'Password must contain at least one special character';
//       });
//     } else {
//       setState(() {
//         _passwordError = null; // Clear error if valid
//       });
//     }
//   }

//   void _validateConfirmPassword(String value) {
//     if (value.isEmpty) {
//       setState(() {
//         _confirmPasswordError = 'Please confirm your password';
//       });
//     } else if (value != _passwordController.text) {
//       setState(() {
//         _confirmPasswordError = 'Passwords do not match';
//       });
//     } else {
//       setState(() {
//         _confirmPasswordError = null; // Clear error if valid
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 30),
//                 const Center(
//                   child: Text(
//                     'Sign Up',
//                     style: TextStyle(
//                       color: Color(0xFF000000),
//                       fontSize: 24,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 0.1,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 50),
//                 CTextField(
//                   controller: _nameController,
//                   label: 'Name',
//                   obscureText: false,
//                   errorText: _nameError,
//                   prefixIcon: const Icon(
//                     Iconsax.user_edit_copy,
//                     color: textFieldTextColor,
//                   ),
//                   onChanged: _validateName,
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Name',
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: 18,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 CupertinoTextField(
//                   controller: _nameController,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   placeholder: 'Enter your name',
//                   placeholderStyle: TextStyle(
//                     color: textFieldTextColor.withOpacity(0.5),
//                   ),
//                   decoration: BoxDecoration(
//                     color: textFieldColor,
//                     borderRadius: BorderRadius.circular(8.0),
//                     border: Border.all(
//                       color: _nameError != null
//                           ? CupertinoColors.destructiveRed
//                           : CupertinoColors.lightBackgroundGray,
//                     ),
//                   ),
//                   prefix: const Padding(
//                     padding: EdgeInsets.only(left: 20),
//                     child: Icon(
//                       Iconsax.user_edit_copy,
//                       color: textFieldTextColor,
//                     ),
//                   ),
//                   onChanged: _validateName,
//                 ),
//                 if (_nameError != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       _nameError!,
//                       style: const TextStyle(
//                           color: CupertinoColors.destructiveRed),
//                     ),
//                   ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Email',
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: 18,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 CupertinoTextField(
//                   controller: _emailController,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   placeholder: 'Enter Email',
//                   placeholderStyle: TextStyle(
//                     color: textFieldTextColor.withOpacity(0.5),
//                   ),
//                   decoration: BoxDecoration(
//                     color: textFieldColor,
//                     borderRadius: BorderRadius.circular(8.0),
//                     border: Border.all(
//                       color: _emailError != null
//                           ? CupertinoColors.destructiveRed
//                           : CupertinoColors.lightBackgroundGray,
//                     ),
//                   ),
//                   prefix: const Padding(
//                     padding: EdgeInsets.only(left: 20),
//                     child: Icon(
//                       CupertinoIcons.mail,
//                       color: textFieldTextColor,
//                     ),
//                   ),
//                   onChanged: _validateEmail,
//                 ),
//                 if (_emailError != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       _emailError!,
//                       style: const TextStyle(
//                           color: CupertinoColors.destructiveRed),
//                     ),
//                   ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Password',
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: 18,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 CupertinoTextField(
//                   controller: _passwordController,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   placeholder: '********',
//                   placeholderStyle: TextStyle(
//                     color: textFieldTextColor.withOpacity(0.5),
//                   ),
//                   decoration: BoxDecoration(
//                     color: textFieldColor,
//                     borderRadius: BorderRadius.circular(8.0),
//                     border: Border.all(
//                       color: _passwordError != null
//                           ? CupertinoColors.destructiveRed
//                           : CupertinoColors.lightBackgroundGray,
//                     ),
//                   ),
//                   prefix: const Padding(
//                     padding: EdgeInsets.only(left: 20),
//                     child: Icon(
//                       Iconsax.lock_1_copy,
//                       color: textFieldTextColor,
//                     ),
//                   ),
//                   suffix: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _isPasswordVisible = !_isPasswordVisible;
//                       });
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 20),
//                       child: Icon(
//                         _isPasswordVisible
//                             ? Iconsax.eye_copy // Show password icon
//                             : Iconsax.eye_slash_copy, // Hide password icon
//                         color: textFieldTextColor,
//                       ),
//                     ),
//                   ),
//                   obscureText: !_isPasswordVisible,
//                   onChanged: _validatePassword,
//                 ),
//                 if (_passwordError != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       _passwordError!,
//                       style: const TextStyle(
//                           color: CupertinoColors.destructiveRed),
//                     ),
//                   ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Confirm Password',
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: 18,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 CupertinoTextField(
//                   controller: _confirmPasswordController,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   placeholder: '********',
//                   placeholderStyle: TextStyle(
//                     color: textFieldTextColor.withOpacity(0.5),
//                   ),
//                   decoration: BoxDecoration(
//                     color: textFieldColor,
//                     borderRadius: BorderRadius.circular(8.0),
//                     border: Border.all(
//                       color: _confirmPasswordError != null
//                           ? CupertinoColors.destructiveRed
//                           : CupertinoColors.lightBackgroundGray,
//                     ),
//                   ),
//                   prefix: const Padding(
//                     padding: EdgeInsets.only(left: 20),
//                     child: Icon(
//                       Iconsax.lock_1_copy,
//                       color: textFieldTextColor,
//                     ),
//                   ),
//                   suffix: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
//                       });
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 20),
//                       child: Icon(
//                         _isConfirmPasswordVisible
//                             ? Iconsax.eye_copy // Show confirm password icon
//                             : Iconsax
//                                 .eye_slash_copy, // Hide confirm password icon
//                         color: textFieldTextColor,
//                       ),
//                     ),
//                   ),
//                   obscureText: !_isConfirmPasswordVisible,
//                   onChanged: _validateConfirmPassword,
//                 ),
//                 if (_confirmPasswordError != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       _confirmPasswordError!,
//                       style: const TextStyle(
//                           color: CupertinoColors.destructiveRed),
//                     ),
//                   ),
//                 const SizedBox(height: 20),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Checkbox(
//                       value: _isChecked,
//                       onChanged: (value) {
//                         setState(() {
//                           _isChecked = value ?? false;
//                         });
//                       },
//                     ),
//                     Expanded(
//                       child: RichText(
//                         textAlign: TextAlign.start,
//                         text: TextSpan(
//                           style: const TextStyle(
//                             color: greyColor,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           children: [
//                             const TextSpan(
//                                 text:
//                                     "By creating an account you agree to our "),
//                             TextSpan(
//                               text: 'terms of use',
//                               style: const TextStyle(
//                                 color: blackColor,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               recognizer: TapGestureRecognizer()
//                                 ..onTap = () {
//                                   Navigator.push(
//                                       context,
//                                       CupertinoPageRoute(
//                                         builder: (context) =>
//                                             const SigninScreen(),
//                                       ));
//                                 },
//                             ),
//                             const TextSpan(text: ' and our '),
//                             TextSpan(
//                               text: 'privacy policy',
//                               style: const TextStyle(
//                                 color: blackColor,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               recognizer: TapGestureRecognizer()
//                                 ..onTap = () {
//                                   Navigator.push(
//                                       context,
//                                       CupertinoPageRoute(
//                                         builder: (context) =>
//                                             const SigninScreen(),
//                                       ));
//                                 },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 40),
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   decoration: BoxDecoration(
//                     color: primaryColor,
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: CupertinoButton(
//                     child: const Text(
//                       'Sign Up',
//                       style: TextStyle(
//                         color: blackColor,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                     onPressed: () {
//                       _validateName(_nameController.text);
//                       _validateEmail(_emailController.text);
//                       _validatePassword(_passwordController.text);
//                       _validateConfirmPassword(_confirmPasswordController.text);

//                       if (_nameError == null &&
//                           _emailError == null &&
//                           _passwordError == null &&
//                           _confirmPasswordError == null) {
//                         // Handle sign-up action here
//                         print('Name: ${_nameController.text}');
//                         print('Email: ${_emailController.text}');
//                         print('Password: ${_passwordController.text}');
//                         // Perform signup logic (e.g., API call)
//                       }
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Center(
//                   child: RichText(
//                     textAlign: TextAlign.center,
//                     text: TextSpan(
//                       style: const TextStyle(
//                         color: greyColor,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       children: [
//                         const TextSpan(text: "Already have an account?"),
//                         TextSpan(
//                           text: ' Sign In here',
//                           style: const TextStyle(
//                             color: blackColor,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           recognizer: TapGestureRecognizer()
//                             ..onTap = () {
//                               Navigator.push(
//                                   context,
//                                   CupertinoPageRoute(
//                                     builder: (context) => const SigninScreen(),
//                                   ));
//                             },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
