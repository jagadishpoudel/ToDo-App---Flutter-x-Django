import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_django/screens/register_page.dart';

class LoginPage extends StatefulWidget {
  final Function(String) onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Dio dio;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    dio = Dio();
    dio.options.validateStatus = (status) => true; // Don't throw on any status
  }

  String _getErrorMessage(dynamic error) {
    try {
      if (error is DioException && error.response != null) {
        final data = error.response!.data;
        print('Error data type: ${data.runtimeType}, value: $data');
        
        if (data is Map) {
          // Check all possible error field locations
          for (final key in ['error', 'username', 'password', 'non_field_errors']) {
            if (data.containsKey(key)) {
              final fieldError = data[key];
              if (fieldError is List && fieldError.isNotEmpty) {
                return fieldError.first.toString();
              } else if (fieldError is String) {
                return fieldError;
              }
            }
          }
          // If no specific field found, check the first key-value pair
          if (data.isNotEmpty) {
            final firstEntry = data.entries.first;
            if (firstEntry.value is List && (firstEntry.value as List).isNotEmpty) {
              return (firstEntry.value as List).first.toString();
            }
            return firstEntry.value.toString();
          }
        }
      }
    } catch (e) {
      print('Error parsing error: $e');
    }
    return error.toString();
  }

  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await dio.post(
        'http://127.0.0.1:8000/auth/login/',
        data: {
          'username': usernameController.text,
          'password': passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        widget.onLoginSuccess(token);
      } else {
        final errorMsg = _getErrorMessage(response);
        print('Login error: $errorMsg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $errorMsg')),
        );
      }
    } on DioException catch (e) {
      final errorMsg = _getErrorMessage(e);
      print('Login error: $errorMsg');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $errorMsg')),
      );
    } catch (e) {
      print('Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage(onRegisterSuccess: (String token) {
                    widget.onLoginSuccess(token);
                  }))),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
