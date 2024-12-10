import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  Future<void> _login() async {
    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Make the HTTP POST request
      final response = await http.post(
        Uri.parse('http://192.168.1.8/smapp/php/login.php'),
        body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      setState(() {
        _isLoading = false; // Hide loading state
      });

      // Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final userId = int.tryParse(data['user_id'].toString());
          if (userId != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setInt('userId', userId);

            // Navigate to HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(userId: userId)),
            );
          } else {
            _showErrorDialog('Invalid user ID returned from the server.');
          }
        } else {
          _showErrorDialog(data['message']);
        }
      } else {
        _showErrorDialog('An error occurred. Please try again later.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Hide loading state
      });
      _showErrorDialog(
          'An error occurred. Please check your internet connection.');
    }
  }

  // Future<void> _login() async {
  //   if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
  //     _showErrorDialog("Please fill in all fields.");
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://192.168.1.8/smapp/php/login.php'),
  //       body: {
  //         'email': _emailController.text.trim(),
  //         'password': _passwordController.text,
  //       },
  //     );

  //     setState(() {
  //       _isLoading = false;
  //     });

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);

  //       if (data['status'] == 'success') {
  //         final int? loggedInUserId = data['user_id'] != null
  //             ? int.tryParse(data['user_id'].toString())
  //             : null;

  //         if (loggedInUserId != null) {
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => HomePage(userId: loggedInUserId),
  //             ),
  //           );
  //         } else {
  //           _showErrorDialog('Invalid user ID returned from the server.');
  //         }
  //       } else {
  //         _showErrorDialog(data['message']);
  //       }
  //     } else {
  //       _showErrorDialog('Server error. Please try again later.');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     _showErrorDialog('An error occurred. Check your internet connection.');
  //   }
  // }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
            vertical: screenHeight * 0.2,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 0, 0, 0),
                Color.fromARGB(255, 255, 255, 255),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.1),
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Login to your account',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: screenHeight * 0.04),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      _isLoading
                          ? CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.02,
                                  ),
                                ),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text(
                  'Don\'t have an account? Register',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
