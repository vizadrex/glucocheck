
class GlucoseReading {
  final int? id;
  final double value;
  final DateTime date;
  final String type; // 'fasting', 'postprandial'
  final String? note;

  const GlucoseReading({
    this.id,
    required this.value,
    required this.date,
    required this.type,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'date': date.toIso8601String(),
      'type': type,
      'note': note,
    };
  }

  factory GlucoseReading.fromMap(Map<String, dynamic> map) {
    return GlucoseReading(
      id: map['id'],
      value: map['value'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      note: map['note'],
    );
  }
}

class Medication {
  final int? id;
  final String name;
  final String dosage;
  final String schedule; // e.g. "08:00"
  final DateTime? lastTaken;
  final List<String> frequency; // e.g. ["Mon", "Tue"] or ["Daily"]

  const Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    this.lastTaken,
    this.frequency = const ['Daily'],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'schedule': schedule,
      'lastTaken': lastTaken?.toIso8601String(),
      'frequency': frequency.join(','),
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      schedule: map['schedule'],
      lastTaken: map['lastTaken'] != null ? DateTime.parse(map['lastTaken']) : null,
      frequency: (map['frequency'] as String).split(','),
    );
  }
  
  Medication copyWith({int? id, DateTime? lastTaken}) {
      return Medication(
          id: id ?? this.id,
          name: this.name,
          dosage: this.dosage,
          schedule: this.schedule,
          lastTaken: lastTaken ?? this.lastTaken,
          frequency: this.frequency,
      );
  }
}

class UserProfile {
  final String name;
  final int age;
  final String sex;
  final String diabetesType; // 'Type 1', 'Type 2'
  final String diagnosisDuration;
  final List<String> comorbidities;

  const UserProfile({
    required this.name,
    required this.age,
    required this.sex,
    required this.diabetesType,
    required this.diagnosisDuration,
    required this.comorbidities,
  });

  // To/From Map for SharedPreferences (stored as JSON string)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'sex': sex,
      'diabetesType': diabetesType,
      'diagnosisDuration': diagnosisDuration,
      'comorbidities': comorbidities,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'],
      age: map['age'],
      sex: map['sex'],
      diabetesType: map['diabetesType'],
      diagnosisDuration: map['diagnosisDuration'],
      comorbidities: List<String>.from(map['comorbidities']),
    );
  }
}

class HabitLog {
  final int? id;
  final String type; // 'food', 'activity'
  final String name; // e.g., 'Apple', 'Running'
  final String details; // e.g., '1 unit', '30 mins'
  final DateTime date;

  const HabitLog({
    this.id,
    required this.type,
    required this.name,
    required this.details,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'details': details,
      'date': date.toIso8601String(),
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'],
      type: map['type'],
      name: map['name'],
      details: map['details'],
      date: DateTime.parse(map['date']),
    );
  }
}
