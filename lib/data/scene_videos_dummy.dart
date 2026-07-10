import '../models/feed_item.dart';
import '../models/post_summary.dart';
import 'home_feed_dummy.dart';

/// Public sample MP4s for scene videos when the API has no video scenes.
const kSceneVideoSampleUrls = [
  'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
];

const List<String> kSceneVideoCaptions = [
  'Late afternoon in the studio — glazing layers while the light was still warm.',
  'Process clip from this week: building texture before the final pass.',
  'Behind the scenes of a new piece. The first strokes always feel the riskiest.',
  'Studio walk-through before opening night. Still deciding on the hang.',
  'Quick look at how this scene came together, from sketch to final details.',
  'Filming the install — spacing, light, and how the work breathes in the room.',
];

/// Placeholder video scenes for the Scenes videos tab.
final List<FeedItem> kSceneVideoDummyItems = [
  for (var i = 0; i < kSceneVideoSampleUrls.length; i++)
    FeedItem.post(
      PostSummary(
        id: 'scene-video-dummy-$i',
        caption: kSceneVideoCaptions[i % kSceneVideoCaptions.length],
        mediaUrl: kSceneVideoSampleUrls[i],
        mediaType: 'video',
        authorName: kHomeFeedArtists[(i + 4) % kHomeFeedArtists.length].name,
        authorUsername: artistHandle(
          kHomeFeedArtists[(i + 4) % kHomeFeedArtists.length],
        ).replaceFirst('@', ''),
        likeCount: 84 + i * 23,
        isLiked: false,
        isSaved: false,
      ),
    ),
];
