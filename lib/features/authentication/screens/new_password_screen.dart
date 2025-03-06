import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warm_faces/features/authentication/repositories/forgot_password_repository.dart';
import 'package:warm_faces/features/authentication/screens/signin_screen.dart';
import 'package:warm_faces/utils/constant/colors.dart';
import 'package:warm_faces/utils/constant/sized.dart';
import 'package:warm_faces/utils/validation/field_validation.dart';
import 'package:warm_faces/utils/widgets/c_button.dart';
import 'package:warm_faces/utils/widgets/c_sizebox.dart';
import 'package:warm_faces/utils/widgets/c_text_field.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  const NewPasswordScreen({super.key, required this.email});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _passwordError;
  String? _confirmPasswordError;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final ForgotPasswordRepository _forgotPasswordRepository =
      ForgotPasswordRepository();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Set New Password',
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: fontSizeHeader,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            addVerticalSpace(8),
            const Center(
              child: Text(
                'This password should be different than the previous passwords',
                style: TextStyle(
                  color: blackColor,
                  fontSize: fontSizeNormal,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            addVerticalSpace(30),
            // Password input field
            CTextField(
              controller: _passwordController,
              label: 'New Password',
              placeholder: '********',
              obscureText: !_isPasswordVisible,
              errorText: _passwordError,
              prefixIcon: const Icon(
                Iconsax.lock_1_copy,
                color: textFieldTextColor,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(
                    _isPasswordVisible
                        ? Iconsax.eye_copy
                        : Iconsax.eye_slash_copy,
                    color: textFieldTextColor,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _passwordError = ValidationUtils.validatePassword(value);
                });
              },
            ),

            // Confirm Password input field
            CTextField(
              controller: _confirmPasswordController,
              label: 'New Confirm Password',
              placeholder: '********',
              obscureText: !_isConfirmPasswordVisible,
              errorText: _confirmPasswordError,
              prefixIcon: const Icon(
                Iconsax.lock_1_copy,
                color: textFieldTextColor,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(
                    _isConfirmPasswordVisible
                        ? Iconsax.eye_copy
                        : Iconsax.eye_slash_copy,
                    color: textFieldTextColor,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _confirmPasswordError =
                      ValidationUtils.validateConfirmPassword(
                          value, _passwordController.text);
                });
              },
            ),

            const SizedBox(height: 30),
            CButton(
              text: 'Reset Password',
              isEnabled: true, // Button is only enabled if _isChecked is true
              enabledColor: primaryColor,
              disabledColor: textFieldColor, // Disabled state color
              onPressed: () async {
                setState(() {
                  _passwordError = ValidationUtils.validatePassword(
                      _passwordController.text);
                  _confirmPasswordError =
                      ValidationUtils.validateConfirmPassword(
                          _confirmPasswordController.text,
                          _passwordController.text);
                });

                if (_passwordError == null && _confirmPasswordError == null) {
                  await _onResetPassword();
                  // Navigator.push(
                  //   context,
                  //   CupertinoPageRoute(
                  //     builder: (context) => const SigninScreen(),
                  //   ),
                  // );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _onResetPassword() async {
  //   try {
  //     // Simulate verification by checking the entered OTP against the static OTP
  //     if (_passwordController.text == 'Nilesh1@123') {
  //       // Show success Snackbar
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //             content: Text(
  //                 "The new password cannot be the same as the old password. Please choose a different password.")),
  //       );
  //     } else if (_passwordController.text == 'Nilesh@123') {
  //       // Show success Snackbar
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //             content: Text(
  //                 "Your password has been successfully updated. You can now use your new password to Sign in.")),
  //       );
  //       // Navigate to Home
  //       Navigator.pushReplacement(
  //         context,
  //         CupertinoPageRoute(builder: (context) => const SigninScreen()),
  //       );
  //     } else {
  //       // Handle invalid OTP case
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Please enter correct password")),
  //       );
  //     }
  //   } catch (e) {
  //     // Handle error (e.g., show a message)
  //     String errorMessage = 'Error: ${e.toString()}';
  //     print(errorMessage);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(errorMessage)),
  //     );
  //   }
  // }

  Future<void> _onResetPassword() async {
    // setState(() {
    //   _isLoading = true; // Start loader
    // });
    try {
      bool success = await _forgotPasswordRepository.resetPassword(
          widget.email, _passwordController.text);
      if (success) {
        // Show success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password Reset Successfully!")),
        );

        // Navigate to SignIn Screen
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const SigninScreen()),
        );
      }
    } catch (e) {
      // Handle error (e.g., show a message)
      String errorMessage;
      if (e is Exception) {
        errorMessage = e
            .toString()
            .replaceFirst('Exception: ', ''); // Remove the "Exception: " prefix
      } else {
        errorMessage =
            'An unknown error occurred. Please try again.'; // Fallback for other errors
      }

      print(errorMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
    // finally {
    //   setState(() {
    //     _isLoading = false; // Stop loader
    //   });
    // }
  }
}
