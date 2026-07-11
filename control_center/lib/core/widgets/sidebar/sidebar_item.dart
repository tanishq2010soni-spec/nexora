import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isExpandable;
  final bool isExpanded;
  final List<SidebarItem> children;
  final bool isSubItem;
  final bool isCollapsed;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
    this.isSelected = false,
    required this.onTap,
    this.isExpandable = false,
    this.isExpanded = false,
    this.children = const [],
    this.isSubItem = false,
    this.isCollapsed = false,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isSubItem) {
      return _buildItem(isSubItem: true);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildItem(isSubItem: false),
        if (!widget.isCollapsed &&
            widget.isExpanded &&
            widget.children.isNotEmpty)
          ...widget.children,
      ],
    );
  }

  Widget _buildItem({required bool isSubItem}) {
    final paddingH = isSubItem ? 12.0 : 12.0;
    final paddingV = isSubItem ? 7.0 : 10.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: isSubItem ? 1 : 2,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.sidebarActive
                : _isHovered
                ? AppColors.sidebarHover
                : Colors.transparent,
            borderRadius: BorderRadius.circular(isSubItem ? 6 : 8),
          ),
          child: Stack(
            children: [
              if (widget.isSelected && !widget.isCollapsed)
                Positioned(
                  left: 0,
                  top: paddingV,
                  bottom: paddingV,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(isSubItem ? 6 : 8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingH,
                    vertical: paddingV,
                  ),
                  child: Row(
                    children: [
                      if (isSubItem) const SizedBox(width: 20),
                      Icon(
                        widget.icon,
                        size: isSubItem ? 14 : 20,
                        color: widget.isSelected
                            ? (isSubItem
                                  ? AppColors.accent
                                  : AppColors.textPrimary)
                            : AppColors.textSecondary,
                      ),
                      if (!widget.isCollapsed) ...[
                        SizedBox(width: isSubItem ? 10 : 12),
                        Expanded(
                          child: Text(
                            widget.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: isSubItem ? 13 : 14,
                              fontWeight: widget.isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (widget.isExpandable && widget.children.isNotEmpty)
                          Icon(
                            widget.isExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
