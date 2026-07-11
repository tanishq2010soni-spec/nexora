import 'package:flutter/material.dart';
import 'search_index.dart';

class GlobalSearchDelegate extends SearchDelegate<SearchEntry?> {
  final List<SearchEntry> entries;

  GlobalSearchDelegate(this.entries);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = entries
        .where(
          (e) =>
              e.title.toLowerCase().contains(query.toLowerCase()) ||
              (e.subtitle?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final entry = results[index];
        return ListTile(
          title: Text(entry.title),
          subtitle: entry.subtitle != null ? Text(entry.subtitle!) : null,
          leading: Icon(_getIcon(entry.module)),
          onTap: () => close(context, entry),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Type to search...'));
    }
    return buildResults(context);
  }

  IconData _getIcon(SearchModule module) {
    switch (module) {
      case SearchModule.agent:
        return Icons.smart_toy;
      case SearchModule.lead:
        return Icons.person_add;
      case SearchModule.customer:
        return Icons.people;
      case SearchModule.conversation:
        return Icons.chat;
      case SearchModule.knowledgeBase:
        return Icons.book;
      case SearchModule.document:
        return Icons.description;
      case SearchModule.setting:
        return Icons.settings;
    }
  }
}
