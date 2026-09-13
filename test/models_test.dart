// Pruebas de los modelos de datos: la conversión a/desde Map es la frontera
// con SQLite y con SharedPreferences, así que es donde aparecen los errores
// de tipo silenciosos.

import 'package:flutter_test/flutter_test.dart';
import 'package:glucocheck/data/models/models.dart';

void main() {
  group('GlucoseReading', () {
    test('toMap y fromMap conservan los datos', () {
      final original = GlucoseReading(
        id: 7,
        value: 126.5,
        date: DateTime(2026, 3, 14, 8, 30),
        type: 'fasting',
        note: 'antes del desayuno',
      );

      final copia = GlucoseReading.fromMap(original.toMap());

      expect(copia.id, original.id);
      expect(copia.value, original.value);
      expect(copia.date, original.date);
      expect(copia.type, original.type);
      expect(copia.note, original.note);
    });

    test('acepta un entero donde SQLite guardó una columna REAL', () {
      // SQLite devuelve int cuando el valor almacenado no tiene decimales.
      // Sin la conversión con num.toDouble() esto lanzaba un error de tipo.
      final lectura = GlucoseReading.fromMap({
        'id': 1,
        'value': 90, // int, no double
        'date': '2026-03-14T08:30:00.000',
        'type': 'fasting',
        'note': null,
      });

      expect(lectura.value, 90.0);
      expect(lectura.value, isA<double>());
    });

    test('la fecha sobrevive al viaje de ida y vuelta por texto ISO', () {
      final fecha = DateTime(2026, 12, 31, 23, 59, 59);
      final lectura = GlucoseReading(value: 110, date: fecha, type: 'postprandial');

      expect(GlucoseReading.fromMap(lectura.toMap()).date, fecha);
    });
  });

  group('Medication', () {
    test('la frecuencia se guarda separada por comas y se recupera como lista', () {
      const medicamento = Medication(
        id: 3,
        name: 'Metformina',
        dosage: '850 mg',
        schedule: '08:00',
        frequency: ['Lun', 'Mié', 'Vie'],
      );

      final mapa = medicamento.toMap();
      expect(mapa['frequency'], 'Lun,Mié,Vie');

      final copia = Medication.fromMap(mapa);
      expect(copia.frequency, ['Lun', 'Mié', 'Vie']);
      expect(copia.name, 'Metformina');
      expect(copia.dosage, '850 mg');
    });

    test('lastTaken nulo se conserva como nulo', () {
      const medicamento = Medication(name: 'Insulina', dosage: '10 UI', schedule: '22:00');
      final copia = Medication.fromMap(medicamento.toMap());
      expect(copia.lastTaken, isNull);
    });

    test('copyWith marca la toma sin perder el resto de los datos', () {
      const medicamento = Medication(
        id: 1, name: 'Metformina', dosage: '850 mg', schedule: '08:00',
        frequency: ['Daily'],
      );
      final tomado = DateTime(2026, 3, 14, 8, 5);

      final actualizado = medicamento.copyWith(lastTaken: tomado);

      expect(actualizado.lastTaken, tomado);
      expect(actualizado.name, medicamento.name);
      expect(actualizado.dosage, medicamento.dosage);
      expect(actualizado.frequency, medicamento.frequency);
    });
  });

  group('UserProfile', () {
    test('las comorbilidades se recuperan como List<String>', () {
      const perfil = UserProfile(
        name: 'Adrián',
        age: 24,
        sex: 'M',
        diabetesType: 'Type 2',
        diagnosisDuration: '3 años',
        comorbidities: ['Hipertensión'],
      );

      final copia = UserProfile.fromMap(perfil.toMap());

      expect(copia.comorbidities, ['Hipertensión']);
      expect(copia.diabetesType, 'Type 2');
      expect(copia.age, 24);
    });
  });

  group('HabitLog', () {
    test('toMap y fromMap conservan los datos', () {
      final habito = HabitLog(
        type: 'activity',
        name: 'Caminata',
        details: '30 min',
        date: DateTime(2026, 3, 14, 19, 0),
      );

      final copia = HabitLog.fromMap(habito.toMap());

      expect(copia.type, 'activity');
      expect(copia.name, 'Caminata');
      expect(copia.details, '30 min');
      expect(copia.date, habito.date);
    });
  });
}
