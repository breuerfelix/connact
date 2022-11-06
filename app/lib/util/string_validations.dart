// TODO: refine

extension Validations on String? {
  bool get isValidEmail {
    if (this == null) return false;

    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(this!);
  }

  bool get isValidName {
    if (this == null) return false;
    return this!.isNotEmpty;
  }

  bool get isValidPassword {
    if (this == null) return false;

    return this!.isNotEmpty;
    // final passwordRegExp = RegExp(
    //     r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\><*~]).{8,}/pre>');
    // return passwordRegExp.hasMatch(this!);
  }
}
