class UserModel {
  String uid; // A special id given by Firebase
  String name; // The user full name
  String email; // The user email address
  String username; // The user preferred username
  String status;
  String schoolName; // e.g University of Ibadan
  String dateOfBirth; // e.g 13th May
  String userLocation; // Where the user lives
  String dateJoined; // The date this user joins the platform
  String userBio; // A short bio about the user
  String department; // The user school department e.g Mathematics Education
  String level; // e.g 200
  int state;
  String profilePhoto;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.username,
    this.status,
    this.schoolName,
    this.dateJoined,
    this.dateOfBirth,
    this.userBio,
    this.userLocation,
    this.department,
    this.level,
    this.state,
    this.profilePhoto,
  });

  Map toMap(UserModel user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['name'] = user.name;
    data['email'] = user.email;
    data['username'] = user.username;
    data['date_joined'] = user.dateJoined;
    data['date_of_birth'] = user.dateOfBirth;
    data['user_bio'] = user.userBio;
    data['user_location'] = user.userLocation;
    data["status"] = user.status;
    data['school_name'] = user.schoolName;
    data['department'] = user.department;
    data['level'] = user.level;
    data["state"] = user.state;
    data["profile_photo"] = user.profilePhoto;
    return data;
  }

  // Named constructor
  UserModel.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.username = mapData['username'];
    this.status = mapData['status'];
    this.schoolName = mapData['school_name'];
    this.department = mapData['department'];
    this.dateJoined = mapData['date_joined'];
    this.dateOfBirth = mapData['date_of_birth'];
    this.userLocation = mapData['user_location'];
    this.userBio = mapData['user_bio'];
    this.level = mapData['level'];
    this.state = mapData['state'];
    this.profilePhoto = mapData['profile_photo'];
  }
}
