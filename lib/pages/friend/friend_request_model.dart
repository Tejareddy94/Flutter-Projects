class FriendRequestModel {
  int id;
  User fromUser;
  User toUser;
  String message;
  String created;
  bool rejected;
  bool viewed;

  FriendRequestModel(this.id, this.fromUser, this.toUser, this.message,
      this.created, this.rejected, this.viewed);

  factory FriendRequestModel.fromJson(dynamic json) {
    return FriendRequestModel(
        json['id'] as int,
        json['from_user'] == null ? null : User.fromJson(json["from_user"]),
        json['to_user'] == null ? null : User.fromJson(json["to_user"]),
        json['message'] as String,
        json['created'] as String,
        json['rejected'] as bool,
        json['viewed'] as bool);
  }

  @override
  String toString() {
    return '{${this.id}, ${this.fromUser}, ${this.toUser}, ${this.message}, ${this.created}, ${this.rejected}, ${this.viewed}}';
  }
}

class User {
  int id;
  ProfileDetails profile;
  ConstituencyDetails constituencyDetails;
  String first_name;
  String last_name;
  String email;
  bool can_create;
  String phone_number;
  bool active;
  bool admin;
  int role;
  bool anonymous;
  int attempts;
  User(
      this.id,
      this.profile,
      this.constituencyDetails,
      this.first_name,
      this.last_name,
      this.email,
      this.can_create,
      this.phone_number,
      this.active,
      this.admin,
      this.role,
      this.anonymous,
      this.attempts);

  factory User.fromJson(dynamic json) {
    return User(
        json['id'] as int,
        json['profile'] == null
            ? null
            : ProfileDetails.fromJson(json["profile"]),
        json['constituency_details'] == null
            ? null
            : ConstituencyDetails.fromJson(json['constituency_details']),
        json['first_name'] as String,
        json['last_name'] as String,
        json['email'] as String,
        json['can_create'] as bool,
        json['phone_number'] as String,
        json['active'] as bool,
        json['admin'] as bool,
        json['role'] as int,
        json['anonymous'] as bool,
        json['attempts'] as int);
  }
  @override
  String toString() {
    return '${this.id}, ${this.profile},${this.constituencyDetails},${this.first_name},${this.last_name}, ${this.email},${this.admin},${this.role},${this.anonymous}, ${this.can_create},${this.phone_number},${this.active},${this.attempts}';
  }
}

class ProfileDetails {
  int id;
  String avatar;
  String location;
  String banner;
  String anonymous_avatar;
  int sex;
  String dob;
  int user;
  ProfileDetails(this.id, this.avatar, this.location, this.banner,
      this.anonymous_avatar, this.sex, this.dob, this.user);

  factory ProfileDetails.fromJson(dynamic json) {
    return ProfileDetails(
      json['id'] as int,
      json['avatar'] as String,
      json['location'] as String,
      json['banner'] as String,
      json['anonymous_avatar'] as String,
      json['sex'] as int,
      json['dob'] as String,
      json['user'] as int,
    );
  }
  @override
  String toString() {
    return '${this.id}, ${this.avatar},${this.location},${this.banner},${this.anonymous_avatar},${this.sex},${this.dob},${this.user}';
  }
}

class ConstituencyDetails {
  String country;
  String state;
  String district;
  String constituency;

  ConstituencyDetails(
      this.country, this.state, this.district, this.constituency);

  factory ConstituencyDetails.fromJson(dynamic json) {
    return ConstituencyDetails(
        json['country'] as String,
        json['state'] as String,
        json['district'] as String,
        json['constituency'] as String);
  }
  @override
  String toString() {
    return '${this.country}, ${this.state},${this.district},${this.constituency}';
  }
}

class DistrictDetails {
  String country;
  String state;
  String district;

  DistrictDetails(
    this.country,
    this.state,
    this.district,
  );

  factory DistrictDetails.fromJson(dynamic json) {
    return DistrictDetails(json['country'] as String, json['state'] as String,
        json['district'] as String);
  }
  @override
  String toString() {
    return '${this.country}, ${this.state},${this.district},';
  }
}
