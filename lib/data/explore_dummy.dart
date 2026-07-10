import '../models/feed_item.dart';
import '../models/piece_summary.dart';
import '../models/post_summary.dart';
import 'home_feed_dummy.dart';
import 'scene_videos_dummy.dart';

const _featuredId = 'explore-dummy-featured';

/// Placeholder hero for Explore when API data is unavailable.
FeedItem get kExploreFeaturedDummy {
  final artist = kHomeFeedArtists[0];
  return FeedItem.piece(
    PieceSummary(
      id: _featuredId,
      title: kFeedPieceTitles[0],
      mediaUrl: picsumUrl(501, 780, 520),
      caption: kFeedStories[0],
      medium: kHomeFeedMediums[0],
      authorName: artist.name,
      authorUsername: artistHandle(artist).replaceFirst('@', ''),
    ),
  );
}

/// Editorial feed placeholders — enough for 10 full cycles (50 items).
final List<FeedItem> kExploreFeedDummyItems = [
  for (var i = 0; i < 40; i++)
    FeedItem.piece(
      PieceSummary(
        id: 'explore-dummy-piece-$i',
        title: kFeedPieceTitles[i % kFeedPieceTitles.length],
        mediaUrl: picsumUrl(600 + i, 480, 640),
        medium: kHomeFeedMediums[i % kHomeFeedMediums.length],
        caption: kFeedStories[i % kFeedStories.length],
        dimensions: kFeedDimensions[i % kFeedDimensions.length],
        authorName: kHomeFeedArtists[(i + 1) % kHomeFeedArtists.length].name,
        authorUsername: artistHandle(
          kHomeFeedArtists[(i + 1) % kHomeFeedArtists.length],
        ).replaceFirst('@', ''),
        isForSale: i % 7 == 2,
        priceCents: i % 7 == 2 ? 240000 : null,
      ),
    ),
  for (var i = 0; i < 10; i++)
    FeedItem.post(
      PostSummary(
        id: 'explore-dummy-scene-$i',
        caption: kFeedStories[(i + 2) % kFeedStories.length],
        mediaUrl: i % 3 == 0
            ? kSceneVideoSampleUrls[i % kSceneVideoSampleUrls.length]
            : picsumUrl(700 + i, 780, 440),
        mediaType: i % 3 == 0 ? 'video' : 'image',
        authorName: kHomeFeedArtists[(i + 5) % kHomeFeedArtists.length].name,
        authorUsername: artistHandle(
          kHomeFeedArtists[(i + 5) % kHomeFeedArtists.length],
        ).replaceFirst('@', ''),
      ),
    ),
];
