import 'package:flutter/material.dart';

import 'icons.dart';

class LimaFacSectionItem {
  const LimaFacSectionItem(this.title, this.icon, {this.subtitle = ''});
  final String title;
  final IconData icon;
  final String subtitle;
}

class LimaFacSectionedPage extends StatefulWidget {
  const LimaFacSectionedPage({
    super.key,
    required this.navigationTitle,
    required this.sections,
    required this.selected,
    required this.onSelected,
    required this.child,
    this.actions = const [],
    this.searchNavigation = false,
  });
  final String navigationTitle;
  final List<LimaFacSectionItem> sections;
  final int selected;
  final ValueChanged<int>? onSelected;
  final Widget child;
  final List<Widget> actions;
  final bool searchNavigation;

  @override
  State<LimaFacSectionedPage> createState() => _LimaFacSectionedPageState();
}

class _LimaFacSectionedPageState extends State<LimaFacSectionedPage> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final selected =
        widget.selected >= 0 && widget.selected < widget.sections.length
        ? widget.sections[widget.selected]
        : null;
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.actions.isNotEmpty)
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.dividerColor)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.actions,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(compact ? 18 : 26),
              child: Row(
                children: [
                  if (selected != null) ...[
                    LimaFacIcon(
                      selected.icon,
                      size: 22,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected?.title ?? widget.navigationTitle,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (selected != null &&
                            selected.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            selected.subtitle,
                            style: TextStyle(
                              color: theme.hintColor,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: widget.child),
          ],
        );
        if (compact) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<int>(
                  value: selected == null ? null : widget.selected,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: widget.navigationTitle,
                  ),
                  items: List.generate(
                    widget.sections.length,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(widget.sections[i].title),
                    ),
                  ),
                  onChanged: widget.onSelected == null
                      ? null
                      : (index) {
                          if (index != null) widget.onSelected!(index);
                        },
                ),
              ),
              Expanded(child: content),
            ],
          );
        }
        return Row(
          children: [
            SizedBox(
              width: 238,
              child: ColoredBox(
                color: theme.scaffoldBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                      child: Text(
                        widget.navigationTitle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: .8,
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                    if (widget.searchNavigation)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                        child: TextField(
                          onChanged: (value) => setState(
                            () => _filter = value.trim().toLowerCase(),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Buscar vistas',
                            isDense: true,
                            prefixIcon: LimaFacIcon(
                              Icons.search_rounded,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          for (var i = 0; i < widget.sections.length; i++)
                            if (widget.sections[i].title.toLowerCase().contains(
                              _filter,
                            ))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Material(
                                  color: i == widget.selected
                                      ? theme.colorScheme.primary.withAlpha(26)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  child: ListTile(
                                    dense: true,
                                    selected: i == widget.selected,
                                    hoverColor: theme.colorScheme.primary
                                        .withAlpha(18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    leading: LimaFacIcon(
                                      widget.sections[i].icon,
                                      size: 20,
                                      color: i == widget.selected
                                          ? theme.colorScheme.primary
                                          : theme.hintColor,
                                    ),
                                    title: Text(
                                      widget.sections[i].title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: i == widget.selected
                                            ? theme.colorScheme.primary
                                            : null,
                                        fontWeight: i == widget.selected
                                            ? FontWeight.w500
                                            : FontWeight.w400,
                                      ),
                                    ),
                                    onTap: widget.onSelected == null
                                        ? null
                                        : () => widget.onSelected!(i),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}

class LimaFacEmptyDevices extends StatelessWidget {
  const LimaFacEmptyDevices({
    super.key,
    required this.title,
    required this.message,
  });
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).cardColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LimaFacIcon(
                Icons.inventory_2_outlined,
                size: 76,
                color: Theme.of(context).hintColor.withAlpha(150),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
