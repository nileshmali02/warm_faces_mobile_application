
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warm_faces/features/authentication/models/signin_model.dart';
import 'package:warm_faces/features/authentication/repositories/signin_repository.dart';
import 'package:warm_faces/features/authentication/screens/forgot_password.dart';
import 'package:warm_faces/features/authentication/screens/signup_screen.dart';
import 'package:warm_faces/features/comman/bottom_navbar.dart';
import 'package:warm_faces/utils/constant/colors.dart';
import 'package:warm_faces/utils/validation/field_validation.dart';
import 'package:warm_faces/utils/widgets/c_button.dart';
import 'package:warm_faces/utils/widgets/c_richtext.dart';
import 'package:warm_faces/utils/widgets/c_text_field.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Validation messages
  String? _emailError;
  String? _passwordError;

  // Track password visibility
  bool _isPasswordVisible = false;

  bool _isLoading = false; // Loader state variable

  final SignInRepository _signInRepository = SignInRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
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
                CTextField(
                  controller: _passwordController,
                  label: 'Password',
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
                            ? Iconsax.eye_copy // Show password icon
                            : Iconsax.eye_slash_copy, // Hide password icon
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ));
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 16,
                        color: blackColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CButton(
                  text: 'Sign In',
                  isEnabled:
                      true, // Button is only enabled if _isChecked is true
                  enabledColor: primaryColor,
                  disabledColor: textFieldColor, // Disabled state color
                  onPressed: () async {
                    // ValidationUtils.validateEmail(_emailController.text);
                    // ValidationUtils.validatePassword(_passwordController.text);
                    // if (_emailError == null && _passwordError == null) {
                    //   // Handle sign-in action here
                    //   print('Email: ${_emailController.text}');
                    //   print('Password: ${_passwordController.text}');
                    //   _onSignIn();
                    // }

                    setState(() {
                      _emailError =
                          ValidationUtils.validateEmail(_emailController.text);
                      _passwordError = ValidationUtils.validatePassword(
                          _passwordController.text);
                    });

                    if (_emailError == null && _passwordError == null) {
                      await _onSignIn();
                    }
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: CRichtext(
                    normalText: "Don't have an account?",
                    actionText: " Sign Up here",
                    onTapAction: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> _onSignIn() async {
  //   setState(() {
  //     _isLoading = true; // Start loader
  //   });
  //   try {
  //     // Get shared preferences
  //     final prefs = await SharedPreferences.getInstance();
  //     // Retrieve stored email and password
  //     String? storedEmail = prefs.getString('userEmail');
  //     String? storedPassword = prefs.getString('userPassword');
  //     print('storedEmail : $storedEmail');
  //     print('storedPassword : $storedPassword');
  //     // Check if the entered email and password match the stored values
  //     // if (_emailController.text == storedEmail &&
  //     //     _passwordController.text == storedPassword) {
  //     if (_emailController.text == "nilesh@gmail.com" &&
  //         _passwordController.text == "Nilesh@123") {
  //       // Handle success (e.g., navigate to another screen)
  //       await prefs.setBool('isLoggedIn', true);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Sign In Successful!")),
  //       );
  //       Navigator.pushReplacement(
  //         context,
  //         CupertinoPageRoute(
  //           builder: (context) => const BottomNavbar(),
  //         ),
  //       );
  //     } else {
  //       // Show error if the credentials do not match
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //             content: Text("Invalid email or password. Please try again.")),
  //       );
  //     }
  //   } catch (e) {
  //     // Display error message in Snackbar
  //     String errorMessage = 'Sign In Failed: ${e.toString()}';
  //     print(errorMessage);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(errorMessage)),
  //     );
  //   } finally {
  //     setState(() {
  //       _isLoading = false; // Stop loader
  //     });
  //   }
  // }

  // Function to handle sign-up
  Future<void> _onSignIn() async {
    setState(() {
      _isLoading = true; // Start loader
    });
    try {
      final signInModel = SignInModel(
        email: _emailController.text,
        password: _passwordController.text,
      );
      bool success = await _signInRepository.signIn(signInModel);
      if (success) {
        // Handle success (e.g., navigate to another screen)
        // Store login status
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign In Successful!")),
        );
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const BottomNavbar(),
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
    } finally {
      setState(() {
        _isLoading = false; // Stop loader
      });
    }
  }
}
