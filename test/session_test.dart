import 'package:flutter_test/flutter_test.dart';
import 'package:iplayground19/api/api.dart';

main() {
  test("Test session", () {
    var a = Session({"session_id": 123});
    var b = Session({"session_id": 123});
    expect(a.compareTo(b) == 0, isTrue);
  });

  test("Test session", () {
    var a = Session({"session_id": 123, "conference_day": 1});
    var b = Session({"session_id": 234, "conference_day": 2});
    expect(a.compareTo(b) == -1, isTrue);
  });

  test("Test session", () {
    var a = Session({
      "session_id": 123,
      "conference_day": 1,
      "start_time": "10:00",
    });
    var b = Session({
      "session_id": 234,
      "conference_day": 1,
      "start_time": "11:00",
    });
    expect(a.compareTo(b) == -1, isTrue);
  });

  test("Test session", () {
    var a = Session({
      "session_id": 123,
      "conference_day": 1,
      "start_time": "10:00",
      "room_name": "103",
    });
    var b = Session({
      "session_id": 234,
      "conference_day": 1,
      "start_time": "10:00",
      "room_name": "104",
    });
    expect(a.compareTo(b) == -1, isTrue);
  });
}
