import 'collect_shipping_address.dart';

class CollectShippingMethod {
  const CollectShippingMethod({
    required this.id,
    required this.title,
    required this.duration,
    required this.priceCents,
  });

  final String id;
  final String title;
  final String duration;
  final int priceCents;

  String get priceDisplay => '\$${(priceCents / 100).toStringAsFixed(2)}';
}

const kCollectShippingMethods = <CollectShippingMethod>[
  CollectShippingMethod(
    id: 'standard',
    title: 'Standard Shipping',
    duration: '4 - 6 Business Days',
    priceCents: 500,
  ),
  CollectShippingMethod(
    id: 'expedited',
    title: 'Expedited Shipping',
    duration: '4 - 6 Business Days',
    priceCents: 500,
  ),
  CollectShippingMethod(
    id: 'express',
    title: 'Express Shipping',
    duration: '4 - 6 Business Days',
    priceCents: 500,
  ),
];

class CollectShippingSelection {
  const CollectShippingSelection({
    required this.address,
    required this.method,
  });

  final CollectShippingAddress address;
  final CollectShippingMethod method;
}

enum CollectPaymentMethod { gpay, applePay, card }

extension CollectPaymentMethodX on CollectPaymentMethod {
  String get label {
    switch (this) {
      case CollectPaymentMethod.gpay:
        return 'GPay';
      case CollectPaymentMethod.applePay:
        return 'Apple Pay';
      case CollectPaymentMethod.card:
        return 'Credit / Debit card';
    }
  }
}
