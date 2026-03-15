import 'package:bloc/bloc.dart';
import 'package:iplayground19/api/api.dart';
import 'package:iplayground19/bloc/data_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationBlocEvent {}

class NotificationBlocLoadEvent extends NotificationBlocEvent {}

/// Adds a notification for the given session.
class NotificationBlocAddEvent extends NotificationBlocEvent {
  /// The ID of the desired session.
  final String sessionId;

  /// Creates a new instance.
  NotificationBlocAddEvent(this.sessionId);
}

/// Remove a notification for the given session.
class NotificationBlocRemoveEvent extends NotificationBlocEvent {
  /// The ID of the desired session.
  final String sessionId;

  /// Creates a new instance.
  NotificationBlocRemoveEvent(this.sessionId);
}

class NotificationBlocState {}

class NotificationBlocInitialState extends NotificationBlocState {}

class NotificationBlocLoadedState extends NotificationBlocState {
  final List<String> sessions;

  NotificationBlocLoadedState(this.sessions);

  bool has(String sessionId) => sessions.contains(sessionId);
}

class NotificationBloc
    extends Bloc<NotificationBlocEvent, NotificationBlocState> {
  final DataBloc? dataBloc;
  NotificationHelper? helper;

  NotificationBloc({this.dataBloc}) : super(NotificationBlocInitialState()) {
    on<NotificationBlocEvent>((event, emit) async {
      if (event is NotificationBlocLoadEvent) {
        final sessions = await _loadSessions();
        emit(NotificationBlocLoadedState(sessions));
      }

      if (event is NotificationBlocAddEvent) {
        var sessions = await _getSessions();
        sessions.add(event.sessionId);
        final state = NotificationBlocLoadedState(sessions);
        emit(state);
        await _saveSessions();
        await _scheduleNotifications();
      }

      if (event is NotificationBlocRemoveEvent) {
        var sessions = await _getSessions();
        sessions.remove(event.sessionId);
        final state = NotificationBlocLoadedState(sessions);
        emit(state);
        await _saveSessions();
        await _scheduleNotifications();
      }
    });
  }

  Future<List<String>> _loadSessions() async {
    final instance = await SharedPreferences.getInstance();
    return instance.getStringList("notifications") ?? <String>[];
  }

  Future<void> _scheduleNotifications() async {
    if (dataBloc == null) {
      return;
    }
    final dataState = dataBloc!.state;
    final notificationState = this.state;
    if (dataState is DataBlocLoadedState &&
        notificationState is NotificationBlocLoadedState) {
      if (helper == null) {
        helper = NotificationHelper();
      }
      helper!.cancelAll();

      final sessions = dataState.sessions;
      final savedSessions = notificationState.sessions;
      for (final sessionId in savedSessions) {
        final session = sessions[sessionId];
        if (session == null) continue;
        helper!.scheduleNotification(session);
      }
    }
  }

  Future<void> _saveSessions() async {
    final state = this.state;
    if (state is NotificationBlocLoadedState) {
      final instance = await SharedPreferences.getInstance();
      instance.setStringList("notifications", state.sessions);
    }
  }

  Future<List<String>> _getSessions() async {
    final currentState = state;
    return currentState is NotificationBlocLoadedState
        ? currentState.sessions
        : await _loadSessions();
  }
}

class NotificationHelper {
  FlutterLocalNotificationsPlugin? _plugin;

  NotificationHelper() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
      return;
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
    _plugin?.cancelAll();
  }

  void scheduleNotification(Session session) async {
    var scheduledNotificationDateTime = getSessionTime(session);
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'notifications',
      'Notifications',
      channelDescription: 'Notifications from iPlayground',
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    var title = session.title;
    var body = "議程將在 ${session.startTime} 於 ${session.roomName} 開始";

    await _plugin?.zonedSchedule(
      id: 0,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
      notificationDetails: platformChannelSpecifics,
      // Use exactAllowWhileIdle to ensure notifications fire on time even
      // when the device is in Doze mode.
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
