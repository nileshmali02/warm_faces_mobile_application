import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warm_faces/features/authentication/screens/signin_screen.dart';
import 'package:warm_faces/utils/constant/colors.dart';

class InstructionScreen extends StatefulWidget {
  const InstructionScreen({super.key});

  @override
  State<InstructionScreen> createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> {
  final PageController _controller =
      PageController(); // Controller for page view
  int _currentPage = 0; // Tracks the current page index
  bool _isChecked = false; // State for checkbox

  // Onboarding data including title, body text, and image path
  List<Map<String, String>> onboardingData = [
    {
      "title": "Welcome to Warm Faces",
      "body":
          "Experience the power of kindness. This app connects you with others through short, heartfelt exchanges that share warmth, presence, and kindness.",
      "image": "assets/images/onboard_3.png"
    },
    {
      "title": "Receive Warmth",
      "body":
          "You’ll receive a short video of someone offering you a warm face – a gesture of “metta,” or loving-kindness. Take a moment to appreciate their kindness, and notice how it feels.",
      "image": "assets/images/Layer 1.png"
    },
    {
      "title": "Give Warmth",
      "body":
          "Share your own warm face back! Record your video to return kindness to the next person in line. Imagine sending kindness forward, letting your warmth and compassion shine through.",
      "image": "assets/images/onboard_2.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCheckboxState(); // Load checkbox state when initializing
  }

  // Load the checkbox state from SharedPreferences
  Future<void> _loadCheckboxState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isChecked = prefs.getBool('dontShowAgain') ?? false; // Default to false
    });
  }

  // Update current page index when the page changes
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  // Navigate to SigninScreen when skipping onboarding
  void _onSkip() {
    _saveCheckboxState(); // Save checkbox state before navigating
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (context) => const SigninScreen()),
    );
  }

  // Save the checkbox state to SharedPreferences
  Future<void> _saveCheckboxState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dontShowAgain', _isChecked);
  }

  // Handle navigation to the next page or finish onboarding
  void _onNext() {
    if (_currentPage < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // If on the last page, navigate to SigninScreen
      _onSkip();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecked) {
      // Navigate directly to SigninScreen if checkbox is checked
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const SigninScreen()),
        );
      });
      return Container(); // Return an empty container to prevent rendering
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/Instructions screen background.png'), // Your background image
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: _onPageChanged,
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              onboardingData[index]["image"]!,
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.height * 0.35,
                            ),
                            const SizedBox(height: 28),
                            Text(
                              onboardingData[index]["title"]!,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              onboardingData[index]["body"]!,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  List.generate(onboardingData.length, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  width: _currentPage == index ? 28.0 : 8.0,
                                  height: 8.0,
                                  decoration: BoxDecoration(
                                    color: _currentPage == index
                                        ? textFieldTextColor.withOpacity(0.7)
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (value) {
                            setState(() {
                              _isChecked = value ?? false;
                            });
                            _onSkip(); // Navigate to SigninScreen
                          },
                        ),
                        const Text("Don't show this again"),
                      ],
                    ),
                    TextButton(
                      onPressed: _onNext, // Next button
                      child: Text(_currentPage == onboardingData.length - 1
                          ? "Get Started" // Change text on last page
                          : "Next"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
