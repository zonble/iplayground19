import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iplayground19/bloc/notification.dart';
import 'package:matcher/matcher.dart';

main() {
  List<MethodCall> log = [];
  setUp(() {
    log = [];
    MethodChannel channel =
        MethodChannel('plugins.flutter.io/shared_preferences');
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'getAll') {
        return Map<String, Object>();
      }
      return null;
    });
  });

  test("test notification bloc", () async {
    NotificationBloc bloc = NotificationBloc(dataBloc: null);
    bloc.dispatch(NotificationBlocLoadEvent());
    expectLater(
        bloc.state,
        emitsInOrder([
          TypeMatcher<NotificationBlocInitialState>(),
          TypeMatcher<NotificationBlocLoadedState>(),
        ]));
  });

  test("test notification bloc", () async {
    NotificationBloc bloc = NotificationBloc(dataBloc: null);
    bloc.dispatch(NotificationBlocLoadEvent());
    bloc.dispatch(NotificationBlocAddEvent('123'));
    bloc.dispatch(NotificationBlocRemoveEvent('123'));
    await expectLater(
        bloc.state,
        emitsInOrder([
          TypeMatcher<NotificationBlocInitialState>(),
          TypeMatcher<NotificationBlocLoadedState>(),
          TypeMatcher<NotificationBlocLoadedState>(),
          TypeMatcher<NotificationBlocLoadedState>(),
        ]));
    expect(log[0].arguments['value'][0] == '123', isTrue);
    expect(log[1].arguments['value'].isEmpty, isTrue);
  });
}
