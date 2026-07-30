import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../screens/home_screen.dart';
import '../screens/questionnaire_screen.dart';
import '../screens/emergency_alert_screen.dart';
import '../screens/health_guide_screen.dart';
import '../screens/doctor_visit_note_screen.dart';

/// Central route table for the app.
/// Route names mirror what a Vue Router index.js would define,
/// just expressed with go_router's declarative API.
class AppRoutes {
  static const home = 'home';
  static const questionnaire = 'questionnaire';
  static const emergency = 'emergency';
  static const healthGuide = 'health-guide';
  static const visitNote = 'visit-note';
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/questionnaire',
      name: AppRoutes.questionnaire,
      builder: (context, state) => const QuestionnaireScreen(),
    ),
    GoRoute(
      path: '/emergency',
      name: AppRoutes.emergency,
      builder: (context, state) {
        final symptom = state.extra as SymptomOption?;
        return EmergencyAlertScreen(symptom: symptom);
      },
    ),
    GoRoute(
      path: '/health-guide',
      name: AppRoutes.healthGuide,
      builder: (context, state) => const HealthGuideScreen(),
    ),
    GoRoute(
      path: '/visit-note',
      name: AppRoutes.visitNote,
      builder: (context, state) => const DoctorVisitNoteScreen(),
    ),
  ],
);
