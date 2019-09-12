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

class SponsorSection {
  List<Sponsor> sponsors;
  String title;

  SponsorSection(Map map) {
    title = map['title'];
    List list = map['items'];
    sponsors = List<Sponsor>.from(list.cast<Map>().map((x) => Sponsor(x)));
  }

  Map toJson() {
    Map map = {};
    map['title'] = title;
    map['items'] = List<Map>.from(sponsors.map((x) => x.toJson()));
    return map;
  }
}

class Partner {
  String name;
  String iconUrl;
  String link;

  Partner(Map map) {
    name = map['name'];
    iconUrl = map['icon'];
    link = map['link'];
  }

  Map toJson() => {
        'name': name,
        'icon': iconUrl,
        'link': link,
      };
}

class Sponsors {
  List<SponsorSection> sections;
  List<Partner> partners;

  Sponsors(Map map) {
    List sponsorList = map['sponsors'];
    sections = List.from(sponsorList.map((x) => SponsorSection(x)));
    List partnerList = map['partner'];
    partners = List.from(partnerList.map((x) => Partner(x)));
  }

  List<Map> convertSpeakersToList(List<Sponsor> list) =>
      List<Map>.of(list.map((x) => x.toJson()));

  Map toJson() {
    var map = Map();
    map['sponsors'] = List<Map>.from(sections.map((x) => x.toJson()));
    map['partner'] = List<Map>.from(partners.map((x) => x.toJson()));
    return map;
  }
}

/// Fetches sponsors and partners.
Future<Sponsors> fetchSponsors() async {
  final response = await http.get(
      'https://raw.githubusercontent.com/iplayground/SessionData/2019/v2/sponsors.json');
  final map = json.decode(response.body);
  return Sponsors(map);
}
