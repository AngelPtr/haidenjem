import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haidenjem/screens/sign_in_screen.dart';
import 'package:provider/provider.dart';
import 'package:haidenjem/service/theme_provider.dart';
import 'package:haidenjem/screens/home_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        //automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.dark_mode), // Add an icon to the leading side
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: Provider.of<ThemeProvider>(context).isDarkMode,
                onChanged: (value) {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleDarkMode();
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                signOut(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent, // text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // rounded corners
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12), // padding
              ),
              child: const Text('Sign Out'),
            )
          ],
        ),
      ),
    );
  }
}
