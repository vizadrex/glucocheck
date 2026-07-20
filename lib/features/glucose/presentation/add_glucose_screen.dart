
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:glucocheck/data/models/models.dart';
import 'package:glucocheck/features/glucose/presentation/glucose_provider.dart';

class AddGlucoseScreen extends ConsumerStatefulWidget {
  const AddGlucoseScreen({super.key});

  @override
  ConsumerState<AddGlucoseScreen> createState() => _AddGlucoseScreenState();
}

class _AddGlucoseScreenState extends ConsumerState<AddGlucoseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _noteController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _type = 'Postprandial'; // 'Ayunas' or 'Postprandial'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Glucosa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Value Input
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nivel de Glucosa (mg/dL)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.water_drop),
                  suffixText: 'mg/dL'
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa un valor';
                  if (double.tryParse(value) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Momento
              const Text('Momento de la medición:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                   Expanded(
                     child: RadioListTile<String>(
                       title: const Text('Ayunas'),
                       value: 'Ayunas',
                       groupValue: _type,
                       onChanged: (val) => setState(() => _type = val!),
                     ),
                   ),
                   Expanded(
                     child: RadioListTile<String>(
                       title: const Text('Post-Comida'),
                       value: 'Postprandial',
                       groupValue: _type,
                       onChanged: (val) => setState(() => _type = val!),
                     ),
                   ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                      label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      onPressed: _pickTime,
                      label: Text(_selectedTime.format(context)),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Notes
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notas (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 30),
              
              FilledButton.icon(
                onPressed: _saveReading,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR LECTURA'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _saveReading() {
    if (_formKey.currentState!.validate()) {
      final value = double.parse(_valueController.text);
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Alert Logic
      if (value < 70 || value > 250) {
        _showDangerDialog(value, dateTime);
      } else {
        _commitSave(value, dateTime);
      }
    }
  }

  void _showDangerDialog(double value, DateTime dateTime) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.warning, color: Colors.red), SizedBox(width: 10), Text('VALOR CRÍTICO')]),
        content: Text('Tu nivel de $value mg/dL es peligroso. \n\nPor favor, contacta a tu médico o acude a urgencias si te sientes mal.'),
        actions: [
            TextButton(onPressed: () { 
                Navigator.pop(ctx); 
                _commitSave(value, dateTime); // Save anyway
            }, child: const Text('Entendido y Guardar')),
        ],
      ),
    );
  }

  Future<void> _commitSave(double value, DateTime dateTime) async {
    final reading = GlucoseReading(
      value: value,
      date: dateTime,
      type: _type,
      note: _noteController.text,
    );
    
    await ref.read(glucoseProvider.notifier).addReading(reading);
    if (mounted) Navigator.pop(context);
  }
}
