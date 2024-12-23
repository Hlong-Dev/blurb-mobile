import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Lưu JWT token vào SharedPreferences
Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('jwt_token', token);
}
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final String url =
        'https://doancoso220241205230136.azurewebsites.net/api/Accounts/SignIn';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, String> body = {
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    setState(() {
      _isLoading = true;
    });

    try {
      print('Sending request to API...');
      print('URL: $url');
      print('Headers: $headers');
      print('Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final String token = response.body;
        await saveToken(token);

        // Thêm thông báo đăng nhập thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thành công!')),
        );

        // Delay một chút trước khi chuyển màn hình
        await Future.delayed(Duration(seconds: 1));
        Navigator.pop(context);
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = responseData['message'] ?? 'Đăng nhập thất bại!';
        _showErrorDialog(errorMessage);
      }

    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Đã xảy ra lỗi khi kết nối đến server.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Spacer(),
            Image.network(
              'https://images.spiderum.com/sp-avatar/c3edf44040da11e88c56e97b1d97fbce.png',
              height: 150,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Tên đăng nhập hoặc Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _login,
              child: Text("Đăng nhập"),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: Text("Quên mật khẩu?"),
            ),
            Divider(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.apple),
              label: Text("Đăng nhập với Apple"),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.facebook),
              label: Text("Đăng nhập với Facebook"),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
