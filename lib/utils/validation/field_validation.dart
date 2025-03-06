
class ValidationUtils {
  // Validate the user's name
  static String? validateName(String value) {
    // Capitalize the first letter if the name is not empty
    if (value.isNotEmpty) {
      value = value[0].toUpperCase() + value.substring(1);
    }

    // Check if the name is empty
    if (value.isEmpty) {
      return 'Please enter your name'; // Error message
    } else if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
      return 'The first character must be a letter'; // First character must be a letter
    } else if (RegExp(r'[^a-zA-Z\s\.]').hasMatch(value)) {
      return 'Only letters, spaces, and dots are allowed'; // Only allowed characters
    } else if (RegExp(r'\s\s+').hasMatch(value) ||
        RegExp(r'\.\.+').hasMatch(value)) {
      return 'Only single spaces and dots are allowed'; // No multiple spaces or dots
    } else if (value.trim() != value) {
      return 'Name cannot have leading or trailing spaces'; // No extra spaces
    } else if (value.length < 3) {
      return 'Name must be at least 3 characters'; // Minimum length
    } else if (value.length > 255) {
      return 'Character length must be less than 255'; // Maximum length
    }
    return null; // Name is valid
  }

  // Validate the user's email
  static String? validateEmail(String value) {
    // Check if the email is empty
    if (value.isEmpty) {
      return 'Please enter your email'; // Error message
    } else if (value.contains(' ')) {
      return 'Email cannot contain spaces'; // No spaces allowed
    } else {
      // Regex pattern to check email format
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email'; // Invalid email format
      } else if (value.length > 255) {
        return 'Character length must be less than 255'; // Maximum length
      }
    }
    return null; // Email is valid
  }

  // Validate the user's password
  static String? validatePassword(String value) {
    // Check if the password is empty
    if (value.isEmpty) {
      return 'Please enter your password'; // Error message
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters'; // Minimum length
    } else if (value.length > 255) {
      return 'Character length must be less than 255'; // Maximum length
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter'; // Must have uppercase
    } else if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter'; // Must have lowercase
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number'; // Must have a number
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character'; // Must have a special character
    }
    return null; // Password is valid
  }

  // Validate that the confirmed password matches the original password
  static String? validateConfirmPassword(String value, String password) {
    // Check if the confirm password is empty
    if (value.isEmpty) {
      return 'Please confirm your password'; // Error message
    } else if (value != password) {
      return 'Passwords do not match'; // Must match original password
    }
    return null; // Confirm password is valid
  }

  static String? validateAge(DateTime dob) {
    // Get the current date and time
    final currentDate = DateTime.now();

    // Calculate the initial age by subtracting the year of birth from the current year
    int age = currentDate.year - dob.year;

    // Check if the birthdate hasn't occurred yet this year (if the month/day is before the user's birthday)
    // If true, decrement the age because the birthday hasn't been reached yet this year
    if (currentDate.month < dob.month ||
        (currentDate.month == dob.month && currentDate.day < dob.day)) {
      age--; // Subtract one year from age if the birthday hasn't passed this year
    }

    // Check if the calculated age is less than 18
    // If so, return an error message indicating the user is not old enough
    if (age < 18) {
      return 'You must be at least 18 years old.';
    }

    // Check if the DOB is more than 100 years in the past
    final hundredYearsAgo =
        currentDate.subtract(const Duration(days: 365 * 100));
    if (dob.isBefore(hundredYearsAgo)) {
      return 'Date of birth cannot be more than 100 years ago.';
    }

    // If age is 18 or older, return null to indicate no error
    return null;
  }
}
