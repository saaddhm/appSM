import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smapp/pages/add_post.dart';
// import 'package:smapp/pages/add_post.dart';
import 'package:smapp/pages/login_page.dart';

class HomePage extends StatefulWidget {
  final int userId;

  HomePage({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _profile;
  List<dynamic> _posts = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchProfileAndPosts();

    // Set up periodic refresh
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchProfileAndPosts();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _fetchProfileAndPosts() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.8/smapp/php/get_profile_and_posts.php?user_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            _profile = data['profile'];
            _posts = data['posts'];
            _isLoading = false;
          });
        } else {
          _showErrorDialog(data['message']);
        }
      } else {
        _showErrorDialog('Failed to fetch data. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while fetching data.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: Text(
          _profile != null ? "Welcome! " + _profile!['full_name'] : 'Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Clear all saved data

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Post Input Section
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 25,
                    backgroundImage: NetworkImage(
                      _profile!['profile'] ?? 'https://via.placeholder.com/150',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPostPage(),
                          ),
                        );
                        // final int? userId = _profile!['user_id'] != null
                        //     ? int.tryParse(_profile!['user_id'].toString())
                        //     : null;
                        // final int userId = 1;
                        // if (userId != null) {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => AddPostPage(userId: userId),
                        //     ),
                        //   );
                        // } else {
                        //   _showErrorDialog(
                        //       'Invalid user ID returned from the server.');
                        // }
                      },
                      readOnly:
                          true, // Prevents typing in the TextField to focus solely on navigation
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Posts Section
            ..._posts.map((post) => _buildPost(post)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPost(Map<String, dynamic> post) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 20,
                child: Image.network(post['profile']),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['full_name'],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(post['created_at'],
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(post['content'], style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 10),
          if (post['image_url'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.network(post['image_url']),
            ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.thumb_up, color: Colors.grey),
                label: Text('Like', style: TextStyle(color: Colors.grey)),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.comment, color: Colors.grey),
                label: Text('Comment', style: TextStyle(color: Colors.grey)),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.share, color: Colors.grey),
                label: Text('Share', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
