import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:warm_faces/utils/constant/colors.dart';
import 'package:warm_faces/utils/constant/sized.dart';
import 'package:warm_faces/utils/widgets/c_sizebox.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Warm Faces'),
      //   centerTitle: false,
      // ),
      body: Stack(
        children: [
          // Background image
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Image.asset(
              'assets/images/Home Screen Background.png', // Your background image
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              filterQuality: FilterQuality.medium,
            ),
          ),
          // Apply blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0), // 20px blur
              child: Container(
                color: Colors.white
                    .withOpacity(0.1), // Optional: add color overlay
              ),
            ),
          ),
          Positioned(
              top: 90,
              left: 100,
              right: 100,
              child: Image.asset(
                'assets/icons/Header_Logo.png',
              )),
          // Foreground content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 160, bottom: 30, right: 10, left: 10),
                child: Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  color: whiteColor,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.asset(
                                'assets/icons/Icon_Receive copy.png',
                                height: 70,
                                width: 70,
                                //color: primaryColor,
                              ),
                              //addVerticalSpace(10),
                              const Text(
                                'Receive',
                                style: TextStyle(
                                  color: blackColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: fontSizeExtraLarge,
                                ),
                              ),
                              //addVerticalSpace(10),
                              const Text(
                                'Receive a new warm \nface every 24 hours.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontSizeNormal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        addVerticalSpace(10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.asset(
                                'assets/icons/icon_Give copy.png',
                                height: 70,
                                width: 70,
                                //color: primaryColor,
                              ),
                              //addVerticalSpace(10),
                              const Text(
                                'Give',
                                style: TextStyle(
                                  color: blackColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: fontSizeExtraLarge,
                                ),
                              ),
                              //addVerticalSpace(10),
                              const Text(
                                'Give a warm face every \n24 hours.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontSizeNormal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        //addVerticalSpace(10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
