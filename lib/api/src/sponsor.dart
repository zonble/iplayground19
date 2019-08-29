import 'dart:convert';

import 'package:http/http.dart' as http;

class Sponsor {
  String name;
  String imageUrl;
  String description;

  Sponsor(Map map) {
    name = map['name'];
    imageUrl = map['picture'];
    description = map['desc'];
  }

  Map toJson() => {
        'name': name,
        'picture': imageUrl,
        'desc': description,
      };
}

class Sponsors {
  List<Sponsor> diamond;
  List<Sponsor> gold;
  List<Sponsor> silver;
  List<Sponsor> bronze;

  List<Sponsor> convert(List list) =>
      List.from(list.cast<Map>().map((x) => Sponsor(x)));

  Sponsors(Map map) {
    diamond = convert(map['diamond']);
    gold = convert(map['gold']);
    silver = convert(map['silver']);
    bronze = convert(map['bronze']);
  }

  List<Map> convertSpeakersToList(List<Sponsor> list) =>
      List<Map>.of(list.map((x) => x.toJson()));

  Map toJson() {
    var map = Map();
    map['diamond'] = convertSpeakersToList(diamond);
    map['gold'] = convertSpeakersToList(gold);
    map['silver'] = convertSpeakersToList(silver);
    map['bronze'] = convertSpeakersToList(bronze);
    return map;
  }
}

/// Fetches sponsors.
Future<Sponsors> fetchSponsors() async {
  final response = await http.get(
      'https://raw.githubusercontent.com/iplayground/SessionData/master/sponsors.json');
  final map = json.decode(response.body);
  return Sponsors(map['sponsors']);
}
