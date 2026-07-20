
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _durationController = TextEditingController();
  
  String _sex = 'Male';
  String _diabetesType = 'Type 2';
  
  // Checkbox states for Comorbidities
  bool _hta = false;
  bool _obesity = false;
  bool _cholesterol = false;
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      final profile = UserProfile.fromMap(jsonDecode(profileJson));
      setState(() {
        _nameController.text = profile.name;
        _ageController.text = profile.age.toString();
        _durationController.text = profile.diagnosisDuration;
        _sex = profile.sex;
        _diabetesType = profile.diabetesType;
        
        // Load comorbidities
        _hta = profile.comorbidities.contains('HTA');
        _obesity = profile.comorbidities.contains('Obesidad');
        _cholesterol = profile.comorbidities.contains('Colesterol');
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      List<String> comorbidities = [];
      if (_hta) comorbidities.add('HTA');
      if (_obesity) comorbidities.add('Obesidad');
      if (_cholesterol) comorbidities.add('Colesterol');

      final profile = UserProfile(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        sex: _sex,
        diabetesType: _diabetesType,
        diagnosisDuration: _durationController.text,
        comorbidities: comorbidities,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', jsonEncode(profile.toMap()));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Saved Successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                       TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre Completo', icon: Icon(Icons.person)),
                        validator: (value) => value!.isEmpty ? 'Ingrese su nombre' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(labelText: 'Edad', icon: Icon(Icons.cake)),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Ingrese su edad' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _sex,
                        decoration: const InputDecoration(labelText: 'Sexo', icon: Icon(Icons.male)),
                        items: ['Male', 'Female', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => _sex = val!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Informacion Clinica', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                       DropdownButtonFormField<String>(
                        value: _diabetesType,
                        decoration: const InputDecoration(labelText: 'Tipo de Diabetes', icon: Icon(Icons.medical_services)),
                        items: ['Type 1', 'Type 2', 'Gestacional'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => _diabetesType = val!),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(labelText: 'Tiempo de enfermedad (años)', icon: Icon(Icons.timer)),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      const Text('Comorbilidades:', textAlign: TextAlign.left),
                      CheckboxListTile(
                        title: const Text('Hipertension (HTA)'),
                        value: _hta,
                        onChanged: (val) => setState(() => _hta = val!),
                      ),
                      CheckboxListTile(
                        title: const Text('Obesidad'),
                        value: _obesity,
                        onChanged: (val) => setState(() => _obesity = val!),
                      ),
                      CheckboxListTile(
                        title: const Text('Colesterol Alto'),
                        value: _cholesterol,
                        onChanged: (val) => setState(() => _cholesterol = val!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR PERFIL'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
