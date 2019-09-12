import 'dart:convert';

import 'package:http/http.dart' as http;

/// Represents speakers.
class Speaker {
  /// Name of the speaker.
  String name;

  /// Biography of the speaker.
  String biography;

  /// Creates a new instance.
  Speaker(Map map) {
    name = map['name'];
    biography = map['bio'];
  }

  /// Converts to JSON.
  Map toJson() => {
        'name': name,
        'bio': biography,
      };
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

  Map toJson() {
    var map = Map();
    map['title'] = title;
    map['abstract'] = abstract;
    map['review_tags'] = reviewTags;
    map['id'] = id;
    map['track'] = track;
    map['video_url'] = videoUrl;
    map['slides_url'] = slideUrl;
    map['custom_fields'] = customFields;
    map['speakers'] = List<Map>.from(speakers.map((x) => x.toJson()));
    return map;
  }
}

/// Fetches programs.
Future<List<Program>> fetchPrograms() async {
  final response = await http.get(
      'https://raw.githubusercontent.com/iplayground/SessionData/2019/v2/program.json');
  final map = json.decode(response.body);
  List list = map['program'];
  return List.from(list.cast<Map>().map((x) => (Program(x))));
}
