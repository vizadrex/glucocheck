
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../../core/services/database_service.dart';
import '../../../../data/models/models.dart';

class MedicationNotifier extends StateNotifier<List<Medication>> {
  final DatabaseService _db;

  MedicationNotifier(this._db) : super([]) {
    loadMeds();
  }

  Future<void> loadMeds() async {
    final meds = await _db.getMedications();
    state = meds;
  }

  Future<void> addMedication(Medication med) async {
    await _db.insertMedication(med);
    await loadMeds();
  }
}

final medicationProvider = StateNotifierProvider<MedicationNotifier, List<Medication>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return MedicationNotifier(db);
});
