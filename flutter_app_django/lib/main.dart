import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app_django/skeleton.dart';
import 'package:flutter_app_django/screens/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    const storage = FlutterSecureStorage();
    final savedToken = await storage.read(key: 'auth_token');
    setState(() {
      token = savedToken;
      isLoading = false;
    });
  }

  void _setToken(String newToken) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'auth_token', value: newToken);
    setState(() => token = newToken);
  }

  void _logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    setState(() => token = null);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Skills Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: token == null
          ? LoginPage(
              onLoginSuccess: _setToken,
            )
          : Skeleton(
              token: token!,
              onLogout: _logout,
            ),
    );
  }
}
