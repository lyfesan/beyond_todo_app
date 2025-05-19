import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;

  User({
    required this.uid,
    required this.email,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] as String,
      email: map['email'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
    };
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User.fromMap(data);
  }
}
