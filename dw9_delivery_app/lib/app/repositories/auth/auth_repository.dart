import 'package:dw9_delivery_app/app/models/auth_model.dart';

abstract class AuthRepository {
  Future<void> register(String email, String password);

  Future<AuthModel> login(String email, String password);
}
