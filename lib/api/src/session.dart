import 'dart:convert';

import 'package:http/http.dart' as http;

class Session {
  int conferenceDay;
  String startTime;
  String endTime;
  int sessionId;
  String proposalId;
  String title;
  String presenter;
  String roomName;
  String trackName;
  String description;

  Session(Map map) {
    conferenceDay = map['conference_day'];
    startTime = map['start_time'];
    endTime = map['end_time'];
    sessionId = map['session_id'];
    proposalId = map['proposal_id'];
    title = map['title'];
    presenter = map['presenter'];
    roomName = map['room_name'];
    trackName = map['track_name'];
    description = map['desc'];
  }
}

Future<List<Session>> fetchSessions() async {
  final response = await http.get(
      'https://raw.githubusercontent.com/iplayground/2019app/master/data/sessions.json');
  final map = json.decode(response.body);
  List list = map['sessions'];
  return List.from(list.cast<Map>().map((x) => (Session(x))));
}
