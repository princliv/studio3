/// Shipping address captured in the Collect checkout flow.
class CollectShippingAddress {
  const CollectShippingAddress({
    required this.firstName,
    required this.lastName,
    required this.street,
    this.apt,
    required this.city,
    required this.state,
    required this.zip,
    this.phone,
  });

  final String firstName;
  final String lastName;
  final String street;
  final String? apt;
  final String city;
  final String state;
  final String zip;
  final String? phone;

  String get summaryLine {
    final parts = <String>[
      if (street.isNotEmpty) street,
      if (apt != null && apt!.isNotEmpty) apt!,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (zip.isNotEmpty) zip,
    ];
    return parts.join(', ');
  }
}

const kUsStates = <String>[
  'AL',
  'AK',
  'AZ',
  'AR',
  'CA',
  'CO',
  'CT',
  'DE',
  'FL',
  'GA',
  'HI',
  'ID',
  'IL',
  'IN',
  'IA',
  'KS',
  'KY',
  'LA',
  'ME',
  'MD',
  'MA',
  'MI',
  'MN',
  'MS',
  'MO',
  'MT',
  'NE',
  'NV',
  'NH',
  'NJ',
  'NM',
  'NY',
  'NC',
  'ND',
  'OH',
  'OK',
  'OR',
  'PA',
  'RI',
  'SC',
  'SD',
  'TN',
  'TX',
  'UT',
  'VT',
  'VA',
  'WA',
  'WV',
  'WI',
  'WY',
  'DC',
];
