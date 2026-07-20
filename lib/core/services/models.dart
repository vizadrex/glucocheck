// Archivo: lib/core/services/models.dart

class GlucoseReading {
  final int? id;
  final double value; // Valor de glucosa
  final DateTime date; // Fecha y hora
  final String type; // 'ayunas' o 'postprandial'

  GlucoseReading({
    this.id,
    required this.value,
    required this.date,
    required this.type,
  });

  // Convertir a Map para guardar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'date': date.toIso8601String(), // Guardamos fecha como texto
      'type': type,
    };
  }

  // Crear objeto desde Map recuperado de SQLite
  factory GlucoseReading.fromMap(Map<String, dynamic> map) {
    return GlucoseReading(
      id: map['id'],
      value: (map['value'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      type: map['type'],
    );
  }
}

class Medication {
  final int? id;
  final String name; // Nombre del medicamento
  final String dosage; // Dosis
  final String frequency; // Frecuencia/Horario

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      frequency: map['frequency'],
    );
  }
}