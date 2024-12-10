import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPostPage extends StatefulWidget {
  // final int userId;

  AddPostPage();

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _contentController = TextEditingController();
  String? _imageUrl;
  bool _isSubmitting = false;

  Future<void> _submitPost() async {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post content cannot be empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final url = Uri.parse('http://192.168.1.8/smapp/php/add_post.php');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': 1,
          'content': content,
          'image_url': _imageUrl ?? '',
        },
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Return to the previous page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while submitting the post.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Post'),
          backgroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What's on your mind?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your post here...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              if (_imageUrl != null)
                Column(
                  children: [
                    Image.network(_imageUrl!),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _imageUrl = null;
                        });
                      },
                      child: Text('Remove Image'),
                    ),
                  ],
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.image),
                      label: Text('Add Image URL'),
                      onPressed: () async {
                        final imageUrl = await _showAddImageDialog();
                        if (imageUrl != null) {
                          setState(() {
                            _imageUrl = imageUrl;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: _submitPost,
                      child: Text('Submit Post'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showAddImageDialog() async {
    final TextEditingController imageUrlController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Image URL'),
          content: TextField(
            controller: imageUrlController,
            decoration: InputDecoration(hintText: 'Enter image URL'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, imageUrlController.text.trim()),
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
