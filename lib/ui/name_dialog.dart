import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../model/house_store.dart';

/// Asks for a name. Returns the sanitized name, or null when cancelled.
Future<String?> askName(BuildContext context, {required String initial, bool firstRun = false, String? title}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: !firstRun,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    builder: (ctx) => _NameDialog(initial: initial, firstRun: firstRun, title: title),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial, required this.firstRun, this.title});
  final String initial;
  final bool firstRun;
  final String? title;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _save() => Navigator.pop(context, HouseStore.sanitizeName(_c.text));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      alignment: const Alignment(0, 0.75),
      title: Text(widget.title ?? l.firstRunNameTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
      content: TextField(
        controller: _c,
        autofocus: true,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.words,
        maxLength: HouseStore.maxNameLength,
        inputFormatters: [LengthLimitingTextInputFormatter(HouseStore.maxNameLength)],
        style: Theme.of(context).textTheme.titleLarge,
        decoration: InputDecoration(hintText: l.nameFieldHint, counterText: ''),
        onSubmitted: (_) => _save(),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, widget.firstRun ? HouseStore.sanitizeName(widget.initial) : null),
          child: Text(widget.firstRun ? l.actionSkip : l.actionCancel),
        ),
        FilledButton(onPressed: _save, child: Text(l.actionSave)),
      ],
    );
  }
}
