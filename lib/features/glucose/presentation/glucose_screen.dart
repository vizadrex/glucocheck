
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/services/database_service.dart';
import '../../../data/models/models.dart';

class GlucoseScreen extends StatefulWidget {
  const GlucoseScreen({super.key});

  @override
  State<GlucoseScreen> createState() => _GlucoseScreenState();
}

class _GlucoseScreenState extends State<GlucoseScreen> {
  final DatabaseService _db = DatabaseService();
  List<GlucoseReading> _readings = [];
  bool _isLoading = true;

  // Chart Filtering
  String _chartFilter = 'Weekly'; // Daily, Weekly, Monthly

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    final data = await _db.getGlucoseReadings();
    setState(() {
      _readings = data;
      _isLoading = false;
    });
  }

  Future<void> _addReading(double value, DateTime date, String type, String note) async {
    // Alert Logic
    if (value < 60 || value > 250) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('⚠️ ALERTA DE SALUD', style: TextStyle(color: Colors.red)),
          content: Text(
              'Su nivel de glucosa ($value mg/dL) está fuera del rango seguro.\n\nPor favor, acuda a un centro de salud o contacte a su médico inmediatamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ENTENDIDO'),
            ),
          ],
        ),
      );
    }

    final reading = GlucoseReading(
      value: value,
      date: date,
      type: type,
      note: note.isEmpty ? null : note,
    );

    await _db.insertGlucose(reading);
    _loadReadings();
  }

  void _showAddDialog() {
    final valueController = TextEditingController();
    final noteController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedType = 'Ayunas';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Registrar Glucosa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nivel de Glucosa (mg/dL)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedType,
                      items: ['Ayunas', 'Postprandial'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setModalState(() => selectedType = val!),
                      decoration: const InputDecoration(labelText: 'Momento'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                   Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setModalState(() => selectedDate = picked);
                      },
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(selectedTime.format(context)),
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: selectedTime);
                        if (picked != null) setModalState(() => selectedTime = picked);
                      },
                    ),
                  ),
                ],
              ),
               TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Notas (Opcional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final val = double.tryParse(valueController.text);
                  if (val == null) return;
                  
                  final finalDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  
                  _addReading(val, finalDate, selectedType, noteController.text);
                  Navigator.pop(ctx);
                },
                child: const Text('GUARDAR'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor(double value) {
    if (value < 70 || value > 180) return Colors.red;
    if (value >= 70 && value <= 130) return Colors.green;
    return Colors.orange; // 131-179 alert/elevated
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control de Glucemia')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Chart Section
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  child: _readings.isEmpty
                      ? const Center(child: Text('No hay datos suficientes para el grafico'))
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: const FlTitlesData(
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _readings.map((r) => FlSpot(r.date.millisecondsSinceEpoch.toDouble(), r.value)).toList(),
                                isCurved: true,
                                color: Theme.of(context).primaryColor,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(show: true, color: Theme.of(context).primaryColor.withOpacity(0.2)),
                              ),
                            ],
                          ),
                        ),
                ),
                const Divider(),
                // History List
                Expanded(
                  child: ListView.builder(
                    itemCount: _readings.length,
                    itemBuilder: (context, index) {
                      final r = _readings[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColor(r.value),
                          child: Text(
                            r.value.toInt().toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text('${r.value} mg/dL - ${r.type}'),
                        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(r.date)),
                        trailing: r.note != null ? const Icon(Icons.note_alt, size: 16) : null,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
