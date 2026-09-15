// LAB ACT 4 - ENHANCEMENT 3: Using the user_service create your own user.dart (model) implementing it on this project
// LAB ACT 5 - ENHANCEMENT 2 & 3: Extended with loginType and profile fields (age, contactNo)
class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String accessToken;
  final String refreshToken;
  final String loginType;
  final String age;
  final String contactNo;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.accessToken,
    required this.refreshToken,
    this.loginType = 'dummyjson',
    this.age = '',
    this.contactNo = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? json['fName'] ?? '',
      lastName: json['lastName'] ?? json['lName'] ?? '',
      gender: json['gender'] ?? '',
      image: json['image'] ?? '',
      accessToken: json['accessToken'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      loginType: json['loginType'] ?? 'dummyjson',
      age: json['age']?.toString() ?? '',
      contactNo: json['contactNo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'loginType': loginType,
      'age': age,
      'contactNo': contactNo,
    };
  }
}
