import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haidenjem/firebase_options.dart';
import 'package:haidenjem/screens/favorite_screen.dart';
import 'package:haidenjem/screens/home_screen.dart';
import 'package:haidenjem/screens/post_screen.dart';
import 'package:haidenjem/screens/profile_screen.dart';
import 'package:haidenjem/screens/search_screen.dart';
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
                return BottomNavBar();
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

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    PostScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black // Dark mode
            : Colors.green[900], // Light mode
        selectedItemColor: Colors.lightGreenAccent,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedIndex == 0
                      ? Colors.lightGreenAccent
                      : Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedIndex == 1
                      ? Colors.lightGreenAccent
                      : Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(Icons.search),
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedIndex == 2
                      ? Colors.lightGreenAccent
                      : Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(Icons.add),
            ),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedIndex == 3
                      ? Colors.lightGreenAccent
                      : Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(Icons.favorite),
            ),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedIndex == 4
                      ? Colors.lightGreenAccent
                      : Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(Icons.person),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
