/// It contains the user's name, email, password, and date of birth.
class EditProfileModel {
  /// The user's name.
  final String name;

  /// The user's date of birth (in "MM/dd/yyyy" format).
  final String dob;

  /// The user's email address.
  final String email;

  /// Constructor to create a EditProfileModel instance.
  /// You must provide a name, email, and date of birth.
  EditProfileModel({
    required this.name,
    required this.dob, // Add dob parameter
    required this.email,
  });

  /// This method converts the EditProfileModel to a JSON format.
  /// This is useful for sending data to the server.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dob': dob,
      'email': email,
    };
  }
}
