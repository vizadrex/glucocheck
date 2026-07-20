
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; 
import '../../../core/services/database_service.dart';
import '../../../data/models/models.dart';
import '../../../core/services/notification_service.dart';

class SanitarioScreen extends StatefulWidget {
  const SanitarioScreen({super.key});

  @override
  State<SanitarioScreen> createState() => _SanitarioScreenState();
}

class _SanitarioScreenState extends State<SanitarioScreen> {
  final DatabaseService _db = DatabaseService();
  List<MedicalAppointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final docs = await _db.getAppointments();
    setState(() => _appointments = docs);
  }

  Future<void> _addAppointment(String title, String type, DateTime date, TimeOfDay time) async {
    final finalDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    
    final appt = MedicalAppointment(
      title: title,
      date: finalDate,
      type: type,
    );
    
    final id = await _db.insertAppointment(appt);
    
    // Remind 1 day before
    final reminderDate = finalDate.subtract(const Duration(days: 1));
    if (reminderDate.isAfter(DateTime.now())) {
      await NotificationService().scheduleNotification(
        id: id + 1000, 
        title: 'Recordatorio de Salud 🏥', 
        body: 'Mañana tienes: $title ($type) a las ${time.format(context)}', 
        scheduledTime: reminderDate
      );
    }
    
    _loadAppointments();
  }
  
  Future<void> _generateAndSharePDF() async {
     final pdf = pw.Document();
     final readings = await _db.getGlucoseReadings();
     final meds = await _db.getMedications();
     
     pdf.addPage(
       pw.Page(
         build: (pw.Context context) {
           return pw.Column(
             crossAxisAlignment: pw.CrossAxisAlignment.start,
             children: [
               pw.Header(level: 0, child: pw.Text("Reporte Clínico GLUCOCHECK")),
               pw.Paragraph(text: "Fecha de generación: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}"),
               
               pw.Header(level: 1, child: pw.Text("Últimas Mediciones de Glucosa")),
               pw.TableHelper.fromTextArray(
                 context: context,
                 data: <List<String>>[
                   <String>['Fecha', 'Valor', 'Momento', 'Contexto'],
                   ...readings.take(15).map((r) => [
                     DateFormat('dd/MM/yy HH:mm').format(r.date),
                     '${r.value}',
                     r.type,
                     r.context ?? 'Rutina'
                   ])
                 ],
               ),
               
               pw.SizedBox(height: 20),
               pw.Header(level: 1, child: pw.Text("Esquema de Medicación Actual")),
               ...meds.map((m) => pw.Bullet(text: "${m.name} - ${m.dosage} (${m.schedule})")),
             ]
           );
         }
       )
     );
     
     final output = await getTemporaryDirectory();
     final file = File("${output.path}/Reporte_GlucoCheck.pdf");
     await file.writeAsBytes(await pdf.save());
     
     await Share.shareXFiles([XFile(file.path)], text: 'Mi reporte clínico GlucoCheck');
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedType = 'Cita Médica';

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
              const Text('Nueva Cita / Examen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Descripción (Ej. Endocrinólogo)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: ['Cita Médica', 'Examen (HbA1c, etc.)', 'Podología', 'Oftalmología'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setModalState(() => selectedType = val!),
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
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    _addAppointment(titleController.text, selectedType, selectedDate, selectedTime);
                    Navigator.pop(ctx);
                  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento Sanitario')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.blue.shade50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('EXPORTAR REPORTE CLÍNICO (PDF)'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: _generateAndSharePDF,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(alignment: Alignment.centerLeft, child: Text('Citas y Exámenes Pendientes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          Expanded(
            child: _appointments.isEmpty 
            ? const Center(child: Text('No hay citas programadas.'))
            : ListView.builder(
              itemCount: _appointments.length,
              itemBuilder: (ctx, i) {
                 final app = _appointments[i];
                 final isPast = app.date.isBefore(DateTime.now());
                 return ListTile(
                   leading: CircleAvatar(
                     backgroundColor: isPast ? Colors.grey : Colors.blue,
                     child: Icon(app.type.contains('Examen') ? Icons.science : Icons.medical_services, color: Colors.white),
                   ),
                   title: Text(app.title, style: TextStyle(decoration: isPast ? TextDecoration.lineThrough : null)),
                   subtitle: Text('${DateFormat('dd/MM/yyyy HH:mm').format(app.date)} | ${app.type}'),
                   trailing: IconButton(
                     icon: const Icon(Icons.delete, color: Colors.red),
                     onPressed: () async {
                       await _db.deleteAppointment(app.id!);
                       _loadAppointments();
                     },
                   ),
                 );
              }
            )
          )
        ],
      ),
    );
  }
}
