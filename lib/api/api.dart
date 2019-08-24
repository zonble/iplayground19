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
}

Future<Sponsors> fetchSponsors() async {
  final response = await http.get(
      'https://raw.githubusercontent.com/zonble/iplayground19/master/data/sponsors.json');
  final map = json.decode(response.body);
  return Sponsors(map['sponsors']);
}
