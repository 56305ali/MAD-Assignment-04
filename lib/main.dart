import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'providers/activity_provider.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Error initializing cameras: $e');
  }
  runApp(const SmartTrackerApp());
}

class SmartTrackerApp extends StatelessWidget {
  const SmartTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: MaterialApp(
        title: 'SmartTracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/history': (context) => const HistoryScreen(),
        },
      ),
    );
  }
}
