import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/world/house_controller.dart';

/// SPEC F1-c2: lighting follows the clock, night is 22:00–06:00.
void main() {
  test('dayparts by hour', () {
    Daypart at(int h) => daypartFor(DateTime(2026, 10, 18, h));
    expect([for (var h = 0; h < 24; h++) at(h)], [
      for (var h = 0; h < 24; h++)
        h >= 22 || h < 6
            ? Daypart.night
            : h < 10
                ? Daypart.morning
                : h < 18
                    ? Daypart.day
                    : Daypart.evening,
    ]);
    expect(at(21), Daypart.evening);
    expect(at(22), Daypart.night);
    expect(at(5), Daypart.night);
    expect(at(6), Daypart.morning);
  });
}
