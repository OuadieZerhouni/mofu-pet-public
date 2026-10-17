import 'dart:async';

import 'package:flutter/material.dart';

import '../../../model/house_store.dart';
import '../../games/boop_rush_screen.dart';
import '../../games/snack_catch_screen.dart';
import '../../theme.dart';
import '../room_context.dart';

/// Playroom: two mini-games on cards; friends play in the background.
class PlayroomRoom extends RoomModule {
  const PlayroomRoom();

  @override
  Widget overlay(BuildContext context, RoomContext rc) {
    final top = MediaQuery.of(context).padding.top + 66;
    final l = rc.l;
    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: ListenableBuilder(
        listenable: rc.store,
        builder: (context, _) {
          final store = rc.store;
          final catcher = store.inRoom(Room.playroom).firstOrNull ?? store.friends.firstOrNull;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GameCard(
                title: l.gameBoopRush,
                body: l.gameBoopRushDesc,
                meta: '${l.gameBest(store.bestBoopRush)} · ${l.gameStarsCap(HouseStore.dailyCap[StarSource.boopRush]!)}',
                art: const _BoardArt(),
                onPlay: () => unawaited(playBoopRush(context, store: store)),
                playLabel: l.gamePlay(l.gameBoopRush),
              ),
              const SizedBox(height: 12),
              _GameCard(
                title: l.gameSnackCatch,
                body: l.gameSnackCatchDesc,
                meta: '${l.gameBest(store.bestSnackCatch)} · ${l.gameStarsCap(HouseStore.dailyCap[StarSource.snackCatch]!)}',
                art: const _CatchArt(),
                onPlay: catcher == null ? null : () => unawaited(playSnackCatch(context, store: store, friend: catcher)),
                playLabel: l.gamePlay(l.gameSnackCatch),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.title, required this.body, required this.meta, required this.art, required this.onPlay, required this.playLabel});
  final String title;
  final String body;
  final String meta;
  final Widget art;
  final VoidCallback? onPlay;
  final String playLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPlay != null,
      label: playLabel,
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [BoxShadow(color: Color(0xFFDCD0FF), offset: Offset(0, 6))],
          ),
          child: Row(
            children: [
              SizedBox(width: 84, height: 84, child: art),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: House.ink)),
                    const SizedBox(height: 2),
                    Text(body, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: House.inkSoft)),
                    const SizedBox(height: 4),
                    Text(meta, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: House.roseDeep)),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill_rounded, color: House.rose, size: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardArt extends StatelessWidget {
  const _BoardArt();

  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFFF7A9BD), Color(0xFF8E5C3B), Color(0xFFF2B632), Color(0xFF8E5C3B), Color(0xFF9FD3F0), Color(0xFF8E5C3B), Color(0xFFB9E3A8), Color(0xFF8E5C3B), Color(0xFFF7A9BD)];
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFDDEFD3), borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(9),
      child: Column(
        children: [
          for (var r = 0; r < 3; r++)
            Expanded(
              child: Row(
                children: [
                  for (var c = 0; c < 3; c++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: colors[r * 3 + c])),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CatchArt extends StatelessWidget {
  const _CatchArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFE3F2F6), borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Positioned(left: 16, top: 12, child: Container(width: 14, height: 14, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE2504F)))),
          Positioned(left: 50, top: 26, child: Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF6CF4C)))),
          Positioned(
            left: 22,
            bottom: 12,
            child: Container(width: 40, height: 20, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color(0xFFFBB8C9))),
          ),
        ],
      ),
    );
  }
}
