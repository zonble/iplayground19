import 'package:bloc/bloc.dart';
import 'package:iplayground19/api/api.dart';
import 'package:iplayground19/bloc/data_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationBlocEvent {}

class NotificationBlocLoadEvent extends NotificationBlocEvent {}

/// Adds a notification for the given session.
class NotificationBlocAddEvent extends NotificationBlocEvent {
  /// The ID of the desired session.
  String sessionId;

  /// Creates a new instance.
  NotificationBlocAddEvent(this.sessionId);
}

/// Remove a notification for the given session.
class NotificationBlocRemoveEvent extends NotificationBlocEvent {
  /// The ID of the desired session.
  String sessionId;

  /// Creates a new instance.
  NotificationBlocRemoveEvent(this.sessionId);
}

class NotificationBlocState {}

class NotificationBlocInitialState extends NotificationBlocState {}

class NotificationBlocLoadedState extends NotificationBlocState {
  List<String> sessions;

  NotificationBlocLoadedState(this.sessions);

  bool has(String sessionId) => sessions.contains(sessionId);
}

class NotificationBloc
    extends Bloc<NotificationBlocEvent, NotificationBlocState> {
  DataBloc dataBloc;
  NotificationHelper helper;

  NotificationBloc({this.dataBloc});

  @override
  NotificationBlocState get initialState => NotificationBlocInitialState();

  Future<List<String>> _loadSessions() async {
    final instance = await SharedPreferences.getInstance();
    return instance.getStringList("notifications") ?? <String>[];
  }

  Future<void> _scheduleNotifications() async {
    if (dataBloc == null) {
      return;
    }
    final dataState = dataBloc.currentState;
    final notificationState = this.currentState;
    if (dataState is DataBlocLoadedState &&
        notificationState is NotificationBlocLoadedState) {
      if (helper == null) {
        helper = NotificationHelper();
      }
      helper.cancelAll();

      final sessions = dataState.sessions;
      final savedSessions = notificationState.sessions;
      for (final sessionId in savedSessions) {
        final session = sessions[sessionId];
        if (session == null) continue;
        helper.scheduleNotification(session);
      }
    }
  }

  Future<void> _saveSessions() async {
    final state = this.currentState;
    if (state is NotificationBlocLoadedState) {
      final instance = await SharedPreferences.getInstance();
      instance.setStringList("notifications", state.sessions);
    }
  }

  Future<List<String>> _getSessions() async {
    final state = currentState;
    return state is NotificationBlocLoadedState
        ? state.sessions
        : await _loadSessions();
  }

  @override
  Stream<NotificationBlocState> mapEventToState(
      NotificationBlocEvent event) async* {
    if (event is NotificationBlocLoadEvent) {
      final sessions = await _loadSessions();
      yield NotificationBlocLoadedState(sessions);
    }

    if (event is NotificationBlocAddEvent) {
      var sessions = await _getSessions();
      sessions.add(event.sessionId);
      final state = NotificationBlocLoadedState(sessions);
      yield state;
      await _saveSessions();
      await _scheduleNotifications();
    }

    if (event is NotificationBlocRemoveEvent) {
      var sessions = await _getSessions();
      sessions.remove(event.sessionId);
      final state = NotificationBlocLoadedState(sessions);
      yield state;
      await _saveSessions();
      await _scheduleNotifications();
    }
  }
}

class NotificationHelper {
  FlutterLocalNotificationsPlugin _plugin;

  NotificationHelper() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) {
      return null;
    });
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) {
      return null;
    });
    _plugin = flutterLocalNotificationsPlugin;
  }

  static DateTime getSessionTime(Session session) {
    final day = session.conferenceDay;
    final startTime = session.startTime;
    return getTime(day, startTime);
  }

  static DateTime getTime(int day, String startTime) {
    final components = startTime.split(":");
    final hour = int.parse(components[0]);
    final minute = int.parse(components[1]);

    DateTime dateTime = DateTime.utc(2019, 9, 20 + day, hour, minute);
    // Taiwan is at UTC + 8
    DateTime taiwanTime = dateTime.subtract(Duration(hours: 8));
    return taiwanTime.subtract(Duration(minutes: 10));
  }

  void cancelAll() {
    _plugin.cancelAll();
  }

  void scheduleNotification(Session session) async {
    var scheduledNotificationDateTime = getSessionTime(session);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'notifications',
      'Notifications',
      'Notifications from iPlayground',
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    var title = session.title;
    var body = "議程將在 ${session.startTime} 於 ${session.roomName} 開始";

    await _plugin.schedule(
      0,
      title,
      body,
      scheduledNotificationDateTime,
      platformChannelSpecifics,
    );
  }
}
