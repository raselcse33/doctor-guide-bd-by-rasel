import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'data/data_repository.dart';
import 'router/app_router.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DoctorGuideApp());
}

class DoctorGuideApp extends StatefulWidget {
  const DoctorGuideApp({super.key});

  @override
  State<DoctorGuideApp> createState() => _DoctorGuideAppState();
}

class _DoctorGuideAppState extends State<DoctorGuideApp> {
  late Future<void> _dataFuture;

  @override
  void initState() {
    super.initState();
    // Load all local JSON once at startup — after this, the app
    // needs zero network access to function.
    _dataFuture = DataRepository.instance.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            title: 'Doctor Guide BD',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            home: const _SplashScreen(),
          );
        }
        return MaterialApp.router(
          title: 'Doctor Guide BD',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          routerConfig: appRouter,
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F766E),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_hospital_rounded, color: Colors.white, size: 56),
            SizedBox(height: 16),
            Text(
              'Doctor Guide BD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
