class UserModel {
  String uid;
  String? email;
  String? nama;
  String role;

  UserModel({required this.uid, this.email, this.nama, required this.role});

  //receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      nama: map['nama'],
      role: map['role'],
    );
  }

  //sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email':email,
      'name': nama,
      'role': role,
    };
  }
}
