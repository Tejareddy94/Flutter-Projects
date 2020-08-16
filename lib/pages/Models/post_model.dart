class PostModel {
  int id;
  int likesCount;
  int commentsCount;
  bool isLiked;
  String userAvatar;
  String description;
  String gpsData;
  int category;
  String updateDate;
  List attachments;
  bool status;
  User user;
  int userId;
  bool myPost;
  bool myDistrictPost;
  bool myConstituencyPost;
  ConstituencyDetails constituencyDetails;
  DistrictDetails districtDetails;
  PostModel(
    this.id,
    this.likesCount,
    this.commentsCount,
    this.isLiked,
    this.userAvatar,
    this.description,
    this.gpsData,
    this.category,
    this.updateDate,
    this.attachments,
    this.status,
    this.user,
    this.userId,
    this.constituencyDetails,
    this.districtDetails,
    this.myConstituencyPost,
    this.myDistrictPost,
    this.myPost,
  );

  factory PostModel.fromJson(dynamic json) {
    return PostModel(
      json['id'] as int,
      json['likes_count'] as int,
      json['comments_count'] as int,
      json['user_liked_post'] as bool,
      json['user_avatar'] as String,
      json['description'] as String,
      json['gps_data'] as String,
      json['category'] as int,
      json['updated_at'] as String,
      json['attachments'] as List,
      json['clarified'] as bool,
      User.fromJson(json['user_details']),
      json['user_id'] as int,
      json['constituency_details'] == null
          ? null
          : ConstituencyDetails.fromJson(json['constituency_details']),
      json['district_details'] == null
          ? null
          : DistrictDetails.fromJson(json['district_details']),
      json['my_constituency_post'],
      json['my_district_post'],
      json['my_post'],
    );
  }

  @override
  String toString() {
    return '{${this.id}, ${this.likesCount}, ${this.commentsCount}, ${this.isLiked}, ${this.userAvatar},${this.description}, ${this.gpsData}, ${this.category},${this.updateDate}, ${this.attachments}, ${this.user}, ${this.constituencyDetails}}';
  }
}

class User {
  String firstname;
  bool isAnonymous;
  bool admin;
  int role;
  User(this.firstname, this.isAnonymous, this.admin, this.role);

  factory User.fromJson(dynamic json) {
    return User(
      json['first_name'] as String,
      json['anonymous'] as bool,
      json['admin'] as bool,
      json['role'] as int,
    );
  }
  @override
  String toString() {
    return '${this.firstname}, ${this.isAnonymous},${this.admin},${this.role}';
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
