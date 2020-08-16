class Comments {
  int id;
  String userName;
  bool myComment;
  String message;
  String upDatedAt;
  int postId;
  int userId;

  Comments(
    this.id,
    this.userName,
    this.myComment,
    this.message,
    this.upDatedAt,
    this.postId,
    this.userId,
  );
  factory Comments.fromJson(dynamic json){
    return Comments(json['id'] as int, json['user_name'] as String, json['my_comment'] as bool, json['message'] as String, json['updated_at'] as String, json['post_id'] as int, json['user_id'] as int);
  }

  @override
  String toString(){
    return '{${this.id},${this.userName},${this.myComment},${this.message},${this.upDatedAt}${this.postId},${this.userId},}';
  }
}