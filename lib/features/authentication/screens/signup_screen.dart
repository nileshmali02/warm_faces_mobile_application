import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart'; // Import this package
import 'package:warm_faces/features/authentication/screens/signup_email_verify.dart';
import 'package:warm_faces/features/comman/privacy_policy.dart';
import 'package:warm_faces/features/comman/terms_of_use.dart';
import 'package:warm_faces/utils/constant/colors.dart';
import 'package:warm_faces/utils/validation/field_validation.dart';
import 'package:warm_faces/utils/widgets/c_button.dart';
import 'package:warm_faces/utils/widgets/c_richtext.dart';
import 'package:warm_faces/utils/widgets/c_text_field.dart';
import '../models/signup_model.dart';
import '../repositories/signup_repository.dart';
import 'signin_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _dob; // Store DOB

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _dobError; // Store DOB error message

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isChecked = false;
  bool _isLoading = false; // Loader state variable

  final SignUpRepository _signUpRepository = SignUpRepository();

  // DateTime date = DateTime(2016, 10, 26);
  // DateTime time = DateTime(2016, 5, 10, 22, 35);
  // DateTime dateTime = DateTime(2016, 8, 3, 17, 45);
  DateTime date =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
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
                // const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Name input field
                CTextField(
                  controller: _nameController,
                  label: 'Name',
                  placeholder: 'Enter your name',
                  obscureText: false,
                  errorText: _nameError,
                  prefixIcon: const Icon(
                    Iconsax.user_edit_copy,
                    color: textFieldTextColor,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _nameError = ValidationUtils.validateName(value);
                    });
                  },
                ),

// DOB input field
                CTextField(
                  controller: _dobController,
                  label: 'Date of Birth',
                  placeholder: '${date.day}/${date.month}/${date.year}',
                  obscureText: false,
                  errorText: _dobError,
                  prefixIcon: const Icon(
                    Iconsax.calendar_1_copy,
                    color: textFieldTextColor,
                  ),
                  onChanged: (value) {},
                  onTap: () => _showDialog(
                    CupertinoDatePicker(
                      initialDateTime: date,
                      mode: CupertinoDatePickerMode.date,
                      use24hFormat: true,
                      showDayOfWeek: true,
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() {
                          date = newDate;
                          // Format the DateTime object to a string before assigning it
                          _dobController.text =
                              DateFormat('dd/MM/yyyy').format(date);

                          // Validate the age when the date is changed
                          _dobError = ValidationUtils.validateAge(newDate);
                        });
                      },
                    ),
                  ),
                  readOnly: true,
                ),
                // Email input field
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

                // Password input field
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
                  label: 'Confirm Password',
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

                const SizedBox(height: 20),

                // Checkbox for terms and conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(
                                text:
                                    "By creating an account you agree to our "),
                            TextSpan(
                              text: 'terms of use',
                              style: const TextStyle(
                                color: blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigator.push(
                                  //     context,
                                  //     CupertinoPageRoute(
                                  //       builder: (context) =>
                                  //           const TermsOfUse(),
                                  //     ));
                                  launchUrl(Uri.parse(
                                      "https://app.termly.io/policy-viewer/policy.html?policyUUID=7c878533-07db-4554-9a22-adfaffe938c0"));
                                },
                            ),
                            const TextSpan(text: ' and our '),
                            TextSpan(
                              text: 'privacy policy',
                              style: const TextStyle(
                                color: blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigator.push(
                                  //     context,
                                  //     CupertinoPageRoute(
                                  //       builder: (context) =>
                                  //           const PrivacyPolicy(),
                                  //     ));
                                  launchUrl(Uri.parse(
                                      "https://app.termly.io/policy-viewer/policy.html?policyUUID=f4cb1e75-7205-479d-af35-ac700d325612"));
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Sign Up button
                CButton(
                  text: 'Sign Up',
                  isEnabled: _isChecked,
                  enabledColor: primaryColor,
                  disabledColor: textFieldColor,
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _nameError = ValidationUtils.validateName(
                                _nameController.text);
                            _emailError = ValidationUtils.validateEmail(
                                _emailController.text);
                            _passwordError = ValidationUtils.validatePassword(
                                _passwordController.text);
                            _confirmPasswordError =
                                ValidationUtils.validateConfirmPassword(
                                    _confirmPasswordController.text,
                                    _passwordController.text);

                            _dobError = ValidationUtils.validateAge(date);
                          });

                          if (_nameError == null &&
                              _emailError == null &&
                              _passwordError == null &&
                              _confirmPasswordError == null &&
                              _dobError == null) {
                            await _onSignUp();
                          }
                        },
                ),

                const SizedBox(height: 16),
                Center(
                  child: CRichtext(
                    normalText: "Already have an account?",
                    actionText: " Sign In here",
                    onTapAction: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const SigninScreen(),
                        ),
                      );
                    },
                  ),
                ),

                // Show loader if loading
                if (_isLoading)
                  const Center(
                    child: CupertinoActivityIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// which hosts CupertinoDatePicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  // Function to handle sign-up
  Future<void> _onSignUp() async {
    setState(() {
      _isLoading = true; // Start loader
    });

    try {
      // Format the DOB in MM/dd/yyyy format
      String formattedDob = DateFormat('MM/dd/yyyy').format(date);

      final signUpModel = SignUpModel(
        name: _nameController.text,
        email: _emailController.text,
        dob: formattedDob,
        password: _passwordController.text,
      );

      bool success = await _signUpRepository.signUp(signUpModel);
      if (success) {
        // Handle success
        print("Sign Up Successful!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign Up Successful!")),
        );
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => SignupEmailVerify(
              email: _emailController.text,
            ),
          ),
        );
      }
    } catch (e) {
      // Display error message
      // String errorMessage = 'Sign Up Failed: ${e.toString()}';
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
