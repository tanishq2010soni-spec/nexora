import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'search_index.dart';
import 'global_search_delegate.dart';

class CommandPalette extends StatefulWidget {
  final List<SearchEntry> entries;

  const CommandPalette({super.key, required this.entries});

  static void show(BuildContext context, List<SearchEntry> entries) {
    showSearch(context: context, delegate: GlobalSearchDelegate(entries));
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class CommandPaletteShortcut extends StatefulWidget {
  final Widget child;
  final List<SearchEntry> entries;

  const CommandPaletteShortcut({
    super.key,
    required this.child,
    required this.entries,
  });

  @override
  State<CommandPaletteShortcut> createState() => _CommandPaletteShortcutState();
}

class _CommandPaletteShortcutState extends State<CommandPaletteShortcut> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            _OpenPaletteIntent(),
      },
      child: Actions(
        actions: {
          _OpenPaletteIntent: CallbackAction<_OpenPaletteIntent>(
            onInvoke: (_) => CommandPalette.show(context, widget.entries),
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          child: widget.child,
        ),
      ),
    );
  }
}

class _OpenPaletteIntent extends Intent {}
