import 'package:flutter/material.dart';
import 'package:flutter_app_django/screens/get_page.dart';
import 'package:flutter_app_django/screens/post_page.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({super.key});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> {
  int currentIndex = 0;
  List pages = [
    GetPage(),
    PostPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.get_app), label: "Get"),
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: "Post"),
        ],
      ),
    );
  }
}