class Validator {
  static String? validateText(String? value, String? fieldName){
    if(value == null || value.isEmpty){
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value){
    if(value == null || value.isEmpty){
      return 'Email is required';
    }

    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');

    if(!emailRegExp.hasMatch(value)){
      return 'Enter a valid email';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }

    if(!value.contains(RegExp(r'[A-Z]'))){
      return 'Password must contains at least one uppercase latter.';
    }

    if(!value.contains(RegExp(r'[a-z]'))){
      return 'Password must contains at least one lowercase latter.';
    }
    
    if(!value.contains(RegExp(r'\d'))){
      return 'Password must contains at least one number.';
    }

    if(!value.contains(RegExp(r'[!@#\$&*~]'))){
      return 'Password must contains at least one special character';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password){
    if(value == null || value.isEmpty){
      return 'Confirm Password is required';
    }
    if(value != password){
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value){
    if(value == null || value.isEmpty){
      return 'Phone Number is required';
    }

    final phoneRegExp = RegExp(r'^\d{10}$');

    if(!phoneRegExp.hasMatch(value)){
      return 'Invalid phone number formate (10 digits are required)';
    }
    
    return null;
  }

}
