import 'package:flutter/material.dart';
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            ); // Return to previous screen (home screen)
          },
        ),
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('profile')
              .doc('username')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              DocumentSnapshot document = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: document['profilePicture'] != null
                            ? NetworkImage(document['profilePicture'])
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: document['profilePicture'] == null
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
                    document['username'],
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
