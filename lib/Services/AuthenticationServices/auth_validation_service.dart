/// Production-Ready Authentication Validation Service
/// Provides comprehensive validation for email, password, and user credentials

class PasswordStrengthResult {
  final bool isValid;
  final int score; // 0-5
  final String message;
  final List<String> requirements;

  PasswordStrengthResult({
    required this.isValid,
    required this.score,
    required this.message,
    required this.requirements,
  });
}

class AuthValidationService {
  // ═══════════════════════════════════════════════════════════════════
  //  EMAIL VALIDATION
  // ═════════════════════════════════════════════════════════════════════

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates email format
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedEmail = email.trim();

    if (trimmedEmail.length < 5) {
      return 'Email is too short';
    }

    if (trimmedEmail.length > 254) {
      return 'Email is too long';
    }

    if (!_emailRegex.hasMatch(trimmedEmail)) {
      return 'Please enter a valid email address (e.g., user@example.com)';
    }

    // Check for common typos in email domains
    final domain = trimmedEmail.split('@')[1].toLowerCase();
    final commonTypos = {
      'gmial.com': 'gmail.com',
      'gmal.com': 'gmail.com',
      'gmai.com': 'gmail.com',
      'gnail.com': 'gmail.com',
      'gamil.com': 'gmail.com',
      'hotmial.com': 'hotmail.com',
      'hotmal.com': 'hotmail.com',
      'yaho.com': 'yahoo.com',
      'yahooo.com': 'yahoo.com',
      'outlok.com': 'outlook.com',
    };

    if (commonTypos.containsKey(domain)) {
      return 'Did you mean ${commonTypos[domain]}?';
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  PASSWORD VALIDATION
  // ═════════════════════════════════════════════════════════════════════

  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _numberRegex = RegExp(r'[0-9]');
  static final RegExp _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>_+\-=\[\]\\\/]');

  /// Validates password strength and returns detailed result
  static PasswordStrengthResult validatePassword(String password) {
    final requirements = <String>[];
    int score = 0;

    // Check minimum length
    if (password.length < 8) {
      requirements.add('At least 8 characters');
    } else {
      score++;
    }

    // Check for uppercase
    if (!_uppercaseRegex.hasMatch(password)) {
      requirements.add('One uppercase letter (A-Z)');
    } else {
      score++;
    }

    // Check for lowercase
    if (!_lowercaseRegex.hasMatch(password)) {
      requirements.add('One lowercase letter (a-z)');
    } else {
      score++;
    }

    // Check for number
    if (!_numberRegex.hasMatch(password)) {
      requirements.add('One number (0-9)');
    } else {
      score++;
    }

    // Check for special character
    if (!_specialCharRegex.hasMatch(password)) {
      requirements.add('One special character (!@#\$%^&*)');
    } else {
      score++;
    }

    // Determine message based on score
    String message;
    bool isValid;

    switch (score) {
      case 0:
      case 1:
        message = 'Very weak password';
        isValid = false;
        break;
      case 2:
        message = 'Weak password - Add more requirements';
        isValid = false;
        break;
      case 3:
        message = 'Fair password - Can be stronger';
        isValid = false;
        break;
      case 4:
        message = 'Good password - Add one more requirement';
        isValid = false;
        break;
      case 5:
        message = 'Strong password!';
        isValid = true;
        break;
      default:
        message = 'Invalid password';
        isValid = false;
    }

    return PasswordStrengthResult(
      isValid: isValid,
      score: score,
      message: message,
      requirements: requirements,
    );
  }

  /// Simple password validation for form field
  static String? validatePasswordSimple(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  /// Validates confirm password match
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  NAME VALIDATION
  // ═════════════════════════════════════════════════════════════════════

  static final RegExp _nameRegex = RegExp(r"^[a-zA-Z\s'-]+$");

  /// Validates user name/username
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }

    final trimmedName = name.trim();

    if (trimmedName.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (trimmedName.length > 50) {
      return 'Name must be less than 50 characters';
    }

    if (!_nameRegex.hasMatch(trimmedName)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    // Check for suspicious patterns (e.g., all same character)
    final uniqueChars = trimmedName.toLowerCase().replaceAll(' ', '').split('').toSet().length;
    if (uniqueChars == 1) {
      return 'Please enter a valid name';
    }

    return null;
  }

  /// Validates username (more restrictive than name)
  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Username is required';
    }

    final trimmedUsername = username.trim();

    if (trimmedUsername.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (trimmedUsername.length > 30) {
      return 'Username must be less than 30 characters';
    }

    // Username must start with a letter
    if (!RegExp(r'^[a-zA-Z]').hasMatch(trimmedUsername)) {
      return 'Username must start with a letter';
    }

    // Username can only contain letters, numbers, and underscores
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmedUsername)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SANITIZATION
  // ═════════════════════════════════════════════════════════════════════

  /// Sanitizes email for storage/query
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Sanitizes name for storage
  static String sanitizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SECURITY CHECKS
  // ═════════════════════════════════════════════════════════════════════

  /// List of common weak passwords to check against
  static final Set<String> _commonPasswords = {
    'password', '123456', '12345678', 'qwerty', 'abc123',
    'monkey', 'letmein', 'dragon', '111111', 'baseball',
    'iloveyou', 'trustno1', 'sunshine', 'princess', 'admin',
    'welcome', 'shadow', 'ashley', 'football', 'jesus',
    'michael', 'ninja', 'mustang', 'password1', '123456789',
    'adobe123', 'admin123', 'login', 'master', 'photoshop',
    '1q2w3e4r', 'zaq12wsx', 'password123', 'qwerty123',
    'lovely', 'whatever', 'starwars', 'harley', 'ranger',
    'thomas', 'robert', 'michael', 'jordan', 'maggie',
    'buster', 'daniel', 'andrew', 'joshua', 'pepper',
  };

  /// Checks if password is commonly used (weak)
  static bool isCommonPassword(String password) {
    return _commonPasswords.contains(password.toLowerCase());
  }

  /// Gets a warning message if password is too common
  static String? getCommonPasswordWarning(String password) {
    if (isCommonPassword(password)) {
      return 'This password is too common and easily guessed. Please choose a more unique password.';
    }

    // Check for sequential patterns
    final lowerPassword = password.toLowerCase();
    if (RegExp(r'123|234|345|456|567|678|789|890|abc|bcd|cde|def|efg|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz').hasMatch(lowerPassword)) {
      return 'Avoid using sequential characters (e.g., 123, abc)';
    }

    // Check for repeated characters
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      return 'Avoid using repeated characters (e.g., aaa, 111)';
    }

    return null;
  }
}
