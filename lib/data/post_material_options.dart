/// Material product for the add-materials flow (Figma 2021:4128).
class PostMaterialOption {
  const PostMaterialOption({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
  });

  final String id;
  final String name;
  final String price;
  final String imagePath;
}

abstract final class PostMaterialOptions {
  PostMaterialOptions._();

  static const all = <PostMaterialOption>[
    PostMaterialOption(
      id: 'winsor_cadmium_red',
      name: 'Winsor & Newton Winton Oil Color - Cadmium Red Hue',
      price: r'$21.40',
      imagePath: 'assets/post/grid/grid_00.png',
    ),
    PostMaterialOption(
      id: 'winsor_ultramarine',
      name: 'Winsor & Newton Winton Oil Color - Ultramarine Blue',
      price: r'$19.80',
      imagePath: 'assets/post/grid/grid_01.png',
    ),
    PostMaterialOption(
      id: 'liquin_medium',
      name: 'Winsor & Newton Liquin Original Medium',
      price: r'$14.25',
      imagePath: 'assets/post/grid/grid_02.png',
    ),
    PostMaterialOption(
      id: 'canvas_panel',
      name: 'Fredrix Canvas Panel - 11 x 14 in',
      price: r'$8.99',
      imagePath: 'assets/post/grid/grid_03.png',
    ),
    PostMaterialOption(
      id: 'gesso_primer',
      name: 'Liquitex Professional Gesso - White',
      price: r'$16.50',
      imagePath: 'assets/post/grid/grid_04.png',
    ),
    PostMaterialOption(
      id: 'palette_knife',
      name: 'RGM New Age Painting Knife #045',
      price: r'$12.30',
      imagePath: 'assets/post/grid/grid_05.png',
    ),
    PostMaterialOption(
      id: 'charcoal_set',
      name: 'General\'s Charcoal Pencil Set - 12 Pack',
      price: r'$11.75',
      imagePath: 'assets/post/grid/grid_06.png',
    ),
    PostMaterialOption(
      id: 'watercolor_paper',
      name: 'Arches Watercolor Block - Cold Press 140 lb',
      price: r'$32.00',
      imagePath: 'assets/post/grid/grid_07.png',
    ),
    PostMaterialOption(
      id: 'brush_set',
      name: 'Princeton Velvetouch Brush Set - 5 Piece',
      price: r'$24.60',
      imagePath: 'assets/post/grid/grid_08.png',
    ),
    PostMaterialOption(
      id: 'fixative_spray',
      name: 'Grumbacher Final Fixative - Matte',
      price: r'$9.45',
      imagePath: 'assets/post/grid/grid_09.png',
    ),
  ];

  static const recentlyUsedIds = <String>[
    'winsor_cadmium_red',
    'winsor_ultramarine',
  ];

  static List<PostMaterialOption> get recentlyUsed => recentlyUsedIds
      .map((id) => byId(id))
      .whereType<PostMaterialOption>()
      .toList();

  static List<PostMaterialOption> get suggested => all
      .where((m) => !recentlyUsedIds.contains(m.id))
      .toList();

  static PostMaterialOption? byId(String id) {
    for (final material in all) {
      if (material.id == id) return material;
    }
    return null;
  }
}
