import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function(String) onRegisterSuccess;

  const RegisterPage({super.key, required this.onRegisterSuccess});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late Dio dio;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
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
          for (final key in ['error', 'username', 'email', 'password', 'non_field_errors']) {
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

  Future<void> register() async {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await dio.post(
        'http://127.0.0.1:8000/auth/register/',
        data: {
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        },
      );

      if (response.statusCode == 201) {
        final token = response.data['token'];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        widget.onRegisterSuccess(token);
      } else {
        final errorMsg = _getErrorMessage(response);
        print('Registration error: $errorMsg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $errorMsg')),
        );
      }
    } on DioException catch (e) {
      final errorMsg = _getErrorMessage(e);
      print('Registration error: $errorMsg');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $errorMsg')),
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
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              const Text(
                'Create Account',
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
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
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
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Register'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Login',
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
      ),
    );
  }
}
