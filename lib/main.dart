import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/widgets/home.dart';
import 'package:task_manager/firebase_options.dart';
import 'package:task_manager/theme/theme.dart';
import 'package:time_machine/time_machine.dart';
import 'dart:io';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

bool amoledTheme = false;
bool materialColor = true;
Locale locale = const Locale('en', 'US');

void main() async {
  final String timeZoneName;

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black),
  );

  if (Platform.isAndroid || Platform.isIOS) {
    timeZoneName = await FlutterTimezone.getLocalTimezone();
  } else {
    timeZoneName = '${DateTimeZone.local}';
  }

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  const DarwinInitializationSettings initializationSettingsIos =
      DarwinInitializationSettings();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIos);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MyAppState();
}

class _MyAppState extends State<MainApp> {
  final themeController = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DynamicColorBuilder(
        builder: (lightColorTheme, darkColorTheme) {
          final lightMaterialTheme =
              lightTheme(lightColorTheme?.surface, lightColorTheme);
          final darkMaterialTheme =
              darkTheme(darkColorTheme?.surface, darkColorTheme);
          final darkMaterialThemeOled = darkTheme(oledColor, darkColorTheme);

          return GetMaterialApp(
            theme: materialColor
                ? lightColorTheme != null
                    ? lightMaterialTheme
                    : lightTheme(lightColor, colorSchemeLight)
                : lightTheme(lightColor, colorSchemeLight),
            darkTheme: amoledTheme
                ? materialColor
                    ? darkColorTheme != null
                        ? darkMaterialThemeOled
                        : darkTheme(oledColor, colorSchemeDark)
                    : darkTheme(oledColor, colorSchemeDark)
                : materialColor
                    ? darkColorTheme != null
                        ? darkMaterialTheme
                        : darkTheme(darkColor, colorSchemeDark)
                    : darkTheme(darkColor, colorSchemeDark),
            themeMode: themeController,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: locale,
            fallbackLocale: const Locale('en', 'US'),
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('fr', 'FR'),
            ],
            debugShowCheckedModeBanner: false,
            initialRoute: FirebaseAuth.instance.currentUser == null
                ? '/sign-in'
                : '/home',
            routes: {
              '/sign-in': (context) {
                return SignInScreen(
                  providers: providers,
                  actions: [
                    AuthStateChangeAction<SignedIn>((context, state) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }),
                  ],
                );
              },
              '/home': (context) {
                return const HomePage();
              },
            },
            builder: EasyLoading.init(),
            title: 'TaskManager',
          );
        },
      ),
    );
  }
}
