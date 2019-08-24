import 'dart:convert';

import 'package:http/http.dart' as http;

class Speaker {
  String name;
  String biography;

  Speaker(Map map) {
    name = map['name'];
    biography = map['bio'];
  }
}

class Program {
  String title;
  String abstract;
  List<String> reviewTags;
  int id;
  String track;
  String videoUrl;
  String slideUrl;
  var customFields;
  List<Speaker> speakers;

  Program(Map map) {
    title = map['title'];
    abstract = map['abstract'];
    reviewTags = List<String>.from(map['review_tags'] ?? []);
    id = map['id'];
    track = map['track'];
    videoUrl = map['video_url'];
    slideUrl = map['slides_url'];
    customFields = map['custom_fields'];
    List speakerMapList = map['speakers'] ?? [];
    speakers = List<Speaker>.from(speakerMapList.map((x) => Speaker(x)));
  }
}

Future<List<Program>> fetchPrograms() async {
  final response = await http.get(
      'https://raw.githubusercontent.com/zonble/iplayground19/master/data/program.json');
  final map = json.decode(response.body);
  List list = map['program'];
  return List.from(list.cast<Map>().map((x) => (Program(x))));
}
