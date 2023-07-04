/// RIoT
/// Custom
/// Classes
/// (rcc)

class User {
  /// id
  String id;
  final String userName;
  final String email;

  User({
    this.id = '',
    required this.userName,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'email': email,
      };
}

class LocalException {
  String exception;

  LocalException({required this.exception}) {
    exception = _parseString(exception);
  }

  String _parseString(String exception) {
    return exception.substring(0);
  }
}
