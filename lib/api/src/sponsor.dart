import 'dart:convert';

import 'package:http/http.dart' as http;

class Sponsor {
  late String name;
  late String imageUrl;
  late String description;

  Sponsor(Map map) {
    name = map['name'];
    imageUrl = map['picture'];
    description = map['desc'];
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'picture': imageUrl,
        'desc': description,
      };
}

class SponsorSection {
  late List<Sponsor> sponsors;
  late String title;

  SponsorSection(Map map) {
    title = map['title'];
    List list = map['items'];
    sponsors = List<Sponsor>.from(list.cast<Map>().map((x) => Sponsor(x)));
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['title'] = title;
    map['items'] = List<Map<String, dynamic>>.from(sponsors.map((x) => x.toJson()));
    return map;
  }
}

class Partner {
  late String name;
  late String iconUrl;
  late String link;

  Partner(Map map) {
    name = map['name'];
    iconUrl = map['icon'];
    link = map['link'];
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': iconUrl,
        'link': link,
      };
}

class Sponsors {
  late List<SponsorSection> sections;
  late List<Partner> partners;

  Sponsors(Map map) {
    List sponsorList = map['sponsors'];
    sections = List.from(sponsorList.map((x) => SponsorSection(x)));
    List partnerList = map['partner'];
    partners = List.from(partnerList.map((x) => Partner(x)));
  }

  List<Map<String, dynamic>> convertSpeakersToList(List<Sponsor> list) =>
      List<Map<String, dynamic>>.of(list.map((x) => x.toJson()));

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['sponsors'] = List<Map<String, dynamic>>.from(sections.map((x) => x.toJson()));
    map['partner'] = List<Map<String, dynamic>>.from(partners.map((x) => x.toJson()));
    return map;
  }
}

/// Fetches sponsors and partners.
Future<Sponsors> fetchSponsors() async {
  final response = await http.get(Uri.parse(
      'https://raw.githubusercontent.com/iplayground/SessionData/2019/v2/sponsors.json'));
  final map = json.decode(response.body);
  return Sponsors(map);
}
