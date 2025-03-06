import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:warm_faces/features/profile_page/models/edit_profile_model.dart';
import 'package:warm_faces/features/profile_page/repositories/edit_profile_repository.dart';
import 'package:warm_faces/utils/constant/colors.dart';
import 'package:warm_faces/utils/validation/field_validation.dart';
import 'package:warm_faces/utils/widgets/c_button.dart';
import 'package:warm_faces/utils/widgets/c_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _dob; // Store DOB
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String? _nameError;
  String? _emailError;
  String? _dobError; // Store DOB error message

  DateTime date = DateTime.now(); // Default current date

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Retrieve user data from secure storage
    _nameController.text = await storage.read(key: 'name') ?? '';
    _emailController.text = await storage.read(key: 'email') ?? '';

    // Retrieve and parse stored DOB, if available
    String? storedDob = await storage.read(key: 'dob');
    if (storedDob != null && storedDob.isNotEmpty) {
      try {
        // Attempt to parse the stored DOB string into a DateTime object
        date = DateFormat('dd/MM/yyyy').parse(storedDob);
        _dobController.text =
            storedDob; // Set the controller text to the stored value
      } catch (e) {
        print("Error parsing DOB: $e");
        // If parsing fails, you could reset it to the current date or show an error
        date = DateTime.now();
        _dobController.text = DateFormat('dd/MM/yyyy').format(date);
      }
    } else {
      // If no stored DOB, use the current date as the default
      _dobController.text = DateFormat('dd/MM/yyyy').format(date);
    }
  }

  final EditProfileRepository _editProfileRepository = EditProfileRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
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

              // Email input field (read-only)
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
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Iconsax.lock_1_copy,
                  ),
                ),
                readOnly: true, // Prevent editing the email
                onChanged: (value) {
                  setState(() {
                    _emailError = ValidationUtils.validateEmail(value);
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
                    initialDateTime:
                        date, // Set the initial date to the loaded date
                    mode: CupertinoDatePickerMode.date,
                    use24hFormat: true,
                    showDayOfWeek: true,
                    maximumDate: DateTime.now(),
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

              const SizedBox(height: 20),
              // Save button
              CButton(
                text: 'Save',
                isEnabled: true,
                enabledColor: primaryColor,
                disabledColor: textFieldColor,
                onPressed: () async {
                  setState(() {
                    _emailError =
                        ValidationUtils.validateEmail(_emailController.text);
                    _nameError =
                        ValidationUtils.validateName(_nameController.text);
                    _dobError = ValidationUtils.validateAge(date);
                  });

                  if (_emailError == null &&
                      _nameError == null &&
                      _dobError == null) {
                    await _onEditProfile();
                  }

                  // Here you can implement save functionality
                  // _onEditProfile();
                  // // Optionally, update the name and dob in secure storage
                  // await storage.write(key: 'name', value: _nameController.text);
                  // await storage.write(key: 'dob', value: _dobController.text);
                  // // setState(() {});
                  // // When the profile is updated, navigate back to ProfileScreen
                  // Navigator.pop(context, {
                  //   'name': _nameController.text,
                  //   'dob': _dobController.text,
                  // });
                  // // When the profile is updated, navigate back to ProfileScreen
                  // Navigator.pop(context, {
                  //   'name': _nameController.text,
                  //   'dob': _dobController.text,
                  // });

                  // Display a confirmation message
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Profile updated successfully')),
                  // );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to display the CupertinoDatePicker
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  Future<void> _onEditProfile() async {
    try {
      // Validate the full name to ensure it's not empty
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Full name cannot be empty.")),
        );
        return; // Stop further execution if the name is empty
      }

      // Format the DOB in MM/dd/yyyy format
      String formattedDob = DateFormat('MM/dd/yyyy').format(date);

      final editProfileModel = EditProfileModel(
        name: _nameController.text,
        dob: formattedDob,
        email: _emailController.text,
      );

      bool success =
          await _editProfileRepository.editProfile(context, editProfileModel);
      if (success) {
        // Optionally, update the name and dob in secure storage
        await storage.write(key: 'name', value: _nameController.text);
        await storage.write(key: 'dob', value: _dobController.text);
        // setState(() {});
        // When the profile is updated, navigate back to ProfileScreen
        Navigator.pop(context, {
          'name': _nameController.text,
          'dob': _dobController.text,
        });
        // When the profile is updated, navigate back to ProfileScreen
        Navigator.pop(context, {
          'name': _nameController.text,
          'dob': _dobController.text,
        });
        // Handle success
        print("Profile Updated Successfully!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully!")),
        );
      }
    } catch (e) {
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

  // Future<void> _onEditProfile() async {
  //   try {
  //     // Format the DOB in MM/dd/yyyy format
  //     String formattedDob = DateFormat('MM/dd/yyyy').format(date);
  //     final editProfileModel = EditProfileModel(
  //       name: _nameController.text,
  //       dob: formattedDob,
  //       email: _emailController.text,
  //     );

  //     bool success = await _editProfileRepository.editProfile(editProfileModel);
  //     if (success) {
  //       // Handle success
  //       print("Profile Update Successfully!");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Profile Updated Successful!")),
  //       );
  //     }
  //   } catch (e) {
  //     String errorMessage;
  //     if (e is Exception) {
  //       errorMessage = e
  //           .toString()
  //           .replaceFirst('Exception: ', ''); // Remove the "Exception: " prefix
  //     } else {
  //       errorMessage =
  //           'An unknown error occurred. Please try again.'; // Fallback for other errors
  //     }

  //     print(errorMessage);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(errorMessage)),
  //     );
  //   }
  // }
}
