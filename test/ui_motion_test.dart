import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/ui/house/parts.dart';

double _scaleOf(WidgetTester tester) {
  final t = tester.widget<Transform>(find.descendant(of: find.byType(Squish), matching: find.byType(Transform)).first);
  return t.transform.entry(0, 0); // x scale (getMaxScaleOnAxis includes z = 1)
}

void main() {
  testWidgets('Squish sinks while pressed and springs back past rest', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Center(child: Squish(child: GestureDetector(onTap: () => taps++, child: const SizedBox(width: 80, height: 80, child: ColoredBox(color: Colors.pink))))),
    ));
    final g = await tester.startGesture(tester.getCenter(find.byType(ColoredBox).last));
    await tester.pump(); // the spring's clock starts on the first frame
    await tester.pump(const Duration(milliseconds: 120));
    expect(_scaleOf(tester), lessThan(0.95), reason: 'sinks under the finger');
    await g.up();
    var peak = 0.0;
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      peak = peak < _scaleOf(tester) ? _scaleOf(tester) : peak;
    }
    expect(peak, greaterThan(1.0), reason: 'a little overshoot on release');
    await tester.pump(const Duration(milliseconds: 800));
    expect(_scaleOf(tester), closeTo(1, 0.01));
    expect(taps, 1, reason: 'the tap still reaches the child');
  });

  testWidgets('StarTag counts up to the new total and settles', (tester) async {
    Widget tag(int n) => MaterialApp(home: Center(child: StarTag(count: n, label: 'stars')));
    await tester.pumpWidget(tag(120));
    expect(find.text('120'), findsOneWidget);
    await tester.pumpWidget(tag(126));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final mid = int.parse(tester.widget<Text>(find.byType(Text)).data!);
    expect(mid, inExclusiveRange(120, 126), reason: 'mid-count');
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('126'), findsOneWidget);
  });
}
