class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.label,
    required this.checked,
    this.category = '',
    this.warning = false,
  });

  final int id;
  final String label;
  final bool checked;
  final String category;
  final bool warning;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as int,
      label: json['label'] as String,
      checked: json['checked'] as bool? ?? false,
      category: json['category'] as String? ?? '',
      warning: json['warning'] as bool? ?? false,
    );
  }
}

class Checklist {
  const Checklist({
    required this.id,
    required this.companyId,
    required this.status,
    required this.progress,
    this.companyName,
    this.items = const [],
  });

  final int id;
  final String companyId;
  final String status;
  final double progress;
  final String? companyName;
  final List<ChecklistItem> items;

  bool get isCompleted => status == 'completed';

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      id: json['id'] as int,
      companyId: json['company_id'] as String,
      companyName: json['company_name'] as String?,
      status: json['status'] as String? ?? 'in_progress',
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
