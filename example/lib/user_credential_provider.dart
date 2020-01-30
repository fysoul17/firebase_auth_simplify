import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class UserCredentialProvider extends ChangeNotifier {
  static UserCredentialProvider of(BuildContext context,
          {bool listen = true}) =>
      Provider.of<UserCredentialProvider>(context, listen: listen);

  String _email;
  String get email => _email;
  set email(String email) {
    _email = email;
    notifyListeners();
  }

  String _password;
  String get password => _password;
  set password(String pw) {
    _password = pw;
    notifyListeners();
  }

  String _phoneNumber;
  String get phoneNumber => _phoneNumber;
  set phoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  String _code;
  String get code => _code;
  set code(String code) {
    _code = code;
    notifyListeners();
  }
}
