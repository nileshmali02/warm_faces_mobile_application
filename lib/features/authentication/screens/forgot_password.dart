import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:warm_faces/features/authentication/repositories/forgot_password_repository.dart';
import 'package:warm_faces/features/authentication/screens/forgot_email_verify.dart';
import 'package:warm_faces/utils/constant/colors.dart';
import 'package:warm_faces/utils/constant/sized.dart';
import 'package:warm_faces/utils/validation/field_validation.dart';
import 'package:warm_faces/utils/widgets/c_button.dart';
import 'package:warm_faces/utils/widgets/c_sizebox.dart';
import 'package:warm_faces/utils/widgets/c_text_field.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();

  // Validation messages
  String? _emailError;

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
                'Forgot Password?',
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
                'Enter your email and we’ll send the confirmation to reset your password.',
                style: TextStyle(
                  color: blackColor,
                  fontSize: fontSizeNormal,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            addVerticalSpace(30),
            CTextField(
              controller: _emailController,
              label: 'Email',
              placeholder: 'Enter your email',
              obscureText: false,
              errorText: _emailError,
              prefixIcon: const Icon(
                CupertinoIcons.mail,
                color: textFieldTextColor,
              ),
              onChanged: (value) {
                setState(() {
                  _emailError = ValidationUtils.validateEmail(value);
                });
              },
            ),
            const SizedBox(height: 10),
            CButton(
              text: 'Send Code',
              isEnabled: true, // Button is only enabled if _isChecked is true
              enabledColor: primaryColor,
              disabledColor: textFieldColor, // Disabled state color
              onPressed: () {
                setState(() {
                  _emailError =
                      ValidationUtils.validateEmail(_emailController.text);
                });

                if (_emailError == null) {
                  _onRequestPasswordReset();
                  // if (_emailController.text == 'nilesh@gmail.com') {
                  //   Navigator.push(
                  //     context,
                  //     CupertinoPageRoute(
                  //       builder: (context) => ForgotEmailVerify(
                  //         email: _emailController.text,
                  //       ),
                  //     ),
                  //   );
                  //   // Handle sign-in action here
                  //   print('Email: ${_emailController.text}');
                  // } else {
                  //   // Handle sign-in action here
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //         content: Text(
                  //             "This email does not exists. Please sign up to create an account.")),
                  //   );
                  // }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to handle sign-up
  Future<void> _onRequestPasswordReset() async {
    try {
      bool success = await _forgotPasswordRepository
          .requestPasswordReset(_emailController.text);
      if (success) {
        // Handle success (e.g., navigate to another screen)

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP send Successful!")),
        );
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ForgotEmailVerify(
              email: _emailController.text,
            ),
          ),
        );
      }
    } catch (e) {
      // Directly use the error message without prefix
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
  }
}
