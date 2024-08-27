import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/appwidgets/home.dart';
import 'package:task_manager/app/utils/device_info.dart';
import 'package:task_manager/firebase_options.dart';
import 'package:task_manager/theme/theme.dart';
import 'package:task_manager/theme/theme_controller.dart';
import 'package:time_machine/time_machine.dart';
import 'dart:io';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final providers = [EmailAuthProvider()];
bool amoledTheme = false;
bool materialColor = true;
String timeformat = '24';
String firstDaySelect = 'monday';
Locale locale = const Locale('fr', 'CA');

void main() async {
  final String timeZoneName;

  WidgetsFlutterBinding.ensureInitialized();
  DeviceFeature().init();

   if (Platform.isAndroid) {
    await setOptimalDisplayMode();
  }
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

Future<void> setOptimalDisplayMode() async {
  final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  final DisplayMode active = await FlutterDisplayMode.active;
  final List<DisplayMode> sameResolution = supported
      .where((DisplayMode m) =>
          m.width == active.width && m.height == active.height)
      .toList()
    ..sort((DisplayMode a, DisplayMode b) =>
        b.refreshRate.compareTo(a.refreshRate));
  final DisplayMode mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;
  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MyAppState();
}

class _MyAppState extends State<MainApp> {
  final themeController = Get.put(ThemeController());
  
  @override
  void initState() {
    amoledTheme = amoledTheme;
    materialColor = materialColor;
    timeformat = timeformat;
    firstDaySelect = firstDaySelect;
    locale = locale;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final edgeToEdgeAvailable = DeviceFeature().isEdgeToEdgeAvailable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DynamicColorBuilder(
        builder: (lightColorTheme, darkColorTheme) {
          final lightMaterialTheme = lightTheme(
              lightColorTheme?.surface, lightColorTheme, edgeToEdgeAvailable);
          final darkMaterialTheme = darkTheme(
              darkColorTheme?.surface, darkColorTheme, edgeToEdgeAvailable);
          final darkMaterialThemeOled =
              darkTheme(oledColor, darkColorTheme, edgeToEdgeAvailable);

          return GetMaterialApp(
            theme: materialColor
                ? lightColorTheme != null
                    ? lightMaterialTheme
                    : lightTheme(
                        lightColor, colorSchemeLight, edgeToEdgeAvailable)
                : lightTheme(lightColor, colorSchemeLight, edgeToEdgeAvailable),
            darkTheme: amoledTheme
                ? materialColor
                    ? darkColorTheme != null
                        ? darkMaterialThemeOled
                        : darkTheme(
                            oledColor, colorSchemeDark, edgeToEdgeAvailable)
                    : darkTheme(oledColor, colorSchemeDark, edgeToEdgeAvailable)
                : materialColor
                    ? darkColorTheme != null
                        ? darkMaterialTheme
                        : darkTheme(
                            darkColor, colorSchemeDark, edgeToEdgeAvailable)
                    : darkTheme(
                        darkColor, colorSchemeDark, edgeToEdgeAvailable),
            themeMode: themeController.theme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: locale,
            fallbackLocale: const Locale('fr', 'CA'),
            supportedLocales: const [
              Locale('en', 'CA'),
              Locale('fr', 'CA'),
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
