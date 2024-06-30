import 'package:flutter/material.dart';
import 'package:haidenjem/main.dart';
import 'package:haidenjem/screens/created_post.dart';
import 'package:haidenjem/screens/edit_profile.dart';
import 'package:haidenjem/screens/home_screen.dart';
import 'package:haidenjem/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userEmail = '';
  String _username = '';
  String _profilePicture = '';

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  _getUserEmail() async {
    final user = await FirebaseAuth.instance.currentUser!;
    final userEmail = user.email;

    setState(() {
      _userEmail = userEmail ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        title: const Text(
          'Profile',
          style: TextStyle(
              color: Colors.lightGreenAccent), // change the title color to red
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black // Dark mode
            : Colors.green[900], // Light mode
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: _getUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _profilePicture != ''
                            ? NetworkImage(_profilePicture)
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: _profilePicture == ''
                            ? const Icon(
                                Icons.person,
                                size: 40,
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _username,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _userEmail,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildGridItem(
                        icon: Icons.person,
                        label: 'Edit Profile',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfileScreen()),
                          ); // Navigate to Edit Profile Screen
                        },
                      ),
                      _buildGridItem(
                        icon: Icons.edit,
                        label: 'Created Post',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreatedPostScreen()),
                          ); // Navigate to Created Post Screen
                        },
                      ),
                      _buildGridItem(
                        icon: Icons.settings,
                        label: 'Settings',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsScreen()),
                          ); // Navigate to Settings Screen
                        },
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _getUserProfile() async {
    final user = await FirebaseAuth.instance.currentUser!;
    final userEmail = user.email;

    final collectionRef = FirebaseFirestore.instance.collection('profile');
    final snapshot = await collectionRef.doc(userEmail).get();

    if (snapshot.exists) {
      _username = snapshot.get('username') ?? '';
      _profilePicture = snapshot.get('profilePicture') ?? '';
    }
  }

  Widget _buildGridItem({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          Text(label),
        ],
      ),
    );
  }
}
