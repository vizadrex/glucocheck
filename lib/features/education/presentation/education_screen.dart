
import 'package:flutter/material.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  final List<Map<String, String>> topics = const [
    {
      'title': '¿Qué es la diabetes?',
      'content': 'La diabetes es una enfermedad crónica que afecta la forma en que el cuerpo convierte los alimentos en energía. El cuerpo no produce suficiente insulina o no puede usarla adecuadamente.'
    },
    {
      'title': 'Importancia del tratamiento',
      'content': 'Seguir el tratamiento ayuda a prevenir complicaciones graves como enfermedades cardíacas, pérdida de visión y problemas renales. Mantener la glucosa en rango es clave.'
    },
    {
      'title': 'Signos de alarma (Hipoglucemia)',
      'content': 'Si sientes temblores, sudoración, hambre excesiva o mareos, tu azúcar puede estar baja (<70 mg/dL). Consume un carbohidrato simple rápidamente.'
    },
    {
      'title': 'Signos de alarma (Hiperglucemia)',
      'content': 'Sed excesiva, ganas frecuentes de orinar, boca seca o dolor de cabeza pueden indicar azúcar alta. Bebe agua y revisa tu medicación.'
    },
    {
      'title': 'Alimentación Saludable',
      'content': 'Prefiere vegetales, granos integrales y proteínas magras. Evita bebidas azucaradas, dulces y harinas refinadas. Controla las porciones.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Educación 📚')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final item = topics[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(item['content']!, style: const TextStyle(fontSize: 15, height: 1.4)),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
