import 'package:photo_manager/photo_manager.dart';

import 'permission_service.dart';

/// Enumerates device photo albums/assets for the custom in-app gallery
/// picker (`PostGalleryPicker`). Permission is requested through the
/// existing `PermissionService` (permission_handler) so there is a single
/// source of truth for gallery access across the app — photo_manager's own
/// permission check is disabled to avoid a second, redundant OS prompt for
/// the same underlying permission.
class PhotoLibraryService {
  PhotoLibraryService._();
  static final PhotoLibraryService instance = PhotoLibraryService._();

  bool _ignoreCheckSet = false;

  Future<GalleryPermissionOutcome> ensureAccess({bool forVideo = false}) async {
    final outcome = forVideo
        ? await PermissionService.instance.requestMixedGalleryAccess()
        : await PermissionService.instance
            .requestGalleryAccess(forVideo: false);
    if (outcome == GalleryPermissionOutcome.granted && !_ignoreCheckSet) {
      PhotoManager.setIgnorePermissionCheck(true);
      _ignoreCheckSet = true;
    }
    return outcome;
  }

  /// Albums including the aggregate "Recent" (all photos, and videos when
  /// [type] is [RequestType.common]) entry first.
  Future<List<AssetPathEntity>> fetchAlbums({
    RequestType type = RequestType.image,
  }) {
    return PhotoManager.getAssetPathList(
      type: type,
      filterOption: FilterOptionGroup(
        orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
      ),
    );
  }

  Future<AssetEntity?> fetchCover(AssetPathEntity album) async {
    final assets = await album.getAssetListRange(start: 0, end: 1);
    return assets.isEmpty ? null : assets.first;
  }

  Future<List<AssetEntity>> fetchAssets(
    AssetPathEntity album, {
    int page = 0,
    int size = 100,
  }) {
    return album.getAssetListPaged(page: page, size: size);
  }
}
