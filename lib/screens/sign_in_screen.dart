import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haidenjem/screens/home_screen.dart';
import 'package:haidenjem/screens/sign_up_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
  clientId:
  '231154984703-6jm1g98dk79o0a6a3s5uoauapr19q63e.apps.googleusercontent.com',
);

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _signInWIthGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_errorMessage),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 350,
        title: Image.asset(
          'assets/images/logo.png',
          height: 100,
          width: 500,
          fit: BoxFit.contain,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 9, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 9, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              Container(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text;
                    // Validasi email
                    if (email.isEmpty || !isValidEmail(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a valid email')),
                      );
                      return;
                    }
                    // Validasi password
                    if (password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter your password')),
                      );
                      return;
                    }
                    try {
                      // Lakukan sign in dengan email dan password
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // Jika berhasil sign in, navigasi ke halaman beranda
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    } on FirebaseAuthException catch (error) {
                      print('Error code: ${error.code}');
                      if (error.code == 'user-not-found') {
                        // Jika email tidak terdaftar, tampilkan pesan kesalahan
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No user found with that email')),
                        );
                      } else if (error.code == 'wrong-password') {
                        // Jika password salah, tampilkan pesan kesalahan
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                              Text('Wrong password. Please try again.')),
                        );
                      } else {
                        // Jika terjadi kesalahan lain, tampilkan pesan kesalahan umum
                        setState(() {
                          _errorMessage = error.message ?? 'An error occurred';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_errorMessage),
                          ),
                        );
                      }
                    } catch (error) {
                      // Tangani kesalahan lain yang tidak terkait dengan otentikasi
                      setState(() {
                        _errorMessage = error.toString();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_errorMessage),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signInWIthGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 16.0),
                      const Text(
                        'Sign In with Google',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text(
                      'Doesn\'t have an account? ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Register here!',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Fungsi untuk memeriksa validitas email
  bool isValidEmail(String email) {
    String emailRegex =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$";
    RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }
}
