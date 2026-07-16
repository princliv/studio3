import 'dart:io';
import 'package:image/image.dart' as img;

/// Regenerates derived app-icon / splash source assets from the base
/// logo_icon_white.png mark, working around a color-fringing bug in
/// flutter_launcher_icons' iOS alpha-flatten step (verified: pre-flattening
/// ourselves at native resolution avoids it) and Android 12's mandatory
/// circular splash-icon safe-zone clipping (fixed by adding transparent
/// padding so the mark doesn't touch the mask edge).
void main() {
  final source = img.decodePng(
    File('assets/logo/logo_icon_white.png').readAsBytesSync(),
  )!;

  // 1) Fully-opaque icon source: composite onto the dark brand background at
  //    native resolution so flutter_launcher_icons never has to flatten
  //    alpha itself (that step is what produced the green fringing).
  final bgColor = img.ColorRgb8(0x0A, 0x0A, 0x0A);
  final flattened = img.Image(width: source.width, height: source.height, numChannels: 3);
  img.fill(flattened, color: bgColor);
  img.compositeImage(flattened, source);
  File('assets/logo/app_icon.png').writeAsBytesSync(img.encodePng(flattened));
  print('Wrote assets/logo/app_icon.png (${flattened.width}x${flattened.height}, opaque)');

  // 2) Padded splash source: same mark on a transparent canvas at ~55% scale
  //    so it sits inside Android 12's circular splash-icon safe zone instead
  //    of being clipped by it.
  const scale = 0.55;
  final canvasSize = (source.width / scale).round();
  final padded = img.Image(width: canvasSize, height: canvasSize, numChannels: 4);
  img.fill(padded, color: img.ColorRgba8(0, 0, 0, 0));
  final offset = ((canvasSize - source.width) / 2).round();
  img.compositeImage(padded, source, dstX: offset, dstY: offset);
  File('assets/logo/splash_icon.png').writeAsBytesSync(img.encodePng(padded));
  print('Wrote assets/logo/splash_icon.png (${padded.width}x${padded.height}, padded, transparent)');
}
