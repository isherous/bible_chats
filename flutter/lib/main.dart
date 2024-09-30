import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'Global/colors.dart';
import 'Providers/main-provider.dart';
import 'Screens/home-screen.dart';
import 'firebase_options.dart';

///Firebase
final Future<FirebaseApp> _initialization =
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: kTransparent,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ///Analytics
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainProvider()),
      ],
      child: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Container(color: Colors.amber);
          if (snapshot.connectionState == ConnectionState.done) {
            ///Removing the Splash Screen
            FlutterNativeSplash.remove();

            return MaterialApp(
              title: 'Bible Chat',
              navigatorObservers: <NavigatorObserver>[observer],
              home: const Home(),
            );
          }
          return Container();
        },
      ),
    );
  }
}
