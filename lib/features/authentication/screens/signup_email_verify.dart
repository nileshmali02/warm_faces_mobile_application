import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:warm_faces/features/authentication/repositories/signup_repository.dart';
import 'package:warm_faces/features/authentication/screens/signin_screen.dart';

import 'package:warm_faces/utils/constant/colors.dart';
import 'package:warm_faces/utils/constant/sized.dart';
import 'package:warm_faces/utils/widgets/c_button.dart';
import 'package:warm_faces/utils/widgets/c_richtext.dart';
import 'package:warm_faces/utils/widgets/c_sizebox.dart';

class SignupEmailVerify extends StatefulWidget {
  final String email;
  const SignupEmailVerify({super.key, required this.email});

  @override
  State<SignupEmailVerify> createState() => _SignupEmailVerifyState();
}

class _SignupEmailVerifyState extends State<SignupEmailVerify> {
// Controllers for text fields
  final TextEditingController _pinController = TextEditingController();

  String? otpCode;
  Timer? _timer;
  int _start = 60; // Time Duration in second
  bool _isTimerRunning = true;

  bool _isVerifyOTPBtn = false;
  final String _btnText = 'Verify';

  final SignUpRepository _signUpRepository = SignUpRepository();

  @override
  void initState() {
    // TODO: implement initState
    _startTimer();
    super.initState();
  }

  void _startTimer() {
    // print('_startTimer');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // print('_start : $_start');
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _isTimerRunning = false;
        });
      } else {
        setState(() {
          _start--;
          _isTimerRunning = true;
        });
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel(); // Cancel the current timer if it's running
    setState(() {
      // print('_start = 60 second');
      _start = 60; // Reset to initial countdown value
      _pinController.clear(); // Clear the PIN controller
      _startTimer(); // Start the timer again
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

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
                'Please Check your Email',
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: fontSizeHeader,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            addVerticalSpace(8),
            Center(
              child: CRichtext(
                normalText: "We have sent the code to ",
                actionText: widget.email,
                onTapAction: () {},
              ),
            ),
            addVerticalSpace(30),
            Pinput(
              length: 4,
              showCursor: true,
              controller: _pinController,
              autofocus: true,
              defaultPinTheme: PinTheme(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: textFieldTextColor.withOpacity(0.5),
                  ),
                  // color: textFieldColor,
                ),
                textStyle: const TextStyle(
                  fontSize: fontSizeLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: primaryColor,
                    width: 2,
                  ),
                  // color: textFieldColor,
                ),
                textStyle: const TextStyle(
                  fontSize: fontSizeLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onChanged: (value) {
                if (value.length == 4) {
                  setState(() {
                    _isVerifyOTPBtn = true;
                  });
                } else {
                  setState(() {
                    _isVerifyOTPBtn = false;
                  });
                }
              },
              onCompleted: (value) {
                setState(() {
                  otpCode = value;
                });
              },
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            addVerticalSpace(10),
            if (_isTimerRunning)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Resend OTP in $_start seconds',
                  style: const TextStyle(
                    fontSize: fontSizeNormal,
                  ),
                ),
              ),
            if (!_isTimerRunning)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Call The Resend OTP
                    // Call The Resend OTP
                    // print('Btn Click');
                    _resetTimer();
                    _onResendOTP();
                  },
                  child: const Text(
                    'Resend Code',
                  ),
                ),
              ),
            const SizedBox(height: 10),
            CButton(
              text: 'Verify',
              isEnabled: _isVerifyOTPBtn, // Pass the state
              enabledColor: primaryColor,
              disabledColor: textFieldColor,
              onPressed: _isVerifyOTPBtn
                  ? () {
                      _onSignUpEmailVerify();
                    }
                  : null, // Disabled state color
              // onPressed: _isVerifyOTPBtn
              //     ? null
              //     : () {
              //         try {

              //           // Show success Snackbar

              //           // if (otpCode == '91756') {
              //           //   Navigator.push(
              //           //     context,
              //           //     CupertinoPageRoute(
              //           //       builder: (context) => const HomeScreen(),
              //           //     ),
              //           //   );
              //           // } else {
              //           //   // Show success Snackbar
              //           //   ScaffoldMessenger.of(context).showSnackBar(
              //           //     const SnackBar(content: Text("Wrong OTP")),
              //           //   );
              //           // }
              //         } catch (e) {
              //           print('Error');
              //         }
              //       },
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _onSignUpEmailVerify() async {
  //   // Set a static OTP for mock purposes
  //   const int staticOtp = 9175; // This is the mock OTP

  //   try {
  //     // Convert the entered OTP code to an integer
  //     int otpCodeInt = int.parse(otpCode.toString());

  //     // Simulate verification by checking the entered OTP against the static OTP
  //     if (otpCodeInt == staticOtp) {
  //       // Simulate a successful verification
  //       // Store login status
  //       final SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setBool('isLoggedIn', true);

  //       // Show success Snackbar
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Email Verified Successfully!")),
  //       );

  //       // Navigate to Home
  //       Navigator.pushReplacement(
  //         context,
  //         CupertinoPageRoute(builder: (context) => const BottomNavbar()),
  //       );
  //     } else {
  //       // Handle invalid OTP case
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Invalid OTP. Please try again.")),
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

  Future<void> _onSignUpEmailVerify() async {
    // setState(() {
    //   _isLoading = true; // Start loader
    // });
    try {
      int otpCodeInt = int.parse(otpCode.toString());
      bool success =
          await _signUpRepository.signUpEmailVerify(widget.email, otpCodeInt);
      if (success) {
        // // Store login status
        // final SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setBool('isLoggedIn', true);

        // Show success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email Verified Successfully!")),
        );

        // Navigate to Home
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

  Future<void> _onResendOTP() async {
    // setState(() {
    //   _isLoading = true; // Start loader
    // });
    try {
      bool success = await _signUpRepository.resendOTP(widget.email);
      if (success) {
        // Show success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Resend Successfully!")),
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
