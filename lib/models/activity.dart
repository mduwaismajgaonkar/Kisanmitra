enum ActivityType { irrigation, fertilizer, sowing, spraying, harvesting, other }

String activityLabel(ActivityType t) {
  switch (t) {
    case ActivityType.irrigation:
      return 'Irrigation';
    case ActivityType.fertilizer:
      return 'Fertilizer';
    case ActivityType.sowing:
      return 'Sowing';
    case ActivityType.spraying:
      return 'Spraying';
    case ActivityType.harvesting:
      return 'Harvesting';
    case ActivityType.other:
      return 'Other';
  }
}

class Activity {
  final DateTime date;
  final ActivityType type;
  final String note;

  const Activity({
    required this.date,
    required this.type,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'type': type.name,
        'note': note,
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        date: DateTime.parse(json['date'] as String),
        type: ActivityType.values.byName(json['type'] as String),
        note: json['note'] as String? ?? '',
      );
}