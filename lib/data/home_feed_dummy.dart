/// Dummy artists for the home feed (20 entries).
class HomeFeedArtist {
  const HomeFeedArtist({required this.name, required this.avatarSeed});

  final String name;
  final int avatarSeed;
}

const List<String> kHomeFeedMediums = [
  'Oil on canvas',
  'Watercolor',
  'Digital art',
  'Acrylic',
  'Charcoal',
  'Mixed media',
  'Gouache',
  'Pastel',
  'Ink',
  'Photography',
];

const List<HomeFeedArtist> kHomeFeedArtists = [
  HomeFeedArtist(name: 'Amara Osei', avatarSeed: 101),
  HomeFeedArtist(name: 'Cedric Okafor', avatarSeed: 102),
  HomeFeedArtist(name: 'Daisy Smith', avatarSeed: 103),
  HomeFeedArtist(name: 'Jordan Lee', avatarSeed: 104),
  HomeFeedArtist(name: 'Alex Chen', avatarSeed: 105),
  HomeFeedArtist(name: 'Sam Rivera', avatarSeed: 106),
  HomeFeedArtist(name: 'Morgan Blake', avatarSeed: 107),
  HomeFeedArtist(name: 'Riley Park', avatarSeed: 108),
  HomeFeedArtist(name: 'Casey Nguyen', avatarSeed: 109),
  HomeFeedArtist(name: 'Taylor Kim', avatarSeed: 110),
  HomeFeedArtist(name: 'Jamie Ortiz', avatarSeed: 111),
  HomeFeedArtist(name: 'Quinn Foster', avatarSeed: 112),
  HomeFeedArtist(name: 'Avery Walsh', avatarSeed: 113),
  HomeFeedArtist(name: 'Rowan Hayes', avatarSeed: 114),
  HomeFeedArtist(name: 'Sage Miller', avatarSeed: 115),
  HomeFeedArtist(name: 'River Cole', avatarSeed: 116),
  HomeFeedArtist(name: 'Eden Brooks', avatarSeed: 117),
  HomeFeedArtist(name: 'Phoenix Reed', avatarSeed: 118),
  HomeFeedArtist(name: 'Skylar James', avatarSeed: 119),
  HomeFeedArtist(name: 'Dakota Ellis', avatarSeed: 120),
];

const List<String> kFeedPieceTitles = [
  'Bodies in Color',
  'Companion Bloom',
  'The City Forgets Itself',
  'Fold then Drift',
  'Coastal Forms #3',
  'Studio Notes — January',
  'Untitled (Series 12)',
  'Warmth Without Surface',
  'Teal Horizon',
  'Quiet Geometry',
  'Night Bloom',
  'Soft Architecture',
  'River Light',
  'Still Life in Motion',
  'Echo Chamber',
];

const List<String> kFeedDimensions = [
  '24×36 in | 60.9×91.4 cm',
  '18×24 in | 45.7×61 cm',
  '30×40 in | 76.2×101.6 cm',
  '12×16 in | 30.5×40.6 cm',
  '36×48 in | 91.4×121.9 cm',
];

const List<String> kFeedStories = [
  'Started this one trying to paint skin as light rather than surface. The teal came first... I wasn\'t really planning it, but once it was there everything else had to answer to it.',
  'A meditation on erosion and time. Each layer records a decision I almost undid.',
  'Exploring new pigments and how they sit on raw linen. The whole series followed from one accidental mix.',
  'Minimalist study in light. I kept asking what color is warmth when you strip away the obvious answer.',
  'This piece began as a sketch and grew into something I didn\'t expect. Sometimes the work knows before you do.',
];

const List<String> kFeedSeriesNames = [
  'Colorful Portraits',
  'Urban Fragments',
  'Process Studies',
  'Light Fields',
];

String picsumUrl(int seed, int w, int h) =>
    'https://picsum.photos/seed/$seed/$w/$h';

String picsumAvatarUrl(int seed) => picsumUrl(seed, 64, 64);

String artistHandle(HomeFeedArtist artist) {
  final handle = artist.name
      .toLowerCase()
      .replaceAll(' ', '')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');
  return '@$handle';
}
