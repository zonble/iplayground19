import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:iplayground19/api/api.dart';

enum DataBlocEvent { load, refresh }

class DataBlocState {}

class DataBlocInitialState extends DataBlocState {}

class DataBlocLoadingState extends DataBlocState {}

class DataBlocLoadedState extends DataBlocState {
  Sponsors sponsors;
  Map<String, Session> sessions;
  Map<String, Program> programs;
  List<Section> day1;
  List<Section> day2;

  DataBlocLoadedState({
    @required this.sponsors,
    @required this.sessions,
    @required this.programs,
    @required this.day1,
    @required this.day2,
  });
}

class DataBlocErrorState extends DataBlocState {
  var error;

  DataBlocErrorState(this.error);
}

class Section {
  String title;
  List<Session> sessions;

  Section({
    @required this.title,
    @required this.sessions,
  });
}

class DataBloc extends Bloc<DataBlocEvent, DataBlocState> {
  @override
  DataBlocState get initialState => DataBlocInitialState();

  @override
  Stream<DataBlocState> mapEventToState(DataBlocEvent event) async* {
    if (currentState is DataBlocLoadingState) {
      return;
    }

    if (currentState is DataBlocLoadedState && event == DataBlocEvent.refresh) {
      return;
    }

    yield DataBlocLoadingState();
    try {
      final sponsors = await fetchSponsors();
      final programs = await fetchPrograms();
      final sessions = await fetchSessions();
      Map<String, Session> sessionMap = reshapeSessions(sessions);
      Map<String, Program> programMap = reshapePrograms(programs);
      List<List<Section>> days = reshapeSessionsToDays(sessions);
      yield DataBlocLoadedState(
        day1: days[0],
        day2: days[1],
        sponsors: sponsors,
        programs: programMap,
        sessions: sessionMap,
      );
    } catch (e) {
      yield DataBlocErrorState(e);
    }
  }

  List<Section> convert(Map<String, List<Session>> dayMap) {
    List<Section> sections = [];
    for (final key in dayMap.keys) {
      var sessions = dayMap[key];
      sessions.sort((a, b) => a.roomName.compareTo(b.roomName));
      final section = Section(
        title: key,
        sessions: dayMap[key],
      );
      sections.add(section);
    }
    sections.sort((a, b) => a.title.compareTo(b.title));
    return sections;
  }

  List<List<Section>> reshapeSessionsToDays(List<Session> sessions) {
    var day1Map = Map<String, List<Session>>();
    var day2Map = Map<String, List<Session>>();

    for (final session in sessions) {
      final startTime = session.startTime;
      final day = session.conferenceDay;
      if (day == 1) {
        List<Session> list = day1Map[startTime];
        if (list == null) {
          list = [session];
          day1Map[startTime] = list;
        } else {
          list.add(session);
        }
      } else if (day == 2) {
        List<Session> list = day2Map[startTime];
        if (list == null) {
          list = [session];
          day2Map[startTime] = list;
        } else {
          list.add(session);
        }
      }
    }
    return [
      convert(day1Map),
      convert(day2Map),
    ];
  }

  Map<String, Session> reshapeSessions(List<Session> list) {
    var map = Map<String, Session>();
    for (var session in list) {
      map["${session.sessionId}"] = session;
    }
    return map;
  }

  Map<String, Program> reshapePrograms(List<Program> list) {
    var map = Map<String, Program>();
    for (var program in list) {
      map["${program.id}"] = program;
    }
    return map;
  }
}
