# 🩸 GlucoCheck — Control de diabetes en tu bolsillo

Aplicación móvil en **Flutter** para que personas con diabetes lleven el control diario de su salud: glucosa, medicamentos, hábitos y educación — todo **guardado localmente en el teléfono**, sin cuentas ni internet.

## Características

- 📈 **Registro de glucosa** con historial y **gráficos de tendencia** (fl_chart), clasificando cada medición (hipoglucemia, normal, hiperglucemia) según el momento del día (ayunas, post-comida...).
- 💊 **Gestión de medicamentos** con **recordatorios por notificación local** para no saltarse ninguna dosis.
- ✅ **Hábitos saludables:** seguimiento de agua, ejercicio, alimentación y sueño.
- 📚 **Módulo educativo** con información práctica sobre la diabetes (tipos, alimentación, señales de alerta).
- 👤 **Perfil y onboarding:** datos personales, tipo de diabetes y rangos objetivo personalizados.
- 📊 **Dashboard** que resume el estado del día de un vistazo.

## Tecnologías

- **Flutter / Dart**
- **Riverpod** (+ riverpod_generator) para el estado
- **sqflite** — base de datos local SQLite
- **flutter_local_notifications** — recordatorios de medicación
- **fl_chart** — gráficos de tendencias
- Arquitectura por **features** (`glucose/`, `medication/`, `habits/`, `education/`, `profile/`, `dashboard/`)

## Estructura del proyecto

```
lib/
├── core/
│   ├── providers.dart           # Providers globales (Riverpod)
│   └── services/                # Base de datos, notificaciones, modelos
├── data/models/                 # Modelos de datos
├── features/
│   ├── dashboard/               # Resumen del día
│   ├── glucose/                 # Registro y gráficas de glucosa
│   ├── medication/              # Medicamentos y recordatorios
│   ├── habits/                  # Hábitos saludables
│   ├── education/               # Contenido educativo
│   └── profile/                 # Onboarding y perfil
└── main.dart
```

## Cómo ejecutarlo

```bash
flutter pub get
flutter run
```

Probado en Android. Los recordatorios usan notificaciones locales, así que la app pedirá ese permiso al iniciar.

## Nota

Este es un proyecto académico: no reemplaza la orientación de un profesional de la salud.

## Lo que aprendí con este proyecto

- Modelar un problema de salud real: rangos de glucosa que dependen del contexto (ayunas vs. post-comida) y no de un número fijo.
- Programar **notificaciones locales confiables** en Android (canales, permisos, zonas horarias).
- Organizar una app por **features** con Riverpod, en lugar de un solo árbol de widgets gigante.
