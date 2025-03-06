// lib/features/authentication/models/signup_model.dart

/// This class is used to hold user sign-up information.
/// It contains the user's name, email, and password.
class SignInModel {
  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;

  /// Constructor to create a SignUpModel instance.
  /// You must provide a name, email, and password.
  SignInModel({
    required this.email,
    required this.password,
  });

  /// This method converts the SignUpModel to a JSON format.
  /// This is useful for sending data to the server.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
