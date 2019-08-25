import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  @override
  NotificationBlocState get initialState => NotificationBlocInitialState();

  Future<List<String>> _loadSessions() async {
    final instance = await SharedPreferences.getInstance();
    return instance.getStringList("notifications") ?? <String>[];
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
      _saveSessions();
      final state = NotificationBlocLoadedState(sessions);
      yield state;
    }

    if (event is NotificationBlocRemoveEvent) {
      var sessions = await _getSessions();
      sessions.remove(event.sessionId);
      _saveSessions();
      final state = NotificationBlocLoadedState(sessions);
      yield state;
    }
  }
}
