import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../../model/house_store.dart';
import '../../world/house_controller.dart';

/// What a room's overlay and shelf get from the house screen.
class RoomContext {
  RoomContext({
    required this.house,
    required this.frame,
    required this.l,
    required this.toast,
    required this.lockPaging,
    required this.goTo,
    required this.openFriend,
    required this.bottomInset,
  });

  final HouseController house;
  final ValueNotifier<int> frame;
  final AppLocalizations l;
  final void Function(String message) toast;

  /// Stop page swipes while a tool or a creature is being dragged.
  final void Function(bool locked) lockPaging;
  final void Function(Room room) goTo;
  final void Function(String friendId) openFriend;
  final double bottomInset;

  HouseStore get store => house.store;
}

/// A room module: optional scene overlay (above the friends) and a shelf.
abstract class RoomModule {
  const RoomModule();

  /// Extra height the shelf needs above the friend-coin row.
  double get shelfExtra => 0;

  Widget overlay(BuildContext context, RoomContext rc) => const SizedBox.shrink();

  /// Room tools shown on the shelf under the friend coins (null = none).
  Widget? tools(BuildContext context, RoomContext rc) => null;

  /// Called when the room becomes / stops being the active page.
  void onEnter(RoomContext rc) {}
  void onLeave(RoomContext rc) {}
}
