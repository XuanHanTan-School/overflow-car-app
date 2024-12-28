import 'package:media_kit/media_kit.dart';

void configureLowLatencyPlayback(bool lowLatency, {required Player player}) {
  if (player.platform is NativePlayer) {
    NativePlayer playerNative = player.platform as NativePlayer;
    if (lowLatency) {
      playerNative.setProperty('profile', 'low-latency');
    }
  }
}
