import 'package:flutter/material.dart';

class NumberedExpansionTile extends StatefulWidget {
  final Widget? leading;
  final Widget title;
  final List<Widget> children;
  final String topText;

  final ShapeBorder? shape;
  final ShapeBorder? collapsedShape;
  final EdgeInsetsGeometry? tilePadding;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  const NumberedExpansionTile({
    super.key,
    this.leading,
    required this.title,
    required this.children,
    required this.topText,
    this.shape,
    this.collapsedShape,
    this.tilePadding,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  @override
  State<NumberedExpansionTile> createState() => _NumberedExpansionTileState();
}

class _NumberedExpansionTileState extends State<NumberedExpansionTile> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onExpansionChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final shape = _expanded
        ? widget.shape
        : (widget.collapsedShape ?? widget.shape);

    return Container(
      decoration: ShapeDecoration(
        shape: shape ?? const RoundedRectangleBorder(),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: (shape is RoundedRectangleBorder)
                ? shape.borderRadius as BorderRadius?
                : null,
            onTap: _toggle,
            child: Padding(
              padding: widget.tilePadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(child: widget.title),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.topText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.expand_more),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(),
            secondChild: Column(children: widget.children),
          ),
        ],
      ),
    );
  }
}