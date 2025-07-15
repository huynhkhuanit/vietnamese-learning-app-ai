class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }

    // Trim whitespace
    final trimmedValue = value.trim();

    // Check basic format first
    if (!trimmedValue.contains('@') || !trimmedValue.contains('.')) {
      return 'Email không hợp lệ';
    }

    // Enhanced email regex that follows RFC 5322 more closely
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Email không hợp lệ';
    }

    // Additional validation
    if (trimmedValue.length > 254) {
      return 'Email quá dài';
    }

    // Check for consecutive dots
    if (trimmedValue.contains('..')) {
      return 'Email không hợp lệ';
    }

    // Check domain part length
    final parts = trimmedValue.split('@');
    if (parts.length != 2) {
      return 'Email không hợp lệ';
    }

    final localPart = parts[0];
    final domainPart = parts[1];

    if (localPart.isEmpty || localPart.length > 64) {
      return 'Email không hợp lệ';
    }

    if (domainPart.isEmpty || domainPart.length > 253) {
      return 'Email không hợp lệ';
    }

    // Check for valid domain ending
    if (!domainPart.contains('.') ||
        domainPart.endsWith('.') ||
        domainPart.startsWith('.')) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải chứa ít nhất một chữ hoa';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải chứa ít nhất một số';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    if (value.length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'Trường này là bắt buộc';
    }
    return null;
  }

  static String? minLength(String? value, int length) {
    if (value == null || value.isEmpty) {
      return 'Trường này là bắt buộc';
    }
    if (value.length < length) {
      return 'Phải có ít nhất $length ký tự';
    }
    return null;
  }

  static String? maxLength(String? value, int length) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > length) {
      return 'Không được vượt quá $length ký tự';
    }
    return null;
  }
}
