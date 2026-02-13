import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_django/model/parse_skills.dart';
import 'package:flutter_app_django/model/skills_model.dart';

class GetPage extends StatefulWidget {
  const GetPage({super.key});

  @override
  State<GetPage> createState() => _GetPageState();
}

class _GetPageState extends State<GetPage> {
  final Dio dio = Dio();

  Future<Map<String, dynamic>> getRequest() async {
    final response = await dio.get('http://127.0.0.1:8000/skills/api/');
    return response.data;
  }

  Future<void> deleteSkill(int skillId) async {
    try {
      await dio.delete('http://127.0.0.1:8000/skills/api/$skillId/delete/');
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting skill: $e')),
      );
    }
  }

  void editSkill(int skillId, String currentName, String currentSkill) {
    TextEditingController nameController =
        TextEditingController(text: currentName);
    TextEditingController skillController =
        TextEditingController(text: currentSkill);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: skillController,
              decoration: const InputDecoration(
                labelText: 'Skills',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await dio.put(
                  'http://127.0.0.1:8000/skills/api/$skillId/',
                  data: {
                    'name': nameController.text,
                    'skill': skillController.text,
                  },
                );
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Skill updated successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating skill: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Skills")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getRequest(),
        builder:
            (
              BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                print("Error fetching data: ${snapshot.error}");
                return Center(child: Text("Error fetching data: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No data available"));
              } else {
                Map<String, dynamic> data = snapshot.data!;
                List<MySkills> skills = [];
                List<int> skillIds = [];
                data.forEach((key, value) {
                  skills.add(parseSkills(value, key));
                  if (value is Map && value['id'] != null) {
                    skillIds.add(value['id']);
                  }
                });
                return ListView.builder(
                  itemCount: skills.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(skills.elementAt(index).name),
                        subtitle: Text(skills.elementAt(index).skill),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  editSkill(
                                    skillIds[index],
                                    skills.elementAt(index).name,
                                    skills.elementAt(index).skill,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Skill'),
                                      content: const Text(
                                        'Are you sure you want to delete this skill?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            deleteSkill(skillIds[index]);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
      ),
    );
  }
}
