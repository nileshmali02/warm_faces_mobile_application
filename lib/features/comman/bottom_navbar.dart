import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warm_faces/features/comman/welcome_screen.dart';
import 'package:warm_faces/features/give/repositories/give_screen_repository.dart';
import 'package:warm_faces/features/give/screens/give_screen.dart';

import 'package:warm_faces/features/homepage/screens/home_screen.dart';
import 'package:warm_faces/features/profile_page/screens/profile_screen.dart';
import 'package:warm_faces/utils/constant/colors.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  final GiveScreenRepository _repository = GiveScreenRepository();

  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const WelcomeScreen(),
    const HomeScreen(),
    const GiveScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      if (index == 2) {
        // If the "Give" tab is tapped, navigate to GiveScreen
        _repository.verifyUploadVideo(context);
        // if (_repository.verifyUpload == 200) {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => const GiveScreen(),
        //     ),
        //   );
        // } else {
        //   showCupertinoDialog(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return CupertinoAlertDialog(
        //         title: const Text('Daily Limit Alert!'),
        //         content: const Text(
        //             'You can upload only 1 clip per day. Please try again tomorrow.'),
        //         actions: <Widget>[
        //           CupertinoDialogAction(
        //             child: const Text('Ok'),
        //             onPressed: () {
        //               Navigator.of(context).pop(); // Close the dialog
        //             },
        //           ),
        //         ],
        //       );
        //     },
        //   );
        // }

        // Container();
      } else {
        _selectedIndex = index;
      }
    });
  }
  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  // This is for the initial screen (before the bottom navbar appears)
  // Widget get initialScreen => const WelcomeScreen();

  // for don't navigate to login screen from this screen
  Future<bool> onWillPop() async {
    if (_selectedIndex == 0) {
      return false;
    } else {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: _screens[_selectedIndex], // Display the selected screen
        // body: _selectedIndex == 0
        //     ? initialScreen // Show the Welcome Screen initially
        //     : _screens[
        //         _selectedIndex], // Show other screens when tabs are clicked
        bottomNavigationBar: _selectedIndex == 1
            ? null
            : BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.only(bottom: 2),
                      width: 32,
                      height: 32,
                      child: _selectedIndex == 0
                          ? Image.asset(
                              'assets/icons/Home_icon.png',
                              color: primaryColor,
                            )
                          : Image.asset(
                              'assets/icons/Home_icon.png',
                              color: darkGreyColor,
                            ),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.only(bottom: 2),
                      width: 32,
                      height: 32,
                      child: _selectedIndex == 1
                          ? Image.asset(
                              'assets/icons/Icon_Receive.png',
                              color: primaryColor,
                            )
                          : Image.asset(
                              'assets/icons/Icon_Receive.png',
                            ),
                    ),
                    label: 'Receive',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.only(bottom: 2),
                      width: 32,
                      height: 32,
                      child: _selectedIndex == 2
                          ? Image.asset(
                              'assets/icons/icon_Give.png',
                              color: primaryColor,
                            )
                          : Image.asset(
                              'assets/icons/icon_Give.png',
                            ),
                    ),
                    label: 'Give',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.only(bottom: 2),
                      width: 32,
                      height: 32,
                      child: _selectedIndex == 3
                          ? Image.asset(
                              'assets/icons/Icon_Profile.png',
                              color: primaryColor,
                            )
                          : Image.asset(
                              'assets/icons/Icon_Profile.png',
                            ),
                    ),
                    label: 'Profile',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: blackColor,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                unselectedItemColor: textFieldTextColor,
                selectedFontSize: 14,
                unselectedFontSize: 14,
                backgroundColor: whiteColor,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
              ),
      ),
    );
  }
}
