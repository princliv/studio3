/// Dummy artists for the home feed (20 entries).
class HomeFeedArtist {
  const HomeFeedArtist({required this.name, required this.avatarSeed});

  final String name;
  final int avatarSeed;
}

const List<String> kHomeFeedMediums = [
  'Oil on Canvas',
  'Watercolor',
  'Digital Art',
  'Acrylic',
  'Charcoal',
  'Mixed Media',
  'Gouache',
  'Pastel',
  'Ink',
  'Photography',
];

const List<HomeFeedArtist> kHomeFeedArtists = [
  HomeFeedArtist(name: 'Jordan Lee', avatarSeed: 101),
  HomeFeedArtist(name: 'Alex Chen', avatarSeed: 102),
  HomeFeedArtist(name: 'Sam Rivera', avatarSeed: 103),
  HomeFeedArtist(name: 'Morgan Blake', avatarSeed: 104),
  HomeFeedArtist(name: 'Riley Park', avatarSeed: 105),
  HomeFeedArtist(name: 'Casey Nguyen', avatarSeed: 106),
  HomeFeedArtist(name: 'Taylor Kim', avatarSeed: 107),
  HomeFeedArtist(name: 'Jamie Ortiz', avatarSeed: 108),
  HomeFeedArtist(name: 'Quinn Foster', avatarSeed: 109),
  HomeFeedArtist(name: 'Avery Walsh', avatarSeed: 110),
  HomeFeedArtist(name: 'Rowan Hayes', avatarSeed: 111),
  HomeFeedArtist(name: 'Sage Miller', avatarSeed: 112),
  HomeFeedArtist(name: 'River Cole', avatarSeed: 113),
  HomeFeedArtist(name: 'Eden Brooks', avatarSeed: 114),
  HomeFeedArtist(name: 'Phoenix Reed', avatarSeed: 115),
  HomeFeedArtist(name: 'Skylar James', avatarSeed: 116),
  HomeFeedArtist(name: 'Dakota Ellis', avatarSeed: 117),
  HomeFeedArtist(name: 'Reese Morgan', avatarSeed: 118),
  HomeFeedArtist(name: 'Cameron Vega', avatarSeed: 119),
  HomeFeedArtist(name: 'Blair Stone', avatarSeed: 120),
];

String picsumUrl(int seed, int w, int h) =>
    'https://picsum.photos/seed/$seed/$w/$h';

String picsumAvatarUrl(int seed) => picsumUrl(seed, 64, 64);
