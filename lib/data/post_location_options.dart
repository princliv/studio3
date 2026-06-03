/// Location options for the create-post flow (Figma 2019:2715).
class PostLocationOption {
  const PostLocationOption({
    required this.id,
    required this.name,
    required this.subtitle,
  });

  final String id;
  final String name;
  final String subtitle;
}

abstract final class PostLocationOptions {
  PostLocationOptions._();

  static const all = <PostLocationOption>[
    PostLocationOption(
      id: 'dallas',
      name: 'Dallas',
      subtitle: 'Texas, United States',
    ),
    PostLocationOption(
      id: 'w_dallas',
      name: 'W Dallas',
      subtitle: '2440 Victory Park Ln, Dallas TX 75219 USA',
    ),
    PostLocationOption(
      id: 'magic_kingdom',
      name: 'Magic Kingdom Park',
      subtitle: '1180 Seven Seas Dr, Lake Buena Vista, FL 32830',
    ),
    PostLocationOption(
      id: 'aa_center',
      name: 'American Airlines Center',
      subtitle: '2500 Victory Ave, Dallas, TX 75219',
    ),
    PostLocationOption(
      id: 'richardson',
      name: 'Richardson',
      subtitle: 'Texas, United States',
    ),
    PostLocationOption(
      id: 'dfw_metro',
      name: 'Dallas/Fort Worth Metro',
      subtitle: 'Dallas–Fort Worth, Texas, United States',
    ),
    PostLocationOption(
      id: 'fort_worth',
      name: 'Fort Worth',
      subtitle: 'Texas, United States',
    ),
    PostLocationOption(
      id: 'plano',
      name: 'Plano',
      subtitle: 'Texas, United States',
    ),
    PostLocationOption(
      id: 'austin',
      name: 'Austin',
      subtitle: 'Texas, United States',
    ),
    PostLocationOption(
      id: 'houston',
      name: 'Houston',
      subtitle: 'Texas, United States',
    ),
    PostLocationOption(
      id: 'deep_ellum',
      name: 'Deep Ellum',
      subtitle: 'Dallas, TX 75226, United States',
    ),
    PostLocationOption(
      id: 'bishop_arts',
      name: 'Bishop Arts District',
      subtitle: 'Dallas, TX 75208, United States',
    ),
  ];

  static PostLocationOption? byId(String id) {
    for (final option in all) {
      if (option.id == id) return option;
    }
    return null;
  }
}
