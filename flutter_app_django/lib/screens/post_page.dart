import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_django/model/parse_skills.dart';
import 'package:flutter_app_django/model/skills_model.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final Dio dio = Dio();

  Future<Map<String, dynamic>> postRequest(String number) async {
    final response = await dio.post(
      'http://127.0.0.1:8000/skills/api/',
      data: {'number': number},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> postNewSkill(String name, String skills) async {
    final response = await dio.post(
      'http://127.0.0.1:8000/skills/api/',
      data: {'name': name, 'skill': skills},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    return response.data;
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController skillsController = TextEditingController();

  String skillNumber = '1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Skill")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: postRequest(skillNumber),
        builder:
            (
              BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                print("Error posting data: ${snapshot.error}");
                return Center(
                  child: Text("Error posting data: ${snapshot.error}"),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No data available"));
              } else {
                Map<String, dynamic> data = snapshot.data!;
                MySkills skill = parseSkills(data['skill'], skillNumber);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(skill.name, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 20),
                  
                      ElevatedButton(
                        onPressed: () async{
                          skillNumber = (Random().nextInt(151) + 1).toString();
                          await postRequest(skillNumber);
                          setState(() {});
                        },
                        child: const Text("Randomize"),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Enter name",
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: skillsController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Enter skills",
                        ),
                      ),
                      SizedBox(height: 20),
                      FilledButton(onPressed: () async {
                        String name = nameController.text;
                        String skillsText = skillsController.text;
                        
                        if (name.isEmpty || skillsText.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all fields')),
                          );
                          return;
                        }
                        
                        await postNewSkill(name, skillsText);
                        nameController.clear();
                        skillsController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Skill posted successfully!')),
                        );
                      }, child: const Text("Post Skill"))
                      // ElevatedButton(
                      //   onPressed: () {
                      //     setState(() {
                      //       skillNumber = fieldController.text;
                      //     });
                      //   },
                      //   child: const Text("Post Skill"),
                      // ),
                    ],
                  ),
                );
              }
            },
      ),
    );
  }
}
