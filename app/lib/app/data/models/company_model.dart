class CompanySummary {
  const CompanySummary({
    required this.id,
    required this.name,
    required this.riskLevel,
    this.category,
    this.region,
  });

  final String id;
  final String name;
  final String riskLevel;
  final String? category;
  final String? region;

  factory CompanySummary.fromJson(Map<String, dynamic> json) {
    return CompanySummary(
      id: json['id'] as String,
      name: json['name'] as String,
      riskLevel: json['risk_level'] as String? ?? 'no_data',
      category: json['category'] as String?,
      region: json['region'] as String?,
    );
  }
}

class ViolationItem {
  const ViolationItem({
    required this.year,
    required this.count,
    this.description,
  });

  final int year;
  final int count;
  final String? description;

  factory ViolationItem.fromJson(Map<String, dynamic> json) {
    return ViolationItem(
      year: json['year'] as int,
      count: json['count'] as int,
      description: json['description'] as String?,
    );
  }
}

class LaborConditionItem {
  const LaborConditionItem({required this.type, required this.compliant});

  final String type;
  final bool compliant;

  factory LaborConditionItem.fromJson(Map<String, dynamic> json) {
    return LaborConditionItem(
      type: json['type'] as String,
      compliant: json['compliant'] as bool,
    );
  }

  String get label {
    switch (type) {
      case 'minimumWage':
        return '최저임금';
      case 'workHours':
        return '근로시간';
      case 'safetyEducation':
        return '안전교육';
      case 'protectiveGear':
        return '보호장비';
      default:
        return type;
    }
  }
}

class CompanyDetail {
  const CompanyDetail({
    required this.id,
    required this.name,
    required this.riskLevel,
    this.category,
    this.region,
    this.employeeSizeBand,
    this.reportYear,
    this.injuryRate,
    this.avgInjuryRate,
    this.workerCount,
    this.casualtyCount,
    this.seriousCasualtyCount,
    this.violations = const [],
    this.laborConditions = const [],
  });

  final String id;
  final String name;
  final String riskLevel;
  final String? category;
  final String? region;
  final String? employeeSizeBand;
  final int? reportYear;
  final double? injuryRate;
  final double? avgInjuryRate;
  final int? workerCount;
  final int? casualtyCount;
  final int? seriousCasualtyCount;
  final List<ViolationItem> violations;
  final List<LaborConditionItem> laborConditions;

  factory CompanyDetail.fromJson(Map<String, dynamic> json) {
    return CompanyDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      riskLevel: json['risk_level'] as String? ?? 'no_data',
      category: json['category'] as String?,
      region: json['region'] as String?,
      employeeSizeBand: json['employee_size_band'] as String?,
      reportYear: json['report_year'] as int?,
      injuryRate: (json['injury_rate'] as num?)?.toDouble(),
      avgInjuryRate: (json['avg_injury_rate'] as num?)?.toDouble(),
      workerCount: json['worker_count'] as int?,
      casualtyCount: json['casualty_count'] as int?,
      seriousCasualtyCount: json['serious_casualty_count'] as int?,
      violations: (json['violations'] as List? ?? [])
          .map((e) => ViolationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      laborConditions: (json['labor_conditions'] as List? ?? [])
          .map((e) => LaborConditionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
