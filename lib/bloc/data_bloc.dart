import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:iplayground19/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  Sponsors sponsors;
  List<Program> programs;
  List<Session> sessions;

  Cache({
    @required this.sponsors,
    @required this.programs,
    @required this.sessions,
  });
}

class CacheRepository {
  Future<Cache> load() async {
    final instance = await SharedPreferences.getInstance();
    Sponsors sponsors = () {
      final sponsorsJson = instance.getString('sponsors');
      if (sponsorsJson == null) return null;
      final Map sponsorsMap = json.decode(sponsorsJson);
      return Sponsors(sponsorsMap);
    }();

    List<Program> programs = () {
      final programsJson = instance.getString('programs');
      if (programsJson == null) return null;
      final List programMapList = json.decode(programsJson);
      return List<Program>.from(programMapList.map((x) => Program(x)));
    }();

    List<Session> sessions = () {
      final sessionsJson = instance.getString('sessions');
      if (sessionsJson == null) return null;
      final List sessionsMapList = json.decode(sessionsJson);
      return List<Session>.from(sessionsMapList.map((x) => Session(x)));
    }();

    if (sponsors != null && programs != null && sessions != null) {
      return Cache(
        sponsors: sponsors,
        programs: programs,
        sessions: sessions,
      );
    }
    return null;
  }

  save(Cache cache) async {
    final instance = await SharedPreferences.getInstance();
    instance.setString('sponsors', json.encode(cache.sponsors));
    instance.setString('programs',
        json.encode(cache.programs.map((x) => x.toJson()).toList()));
    instance.setString('sessions',
        json.encode(cache.sessions.map((x) => x.toJson()).toList()));
  }
}

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
  CacheRepository cacheRepo = CacheRepository();

  @override
  DataBlocState get initialState => DataBlocInitialState();

  @override
  Stream<DataBlocState> mapEventToState(DataBlocEvent event) async* {
    if (currentState is DataBlocLoadingState) {
      return;
    }

    if (currentState is DataBlocLoadedState && event == DataBlocEvent.load) {
      return;
    }

    try {
      if (event == DataBlocEvent.load) {
        Cache cache = await cacheRepo.load();
        if (cache != null) {
          final sponsors = cache.sponsors;
          final programs = cache.programs;
          final sessions = cache.sessions;
          yield generateState(
            sessions: sessions,
            programs: programs,
            sponsors: sponsors,
          );
          return;
        }
      }

      yield DataBlocLoadingState();

      final sponsors = await fetchSponsors();
      final programs = await fetchPrograms();
      final sessions = await fetchSessions();
      yield generateState(
        sessions: sessions,
        programs: programs,
        sponsors: sponsors,
      );
      cacheRepo.save(
          Cache(sponsors: sponsors, programs: programs, sessions: sessions));
    } catch (e) {
      print(e);
      if (currentState is DataBlocLoadedState) {
        return;
      }
      yield DataBlocErrorState(e);
    }
  }

  DataBlocLoadedState generateState(
      {List<Session> sessions, List<Program> programs, Sponsors sponsors}) {
    Map<String, Session> sessionMap = reshapeSessions(sessions);
    Map<String, Program> programMap = reshapePrograms(programs);
    List<List<Section>> days = reshapeSessionsToDays(sessions);
    return DataBlocLoadedState(
      day1: days[0],
      day2: days[1],
      sponsors: sponsors,
      programs: programMap,
      sessions: sessionMap,
    );
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
