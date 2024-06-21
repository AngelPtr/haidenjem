import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haidenjem/firebase_options.dart';
import 'package:haidenjem/screens/home_screen.dart';
import 'package:haidenjem/screens/sign_in_screen.dart';
import 'package:haidenjem/service/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final themeProvider = ThemeProvider();
  await themeProvider.initDarkMode();
  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HaidenJem Apps',
          theme: themeProvider.isDarkMode
              ? ThemeData(
            brightness: Brightness.dark,
            appBarTheme: AppBarTheme(),
          )
              : ThemeData(
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(),
          ),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //return NavBarScreen();
                return const HomeScreen();
              } else {
                return const SignInScreen();
              }
            },
          ),
        );
      },
    );
  }
}
