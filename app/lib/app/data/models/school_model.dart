class School {
  const School({required this.name, required this.region, this.kind});

  final String name;
  final String region;
  final String? kind;

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      name: json['SCHUL_NM'] as String? ?? '',
      region: json['LCTN_SC_NM'] as String? ?? '',
      kind: json['SCHUL_KND_SC_NM'] as String?,
    );
  }
}
