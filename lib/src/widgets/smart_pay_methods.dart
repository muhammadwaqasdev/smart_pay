import 'package:flutter/material.dart';

import '../providers/payment_provider_plugin.dart';
import '../store/smart_pay_store.dart';

typedef PaymentMethodSelected = void Function(PaymentProviderPlugin provider);

class SmartPayMethods extends StatelessWidget {
  final SmartPayStore store;
  final PaymentMethodSelected? onMethodSelected;
  final Axis direction;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const SmartPayMethods({
    super.key,
    required this.store,
    this.onMethodSelected,
    this.direction = Axis.horizontal,
    this.padding = const EdgeInsets.all(8),
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final List<PaymentProviderPlugin> enabled = store.enabledProviders;

    if (enabled.isEmpty) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<String?>(
      valueListenable: store.selectedProviderId,
      builder: (context, selectedId, _) {
        final List<Widget> children = <Widget>[];
        for (final p in enabled) {
          final bool selected = p.id == selectedId;
          children.add(
            _MethodChip(
              label: p.displayName,
              selected: selected,
              onTap: () {
                store.selectById(p.id);
                onMethodSelected?.call(p);
              },
            ),
          );
          if (p != enabled.last) {
            children.add(SizedBox(
                width: direction == Axis.horizontal ? spacing : 0,
                height: direction == Axis.vertical ? spacing : 0));
          }
        }

        final Widget content = direction == Axis.horizontal
            ? Row(children: children)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children);

        return Padding(padding: padding, child: content);
      },
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MethodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
