class PostComment {
  String photoUrl;
  String name;
  String caption;
  String date;
  String postUid;
  String userUid;

  PostComment({this.photoUrl, this.name, this.caption, this.date, this.postUid, this.userUid});

  Map toMap(PostComment postComment) {
    var data = Map<String, dynamic>();
    data['photoUrl'] = postComment.photoUrl;
    data['name'] = postComment.name;
    data['caption'] = postComment.caption;
    data['date'] = postComment.date;
    data["uid"] = postComment.postUid;
    data["uid"] = postComment.userUid;
    return data;
  }

  // Named constructor
  PostComment.fromMap(Map<String, dynamic> mapData) {
    this.photoUrl = mapData['photoUrl'];
    this.name = mapData['name'];
    this.caption = mapData['caption'];
    this.date = mapData['date'];
    this.postUid = mapData['postUid'];
    this.userUid = mapData['userUid'];
  }
}
