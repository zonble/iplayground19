import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iplayground19/bloc/data_bloc.dart';
import 'package:iplayground19/api/api.dart';
import 'package:matcher/matcher.dart';

class DataBlocLoadedStateMatcher extends CustomMatcher {
  DataBlocLoadedStateMatcher(matcher)
      : super("DataBlocLoadedState matcher", "DataBlocLoadedState matcher",
            matcher);

  @override
  featureValueOf(item) {
    if (item is DataBlocLoadedState) {
      for (var section in item.day1) {
        var startTime = '';
        for (Session session in section.sessions) {
          if (startTime == '') {
            startTime = session.startTime;
          }
          if (session.startTime != startTime) return false;
          if (session.conferenceDay != 1) return false;
        }
      }
      for (var section in item.day2) {
        var startTime = '';
        for (Session session in section.sessions) {
          if (startTime == '') {
            startTime = session.startTime;
          }
          if (session.startTime != startTime) return false;
          if (session.conferenceDay != 2) return false;
        }
      }
      return true;
    }
    return false;
  }
}

void main() {
  setUp(() {
    final channel = MethodChannel('plugins.flutter.io/shared_preferences');
    channel.setMockMethodCallHandler((call) async {
      if (call.method == 'getAll') {
        return {};
      }
      return null;
    });
  });

  test("Test Bloc", () async {
    final bloc = DataBloc();
    bloc.dispatch(DataBlocEvent.load);
    expectLater(
        bloc.state,
        emitsInOrder([
          TypeMatcher<DataBlocInitialState>(),
          TypeMatcher<DataBlocLoadingState>(),
          DataBlocLoadedStateMatcher(isTrue),
        ]));
  });
}
