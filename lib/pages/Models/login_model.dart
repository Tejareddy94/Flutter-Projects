class LoginModel {
  int id;
  String access;
  String firstName;
  String lastName;
  String email;
  String avatarUrl;
  int role;
  bool isAdmin;
  String phoneNumber;
  bool canCreate;
  bool foreignUser;

  LoginModel(
      this.id,
      this.access,
      this.firstName,
      this.lastName,
      this.email,
      this.avatarUrl,
      this.role,
      this.isAdmin,
      this.phoneNumber,
      this.canCreate,
      this.foreignUser);

  String get userName => firstName + lastName;

  factory LoginModel.fromJson(dynamic json) {
    return LoginModel(
        json['id'] as int,
        json['access'] as String,
        json['first_name'] as String,
        json['last_name'] as String,
        json['email'] as String,
        json['avatar_url'] as String,
        json['role'] as int,
        json['is_admin'] as bool,
        json['phone_number'] as String,
        json['can_create'] as bool,
        json['foreign_user'] as bool);
  }
}
