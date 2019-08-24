import 'package:flutter_test/flutter_test.dart';
import 'package:iplayground19/data_bloc.dart';
import 'package:matcher/matcher.dart';

void main() {
  test("Test Bloc", () async {
    final bloc = DataBloc();
    bloc.dispatch(DataBlocEvent.load);
    expectLater(
        bloc.state,
        emitsInOrder([
          TypeMatcher<DataBlocInitialState>(),
          TypeMatcher<DataBlocLoadingState>(),
          TypeMatcher<DataBlocLoadedState>(),
        ]));
  });
}
