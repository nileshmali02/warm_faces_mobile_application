/// This class is used to hold user sign-up information.
/// It contains the user's name, email, password, and date of birth.
class SignUpModel {
  /// The user's name.
  final String name;

  /// The user's email address.
  final String email;

  /// The user's date of birth (in "MM/dd/yyyy" format).
  final String dob;

  /// The user's password.
  final String password;

  /// Constructor to create a SignUpModel instance.
  /// You must provide a name, email, password, and date of birth.
  SignUpModel({
    required this.name,
    required this.email,
    required this.dob, // Add dob parameter
    required this.password,
  });

  /// This method converts the SignUpModel to a JSON format.
  /// This is useful for sending data to the server.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'dob': dob,
      'password': password,
    };
  }
}
