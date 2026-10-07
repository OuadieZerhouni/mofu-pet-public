import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../l10n/app_localizations.dart';
import '../model/catalog.dart';
import '../model/pet_store.dart';
import 'names.dart';
import 'theme.dart';
import 'widgets.dart';

Future<void> showWardrobe(BuildContext context) {
  final store = AppScope.of(context).store;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AppScope(services: AppScope.of(context), child: WardrobeSheet(store: store)),
  );
}

class WardrobeSheet extends StatefulWidget {
  const WardrobeSheet({super.key, required this.store});
  final PetStore store;

  @override
  State<WardrobeSheet> createState() => _WardrobeSheetState();
}

class _WardrobeSheetState extends State<WardrobeSheet> {
  late final Set<String> _newOnOpen = widget.store.unseenUnlocks;

  @override
  void initState() {
    super.initState();
    // Seen as soon as the wardrobe opens; the dots stay visible for this visit.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.store.markSeen(_newOnOpen));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final h = MediaQuery.sizeOf(context).height;
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final s = widget.store;
        // Seasonal items appear only once earned, so the grid never shows a
        // permanently locked tile outside its season.
        final accessories = Catalog.accessories
            .where((a) => a.rule.kind != UnlockKind.seasonal || s.isUnlocked(a.rule))
            .toList();
        return SizedBox(
          height: h * 0.74,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                MofuPreview(colorId: s.colorId, accessoryId: s.accessoryId, fluff: s.fluffFraction, size: 120),
                Text(l.wardrobeTitle, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                TabBar(
                  labelColor: MofuColors.accentDeep,
                  unselectedLabelColor: MofuColors.inkSoft,
                  indicatorColor: MofuColors.accentDeep,
                  dividerColor: Colors.transparent,
                  labelStyle: Theme.of(context).textTheme.titleMedium,
                  tabs: [Tab(text: l.tabFur), Tab(text: l.tabAccessories)],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _Grid(
                        children: [
                          for (final c in Catalog.furColors)
                            _ItemTile(
                              preview: MofuPreview(colorId: c.id, accessoryId: s.accessoryId, fluff: 0.55, size: 74),
                              name: l.colorName(c.id),
                              locked: !s.isUnlocked(c.rule),
                              lockText: l.unlockText(c.rule),
                              selected: s.colorId == c.id,
                              isNew: _newOnOpen.contains('color:${c.id}'),
                              newLabel: l.badgeNew,
                              onTap: () => s.setColor(c.id),
                            ),
                        ],
                      ),
                      _Grid(
                        children: [
                          for (final a in accessories)
                            _ItemTile(
                              preview: MofuPreview(colorId: s.colorId, accessoryId: a.id, fluff: 0.55, size: 74),
                              name: l.accessoryName(a.id),
                              locked: !s.isUnlocked(a.rule),
                              lockText: l.unlockText(a.rule),
                              selected: s.accessoryId == a.id,
                              isNew: _newOnOpen.contains('acc:${a.id}'),
                              newLabel: l.badgeNew,
                              onTap: () => s.setAccessory(a.id),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.paddingOf(context).bottom),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.78,
      children: children,
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.preview,
    required this.name,
    required this.locked,
    required this.lockText,
    required this.selected,
    required this.isNew,
    required this.newLabel,
    required this.onTap,
  });

  final Widget preview;
  final String name;
  final bool locked;
  final String lockText;
  final bool selected;
  final bool isNew;
  final String newLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: !locked,
      selected: selected,
      label: locked ? '$name. $lockText' : name,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: MofuColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? MofuColors.accent : MofuColors.line, width: selected ? 3 : 1.5),
          ),
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: locked
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.mode(MofuColors.lock, BlendMode.srcATop),
                              child: Opacity(opacity: 0.6, child: preview),
                            )
                          : preview,
                    ),
                  ),
                  Text(
                    locked ? lockText : name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: locked
                        ? t.bodySmall?.copyWith(fontSize: 11.5, height: 1.15)
                        : t.bodyMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
                  ),
                ],
              ),
              if (locked)
                const PositionedDirectional(top: 2, end: 2, child: Icon(Icons.lock_rounded, size: 16, color: MofuColors.lock)),
              if (isNew && !locked)
                PositionedDirectional(
                  top: 0,
                  start: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: MofuColors.accentDeep, borderRadius: BorderRadius.circular(10)),
                    child: Text(newLabel, style: t.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
