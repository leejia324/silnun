class CompanySummary {
  const CompanySummary({
    required this.id,
    required this.name,
    required this.riskLevel,
    this.region,
  });

  final String id;
  final String name;
  final String riskLevel;
  final String? region;

  factory CompanySummary.fromJson(Map<String, dynamic> json) {
    return CompanySummary(
      id: json['id'] as String,
      name: json['name'] as String,
      riskLevel: json['risk_level'] as String? ?? 'no_data',
      region: json['region'] as String?,
    );
  }
}
