# Doctor Guide BD

An **offline-first** Flutter app that helps Bangladeshi users figure out which
doctor specialist to visit based on their symptoms. No internet connection is
required after install — all data ships as local JSON assets.

## Getting started

```bash
flutter pub get
flutter run
```

Requires Flutter 3.x+ (Dart SDK ^3.3.0).

## Project structure

```
doctor_guide_bd/
├── pubspec.yaml
├── assets/
│   └── data/
│       ├── symptoms.json          # body parts, durations, symptom→specialist mapping, emergency flags
│       ├── specialists.json       # specialist departments (Bengali descriptions)
│       └── medical_degrees.json   # MBBS/FCPS/MD/MS/Professor explained in Bengali
└── lib/
    ├── main.dart                  # entry point, loads JSON, boots the router
    ├── theme.dart                 # shared colors + ThemeData (Tailwind-style constants)
    ├── router/
    │   └── app_router.dart        # go_router route table (the Flutter equivalent of router/index.js)
    ├── data/
    │   └── data_repository.dart   # loads & caches the JSON assets, offline query helpers
    ├── models/
    │   └── models.dart            # BodyPart, SymptomOption, Specialist, MedicalDegree, etc.
    ├── screens/
    │   ├── home_screen.dart
    │   ├── questionnaire_screen.dart      # Step 1 body part → symptom, Step 2 duration, Step 3 age/gender → result
    │   ├── emergency_alert_screen.dart    # Red Flag Alert screen for emergency symptoms
    │   ├── health_guide_screen.dart       # 2 tabs: Medical Degrees Explained / Specialists Guide (offline search)
    │   └── doctor_visit_note_screen.dart  # symptom → 5 quick questions → summary card → Save as PDF/Image
    └── widgets/
        ├── star_rating_widget.dart
        └── summary_card_widget.dart       # the "Doctor Visit Summary Card" captured for export
```

## How the pieces map to your original spec

| You asked for (Vue/Capacitor) | Built here (Flutter) |
|---|---|
| `router/index.js` | `lib/router/app_router.dart` using `go_router` |
| Local JSON for symptoms/departments | `assets/data/*.json`, loaded via `DataRepository` |
| `Questionnaire.vue` | `lib/screens/questionnaire_screen.dart` |
| Red Flag Alert Screen | `lib/screens/emergency_alert_screen.dart` |
| `HealthGuide.vue` (2 tabs, offline search) | `lib/screens/health_guide_screen.dart` |
| `DoctorVisitNote.vue` (summary + Save as PDF/Image) | `lib/screens/doctor_visit_note_screen.dart` + `summary_card_widget.dart` |

## Key behaviors

- **Emergency detection**: any symptom marked `"isEmergency": true` in
  `symptoms.json` (e.g. severe chest pain, breathing difficulty, sudden
  vision loss with pain, sudden worst-ever headache, severe abdominal pain)
  routes straight to the full-screen Red Flag Alert instead of continuing
  the questionnaire.
- **Star ratings**: each symptom maps to one or more specialists with a
  1–5 star confidence score, shown via ⭐ icons, sorted highest-match-first.
- **Offline search**: the Health Guide's search boxes filter the in-memory
  lists loaded at startup — no network calls anywhere in the app.
- **Export**: the Visit Note summary card is captured with `screenshot`,
  then either shared directly as a PNG or embedded into a generated PDF
  (via the `pdf` + `printing` packages) and shared/printed from there.

## Extending the data

To add a new symptom, specialist, or degree, just edit the relevant JSON
file under `assets/data/` — no Dart code changes needed unless you're
adding a new *type* of question or screen.
