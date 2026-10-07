class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.school,
    this.grade,
  });

  final String uid;
  final String email;
  final String? name;
  final String? school;
  final String? grade;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      school: json['school'] as String?,
      grade: json['grade'] as String?,
    );
  }
}
