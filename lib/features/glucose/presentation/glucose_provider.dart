
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucocheck/core/providers.dart';
import 'package:glucocheck/core/services/database_service.dart';
import 'package:glucocheck/data/models/models.dart';

class GlucoseState {
  final List<GlucoseReading> readings;
  final bool isLoading;

  GlucoseState({this.readings = const [], this.isLoading = false});
}

class GlucoseNotifier extends StateNotifier<GlucoseState> {
  final DatabaseService _db;

  GlucoseNotifier(this._db) : super(GlucoseState()) {
    loadReadings();
  }

  Future<void> loadReadings() async {
    state = GlucoseState(readings: state.readings, isLoading: true);
    final data = await _db.getReadings();
    state = GlucoseState(readings: data, isLoading: false);
  }

  Future<void> addReading(GlucoseReading reading) async {
    await _db.insertReading(reading);
    await loadReadings();
  }
  
  // Getter for the most recent reading (first in list because of DESC order)
  GlucoseReading? get latestReading => state.readings.isNotEmpty ? state.readings.first : null;
  
  // Calculate average of today
  double get averageToday {
    final now = DateTime.now();
    final todayReadings = state.readings.where((r) => 
      r.date.year == now.year && 
      r.date.month == now.month && 
      r.date.day == now.day
    );
    
    if (todayReadings.isEmpty) return 0;
    final sum = todayReadings.fold(0.0, (prev, element) => prev + element.value);
    return sum / todayReadings.length;
  }
}

final glucoseProvider = StateNotifierProvider<GlucoseNotifier, GlucoseState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return GlucoseNotifier(db);
});
