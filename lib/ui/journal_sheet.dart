import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../l10n/app_localizations.dart';
import '../model/catalog.dart';
import 'names.dart';
import 'theme.dart';

Future<void> showJournal(BuildContext context) {
  final services = AppScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AppScope(services: services, child: const JournalSheet()),
  );
}

class JournalSheet extends StatelessWidget {
  const JournalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final store = AppScope.of(context).store;
    final t = Theme.of(context).textTheme;
    final found = store.discovered.length;
    const total = 24;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.74,
      child: Column(
        children: [
          Text(l.journalTitle, style: t.titleLarge),
          const SizedBox(height: 6),
          Text(l.journalProgress(found, Catalog.reactions.length), style: t.bodySmall),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: found / (Catalog.reactions.isEmpty ? total : Catalog.reactions.length),
                minHeight: 9,
                backgroundColor: MofuColors.line,
                valueColor: const AlwaysStoppedAnimation(MofuColors.gold),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.paddingOf(context).bottom),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
              children: [
                for (final r in Catalog.reactions)
                  _Entry(
                    emoji: r.emoji,
                    known: store.discovered.contains(r.id),
                    name: l.reaction(r.id).$1,
                    hint: l.reaction(r.id).$2,
                    unknown: l.journalUnknown,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.emoji, required this.known, required this.name, required this.hint, required this.unknown});
  final String emoji;
  final bool known;
  final String name;
  final String hint;
  final String unknown;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      label: known ? '$name. $hint' : '$unknown. $hint',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: known ? MofuColors.card : MofuColors.card.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: known ? const Color(0xFFFFE3A3) : MofuColors.line, width: 1.5),
        ),
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: known ? const Color(0xFFFFF4D6) : MofuColors.line,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: known
                  ? Text(emoji, style: const TextStyle(fontSize: 26))
                  : ColorFiltered(
                      colorFilter: const ColorFilter.mode(MofuColors.lock, BlendMode.srcIn),
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
            ),
            const SizedBox(height: 6),
            // Undiscovered: a silhouette and the hint, nothing that gives the name away.
            if (known) ...[
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: MofuColors.ink),
              ),
              const SizedBox(height: 2),
            ],
            Expanded(
              child: Text(
                hint,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: t.bodySmall?.copyWith(fontSize: 11.5, height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
