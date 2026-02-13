import 'package:flutter_app_django/model/skills_model.dart';

// List<MySkills> parseSkills(Map<String, dynamic> skillJson, String skillNumber) {
//   List<MySkills> skills = [];
  
//   skillJson.forEach((key, value){
//     skills.add(MySkills.fromJson(
//       {
//         'id': key,
//         'name': value['name'],
//         'skill': value['skill'],
//       }
//     ));
//   });

//   return skills;
// }

MySkills parseSkills(Map<String, dynamic>? skillJson, String id) {
  if (skillJson == null) {
    return MySkills(id: id, name: id, skill: 'error');
  }
  return MySkills.fromJson({
    'id': id,
    'name': skillJson['name'],
    'skill': skillJson['skill'],
  });
}