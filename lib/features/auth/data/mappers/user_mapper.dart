import '../../domain/entities/user.dart';
import '../models/user_model.dart';

extension UserMapper on UserModel {
  User toEntity() {
    return User(id: id, name: name, token: token);
  }
}
