import 'package:b_bot/controllers/user_control/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/app_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final appPreferences = AppPreferences(prefs);
  await appPreferences.initDefaults();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(appPreferences: appPreferences));
}

class MyApp extends StatefulWidget {
  final AppPreferences appPreferences;

  const MyApp({required this.appPreferences, super.key});

  static MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MyAppState>();
  }

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void updateThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = widget.appPreferences.getThemeMode();
    setState(() {
      _themeMode = themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B-BOT',
      themeMode: _themeMode,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      initialRoute: "auth",
      routes: {
        'auth': (context) => const AuthWrapper(),
      },
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      primarySwatch: Colors.purple,
      primaryColor: Colors.purple,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.black87, fontSize: 57),
        displayMedium: TextStyle(color: Colors.black87, fontSize: 45),
        displaySmall: TextStyle(color: Colors.black87, fontSize: 36),
        headlineLarge: TextStyle(color: Colors.black87, fontSize: 32),
        headlineMedium: TextStyle(color: Colors.black87, fontSize: 28),
        headlineSmall: TextStyle(color: Colors.black87, fontSize: 24),
        titleLarge: TextStyle(color: Colors.black87, fontSize: 22),
        titleMedium: TextStyle(color: Colors.black87, fontSize: 16),
        titleSmall: TextStyle(color: Colors.black87, fontSize: 14),
        bodyLarge: TextStyle(color: Colors.black87, fontSize: 20),
        bodyMedium: TextStyle(color: Colors.black87, fontSize: 18),
        bodySmall: TextStyle(color: Colors.black87, fontSize: 15),
        labelLarge: TextStyle(color: Colors.black87, fontSize: 14),
        labelMedium: TextStyle(color: Colors.black87, fontSize: 12),
        labelSmall: TextStyle(color: Colors.black87, fontSize: 10),
      ),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white70,
      dialogBackgroundColor: Colors.white,
      dividerColor: Colors.grey[300],
      splashColor: Colors.purpleAccent[100],
      iconTheme: const IconThemeData(color: Colors.black87),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.purple),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          textStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.purple,
        textTheme: ButtonTextTheme.primary,
      ),
      colorScheme: ColorScheme.light(
        primary: Colors.purple,
        secondary: Colors.purple[700]!,
        surface: Colors.white,
        tertiary: Colors.grey[600]!,
        error: Colors.red[700]!,
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      primarySwatch: Colors.purple,
      primaryColor: Colors.purple[300],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.purple[300],
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white70, fontSize: 57),
        displayMedium: TextStyle(color: Colors.white70, fontSize: 45),
        displaySmall: TextStyle(color: Colors.white70, fontSize: 36),
        headlineLarge: TextStyle(color: Colors.white70, fontSize: 32),
        headlineMedium: TextStyle(color: Colors.white70, fontSize: 28),
        headlineSmall: TextStyle(color: Colors.white70, fontSize: 24),
        titleLarge: TextStyle(color: Colors.white70, fontSize: 22),
        titleMedium: TextStyle(color: Colors.white70, fontSize: 16),
        titleSmall: TextStyle(color: Colors.white70, fontSize: 14),
        bodyLarge: TextStyle(color: Colors.white70, fontSize: 20),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 18),
        bodySmall: TextStyle(color: Colors.white70, fontSize: 15),
        labelLarge: TextStyle(color: Colors.white70, fontSize: 14),
        labelMedium: TextStyle(color: Colors.white70, fontSize: 12),
        labelSmall: TextStyle(color: Colors.white70, fontSize: 10),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dialogBackgroundColor: const Color(0xFF1E1E1E),
      dividerColor: Colors.grey[800],
      splashColor: Colors.purpleAccent[100],

      iconTheme: const IconThemeData(color: Colors.white70),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.purple[300]),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          textStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.purple[300],
        textTheme: ButtonTextTheme.primary,
      ),
      colorScheme: ColorScheme.dark(
        primary: Colors.purple[300]!,
        secondary: Colors.purple[200]!,
        surface: const Color(0xFF1E1E1E),
        tertiary: Colors.grey[400]!,
        error: Colors.red[400]!,
      ),
    );
  }
}