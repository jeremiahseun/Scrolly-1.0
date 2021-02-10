class Post {
  String photoUrl;
  String name;
  String caption;
  String location;
  String date;
  String uid;

  Post(
      {this.photoUrl,
      this.name,
      this.caption,
      this.location,
      this.date,
      this.uid});

  Map toMap(Post post) {
    var data = Map<String, dynamic>();
    data['photoUrl'] = post.photoUrl;
    data['name'] = post.name;
    data['caption'] = post.caption;
    data['date'] = post.date;
    data['location'] = post.location;
    data["uid"] = post.uid;
    return data;
  }

  // Named constructor
  Post.fromMap(Map<String, dynamic> mapData) {
    this.photoUrl = mapData['photoUrl'];
    this.name = mapData['name'];
    this.caption = mapData['caption'];
    this.location = mapData['location'];
    this.date = mapData['date'];
    this.uid = mapData['uid'];
  }
}
