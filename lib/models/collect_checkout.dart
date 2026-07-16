import '../models/address.dart';
import '../models/shipping_quote.dart';

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

  factory CollectShippingMethod.fromQuote(ShippingMethodQuote quote) {
    return CollectShippingMethod(
      id: quote.id,
      title: quote.title,
      duration: quote.duration,
      priceCents: quote.cents,
    );
  }
}

class CollectShippingSelection {
  const CollectShippingSelection({
    required this.address,
    required this.method,
  });

  final Address address;
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
