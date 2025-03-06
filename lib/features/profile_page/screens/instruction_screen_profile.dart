import 'package:flutter/material.dart';
import 'package:warm_faces/utils/constant/colors.dart';

class InstructionScreenProfile extends StatefulWidget {
  const InstructionScreenProfile({super.key});

  @override
  State<InstructionScreenProfile> createState() =>
      _InstructionScreenProfileState();
}

class _InstructionScreenProfileState extends State<InstructionScreenProfile> {
  final PageController _controller =
      PageController(); // Controller for page view
  int _currentPage = 0; // Tracks the current page index
  final bool _isChecked = false; // State for checkbox

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
  }

  // Update current page index when the page changes
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  // Navigate to SigninScreen when skipping onboarding
  void _onSkip() {
    Navigator.pop(context);
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
                    // Row(
                    //   children: [
                    //     Checkbox(
                    //       value: _isChecked,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           _isChecked = value ?? false;
                    //         });
                    //       },
                    //     ),
                    //     const Text("Skip"),
                    //   ],
                    // ),
                    TextButton(
                      onPressed: _onSkip, // Next button
                      child: const Text('Close'),
                    ),
                    TextButton(
                      onPressed: _onNext, // Next button
                      child: Text(_currentPage == onboardingData.length - 1
                          ? "" // Change text on last page
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
