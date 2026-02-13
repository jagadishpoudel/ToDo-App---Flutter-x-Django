import 'package:flutter/material.dart';
import 'package:flutter_app_django/screens/get_page.dart';
import 'package:flutter_app_django/screens/post_page.dart';

class Skeleton extends StatefulWidget {
  final String token;
  final Function onLogout;

  const Skeleton({
    super.key,
    required this.token,
    required this.onLogout,
  });

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> {
  int currentIndex = 0;

  late List pages;

  @override
  void initState() {
    super.initState();
    pages = [
      GetPage(token: widget.token),
      PostPage(token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills Todo App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onLogout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "My Skills"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add Skill"),
        ],
      ),
    );
  }
}