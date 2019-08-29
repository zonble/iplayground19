import 'dart:convert';

import 'package:http/http.dart' as http;

class Session implements Comparable<Session> {
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
    conferenceDay = map['conference_day'] ?? 0;
    startTime = map['start_time'] ?? '';
    endTime = map['end_time'] ?? '';
    sessionId = map['session_id'] ?? '';
    proposalId = map['proposal_id'] ?? '';
    title = map['title'] ?? '';
    presenter = map['presenter'] ?? '';
    roomName = map['room_name'] ?? '';
    trackName = map['track_name'] ?? '';
    description = map['desc'] ?? '';
  }

  Map toJson() {
    var map = Map();
    map['conference_day'] = conferenceDay;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['session_id'] = sessionId;
    map['proposal_id'] = proposalId;
    map['title'] = title;
    map['presenter'] = presenter;
    map['room_name'] = roomName;
    map['track_name'] = trackName;
    map['desc'] = description;
    return map;
  }

  int compareTo(Session session) {
    if (this.sessionId == session.sessionId) {
      return 0;
    }
    if (this.conferenceDay < session.conferenceDay) {
      return -1;
    } else if (this.conferenceDay > session.conferenceDay) {
      return 1;
    }
    var result = this.startTime.compareTo(session.startTime);
    if (result != 0) return result;
    return this.roomName.compareTo(session.roomName);
  }
}

/// Fetches sessions.
Future<List<Session>> fetchSessions() async {
  final response = await http.get(
      'https://raw.githubusercontent.com/iplayground/SessionData/master/sessions.json');
  final map = json.decode(response.body);
  List list = map['sessions'];
  return List.from(list.cast<Map>().map((x) => (Session(x))));
}
