class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Введіть пошту';
    if (!value.contains('@')) return 'Пошта повинна містити @';
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Введіть повне імʼя';

    final digitRegex = RegExp(r'[0-9]');
    if (digitRegex.hasMatch(value)) {
      return 'Імʼя не може містити цифри';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Пароль має бути не менше 6 символів';
    }
    return null;
  }

  static String? confirmPassword(String? value, String originalPassword) {
    if (value != originalPassword) {
      return 'Паролі не збігаються';
    }
    return null;
  }
}
