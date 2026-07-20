
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/database_service.dart';
import '../../../data/models/models.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _db = DatabaseService();
  final _foodController = TextEditingController();
  final _activityTypeController = TextEditingController();
  final _activityDurationController = TextEditingController();
  final _activityFreqController = TextEditingController();

  List<HabitLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHabits();
  }
  
  Future<void> _loadHabits() async {
    final data = await _db.getHabits();
    setState(() => _logs = data);
  }

  Future<void> _saveHabit(String type, String name, String details) async {
    final habit = HabitLog(
      type: type,
      name: name,
      details: details,
      date: DateTime.now(),
    );
    await _db.insertHabit(habit);
    _loadHabits();
    
    // Clear inputs
    _foodController.clear();
    _activityTypeController.clear();
    _activityDurationController.clear();
    _activityFreqController.clear();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro guardado')));
    }
  }

  Widget _buildFoodTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Registro de Alimentación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextField(
            controller: _foodController,
            decoration: const InputDecoration(labelText: '¿Qué comiste hoy?', suffixIcon: Icon(Icons.restaurant)),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
               if (_foodController.text.isNotEmpty) {
                 _saveHabit('food', _foodController.text, 'N/A');
               }
            },
            child: const Text('GUARDAR ALIMENTO'),
          ),
          const SizedBox(height: 20),
          const Text('Sugerencias Saludables:', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView(
              children: const [
                ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text('Ensalada de vegetales frescos')),
                ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text('Pechuga de pollo a la plancha')),
                ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text('Frutas bajas en azucar (Fresa, Kiwi)')),
                ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text('Agua (2 litros diarios)')),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Registro de Actividad Fisica', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextField(
            controller: _activityTypeController,
            decoration: const InputDecoration(labelText: 'Tipo (Ej. Caminata)', suffixIcon: Icon(Icons.directions_run)),
          ),
           TextField(
            controller: _activityDurationController,
            decoration: const InputDecoration(labelText: 'Duracion (Ej. 30 mins)', suffixIcon: Icon(Icons.timer)),
          ),
           TextField(
            controller: _activityFreqController,
            decoration: const InputDecoration(labelText: 'Frecuencia (Ej. Diario)', suffixIcon: Icon(Icons.event_repeat)),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (_activityTypeController.text.isNotEmpty) {
                _saveHabit('activity', _activityTypeController.text, '${_activityDurationController.text} - ${_activityFreqController.text}');
              }
            },
            child: const Text('GUARDAR ACTIVIDAD'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitos Saludables'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Alimentación'), Tab(text: 'Actividad Física')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFoodTab(),
          _buildActivityTab(),
        ],
      ),
    );
  }
}
