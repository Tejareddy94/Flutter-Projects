class FriendsModel {
  int id;
  String first_name;
  String last_name;
  bool anonymous;
  ConstituencyDetails constituency_details;
  String user_avatar;

  FriendsModel(this.id, this.first_name, this.last_name, this.anonymous,
      this.constituency_details, this.user_avatar);

  factory FriendsModel.fromJson(dynamic json) {
    return FriendsModel(
        json['id'] as int,
        json['first_name'],
        json['last_name'],
        json['anonymous'],
        json['constituency_details'] == null
            ? null
            : ConstituencyDetails.fromJson(json['constituency_details']),
        json['user_avatar']);
  }

  @override
  String toString() {
    return '{${this.id}, ${this.first_name}, ${this.last_name}, ${this.anonymous}, ${this.constituency_details},${this.user_avatar}}';
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
