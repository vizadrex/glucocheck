
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../glucose/presentation/glucose_screen.dart';
import '../../medication/presentation/medication_screen.dart';
import '../../habits/presentation/habits_screen.dart';
import '../../education/presentation/education_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../../core/services/database_service.dart';
import '../../../data/models/models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _db = DatabaseService();
  List<GlucoseReading> _recentReadings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  // Reload data when returning involves using RouteAware or just simple setState on navigation pop
  Future<void> _loadData() async {
    final readings = await _db.getGlucoseReadings();
    setState(() {
      _recentReadings = readings.take(7).toList(); // Last 7 readings
    });
  }

  void _navigateTo(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    _loadData(); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GLUCOCHECK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _navigateTo(const ProfileScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Chart
              const Text('Resumen Reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)],
                ),
                child: _recentReadings.isEmpty
                    ? const Center(child: Text('Registra tu glucosa para ver el grafico'))
                    : LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _recentReadings.map((r) => FlSpot(r.date.millisecondsSinceEpoch.toDouble(), r.value)).toList(),
                              isCurved: true,
                              color: Theme.of(context).primaryColor,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              
              // Menu Grid
              const Text('Modulos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    icon: Icons.bloodtype, 
                    color: Colors.redAccent, 
                    label: 'Glucemia',
                    onTap: () => _navigateTo(const GlucoseScreen()),
                  ),
                  _buildMenuCard(
                    icon: Icons.medication, 
                    color: Colors.blueAccent, 
                    label: 'Medicamentos',
                    onTap: () => _navigateTo(const MedicationScreen()),
                  ),
                  _buildMenuCard(
                    icon: Icons.restaurant, 
                    color: Colors.green, 
                    label: 'Habitos',
                    onTap: () => _navigateTo(const HabitsScreen()),
                  ),
                  _buildMenuCard(
                    icon: Icons.school, 
                    color: Colors.orange, 
                    label: 'Educación',
                    onTap: () => _navigateTo(const EducationScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, spreadRadius: 2)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
