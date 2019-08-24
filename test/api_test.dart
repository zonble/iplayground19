import 'package:flutter_test/flutter_test.dart';
import 'package:iplayground19/api/api.dart';

main() async {
  test("Test Sponsor", () async {
    var sponsors = await fetchSponsors();
    expect(sponsors.diamond != null, isTrue);
    expect(sponsors.gold != null, isTrue);
    expect(sponsors.silver != null, isTrue);
    expect(sponsors.bronze != null, isTrue);
  });
}
