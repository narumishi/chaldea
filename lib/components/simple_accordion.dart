import 'package:flutter/material.dart';

typedef AccordionHeaderBuilder = Widget Function(
    BuildContext context, bool expanded);

class SimpleAccordion extends StatefulWidget {
  final bool expanded;
  final AccordionHeaderBuilder headerBuilder;
  final WidgetBuilder contentBuilder;
  final void Function(bool expanded)? expandCallback;
  final bool canTapOnHeader;
  final AccordionHeaderBuilder? expandIconBuilder;
  final bool disableAnimation;

  const SimpleAccordion({
    Key? key,
    this.expanded = false,
    required this.headerBuilder,
    required this.contentBuilder,
    this.expandCallback,
    this.canTapOnHeader = true,
    this.expandIconBuilder,
    this.disableAnimation = false,
  }) : super(key: key);

  @override
  _SimpleAccordionState createState() => _SimpleAccordionState();
}

class _SimpleAccordionState extends State<SimpleAccordion> {
  bool expanded = false;

  @override
  void initState() {
    super.initState();
    expanded = widget.expanded;
  }

  void toggle() {
    setState(() {
      expanded = !expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    late Widget expandIcon;
    if (widget.expandIconBuilder != null) {
      expandIcon = widget.expandIconBuilder!(context, expanded);
      if (!widget.canTapOnHeader)
        expandIcon = GestureDetector(onTap: toggle, child: expandIcon);
    } else {
      expandIcon = ExpandIcon(
        isExpanded: expanded,
        onPressed: widget.canTapOnHeader ? null : (_) => toggle(),
      );
    }
    Widget header = widget.headerBuilder(context, expanded);
    header = Row(children: [Expanded(child: header), expandIcon]);
    if (widget.canTapOnHeader) {
      header = InkWell(onTap: toggle, child: header);
    }
    Widget content;
    if (widget.disableAnimation) {
      content = expanded ? widget.contentBuilder(context) : Container();
    } else {
      content = AnimatedCrossFade(
        firstChild: Container(height: 0.0),
        secondChild: widget.contentBuilder(context),
        firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.fastOutSlowIn,
        crossFadeState:
            expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
      );
    }

    return Padding(
      padding: expanded ? EdgeInsets.only(bottom: 6) : EdgeInsets.zero,
      child: Material(
        elevation: expanded ? 2 : 0,
        color: Material.of(context)?.color,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [header, content],
        ),
      ),
    );
  }
}
