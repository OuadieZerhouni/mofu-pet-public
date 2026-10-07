import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/l10n/app_localizations.dart';

/// Arabic is a main market: its six plural categories must resolve to real
/// Arabic grammar, not fall back to `other`. (RTL layout of the whole app is
/// exercised in app_smoke_test.dart.)
void main() {
  test('Arabic plurals resolve per category', () async {
    final l = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(l.daysTogether(1), 'اليوم الأول معًا');
    expect(l.daysTogether(2), 'اليوم الثاني معًا');
    expect(l.lockedDays(2), 'زُر في يومين');
    expect(l.lockedDays(5), 'زُر في 5 أيام');
    expect(l.lockedDays(11), 'زُر في 11 يومًا');
    expect(l.lockedJournal(1), 'اكتشف ردة فعل واحدة');
  });

  test('English plurals still read naturally', () async {
    final l = await AppLocalizations.delegate.load(const Locale('en'));
    expect(l.daysTogether(1), 'Day 1 together');
    expect(l.daysTogether(12), 'Day 12 together');
    expect(l.lockedSnacks(1), 'Share 1 snack');
    expect(l.lockedSnacks(15), 'Share 15 snacks');
  });
}
