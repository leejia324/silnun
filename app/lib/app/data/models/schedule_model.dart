class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.title,
    required this.date,
    this.checklistId,
  });

  final int id;
  final String title;
  final DateTime date;
  final int? checklistId;

  bool get isAuto => checklistId != null;

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'] as int,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      checklistId: json['checklist_id'] as int?,
    );
  }
}
