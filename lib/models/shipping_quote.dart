/// A shipping method option returned by GET /api/pieces/:id/shipping-quote.
class ShippingMethodQuote {
  const ShippingMethodQuote({required this.id, required this.cents});

  final String id;
  final int cents;

  factory ShippingMethodQuote.fromJson(Map<String, dynamic> json) {
    return ShippingMethodQuote(
      id: json['id'] as String? ?? '',
      cents: (json['cents'] as num?)?.toInt() ?? 0,
    );
  }

  String get priceDisplay => '\$${(cents / 100).toStringAsFixed(2)}';

  String get title {
    switch (id) {
      case 'standard':
        return 'Standard Shipping';
      case 'express':
        return 'Express Shipping';
      case 'overnight':
        return 'Overnight Shipping';
      case 'free':
        return 'Free Shipping';
      default:
        return id;
    }
  }

  String get duration {
    switch (id) {
      case 'standard':
        return '4 - 6 Business Days';
      case 'express':
        return '2 - 3 Business Days';
      case 'overnight':
        return 'Next Business Day';
      case 'free':
        return '7 - 10 Business Days';
      default:
        return '';
    }
  }
}
