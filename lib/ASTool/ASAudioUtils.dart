import 'package:audioplayers/audioplayers.dart';

import 'ASLogger.dart';
import 'as_LocalProvider.dart';
import 'as_extension_help.dart';


class ASAudioUtils {
  // 单例实例
  static final ASAudioUtils _instance = ASAudioUtils._internal();

  factory ASAudioUtils() => _instance;

  ASAudioUtils._internal();

  // 背景音乐播放器
  final AudioPlayer _bgmPlayer = AudioPlayer();

  // 音效播放器池，避免音效重叠被打断
  final List<AudioPlayer> playerQueue = [];

  final int _maxSfxPlayers = 1;

  bool _bgmPlaying = false;

  Future<void> initTempQueue() async {
    // 初始化音效播放器池
    if (playerQueue.isEmpty) {
      for (int i = 0; i < _maxSfxPlayers; i++) {
        var audioPlayer = AudioPlayer();
        await audioPlayer.setPlayerMode(PlayerMode.lowLatency);
        await audioPlayer.setReleaseMode(ReleaseMode.stop);
        audioPlayer.setAudioContext(
            AudioContext(
                android: AudioContextAndroid(
                  isSpeakerphoneOn: true,
                  stayAwake: false,
                  contentType: AndroidContentType.music,
                  usageType: AndroidUsageType.game, // 或 media
                  audioFocus: AndroidAudioFocus.none, // ✅ 不抢焦点
                )
            ));
        playerQueue.add(audioPlayer);
      }
    }
  }

  /// 播放背景音乐，循环播放
  Future<void> playBGM({double volume = 0.6}) async {
    if(_bgmPlayer.state == PlayerState.stopped){
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(volume);
      await _bgmPlayer.play(AssetSource("cs_bg".mp3files()));
    }else if(_bgmPlayer.state == PlayerState.paused){
      await _bgmPlayer.resume();
    }
    _bgmPlaying = true;
  }

  /// 暂停背景音乐
  Future<void> pauseBGM() async {
    if (_bgmPlaying) {
      await _bgmPlayer.pause();
      _bgmPlaying = false;
    }
  }

  /// 恢复背景音乐
  Future<void> resumeBGM() async {
    if (!_bgmPlaying) {
      await _bgmPlayer.resume();
      _bgmPlaying = true;
    }
  }

  /// 停止背景音乐
  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
    _bgmPlaying = false;
  }

  Future<void> playBigwinAudio()async{
    playTempAudio("cs_bigwin".mp3files());
  }

  Future<void> playCashAudio()async{
    playTempAudio("cs_cash".mp3files());
  }

  Future<void> playGuaAudio()async{
    playTempAudio("cs_gua".mp3files());
  }

  Future<void> playWheelAudio()async{
    playTempAudio("cs_wheel".mp3files());
  }

  Future<void> playchouAudio()async{
    playTempAudio("".mp3files());
  }

  Future<void> playFaildAudio()async{
    playTempAudio("".mp3files());
  }

  Future<void> playkkAudio()async{
    playTempAudio("".mp3files());
  }

  Future<void> playDolasAudio()async{
    playTempAudio("".mp3files());
  }

  Future<void> playShaiziAudio()async{
    playTempAudio("".mp3files());
  }

  Future<void> playTempAudio(String assetPath, {double volume = 1.0}) async {
    if (!ASLocalProvider.instance.as_sound_music) {
      return;
    }
    for (final player in playerQueue) {
      if (player.state != PlayerState.playing) {
        await _safePlay(player, assetPath, volume);
        return;
      }
    }
    // 都在播放，复用第一个
    if (playerQueue.isNotEmpty) {
      await _safePlay(playerQueue.first, assetPath, volume);
    }
  }

  Future<void> _safePlay(AudioPlayer player, String assetPath, double volume) async {
    try {
      // ⭐ 关键点：彻底释放 native 资源
      await player.release();

      // 极小延迟，确保 native 层完成 teardown（可留可不留，Android 上建议保留）
      await Future.delayed(const Duration(milliseconds: 20));

      await player.setVolume(volume);
      await player.play(AssetSource(assetPath));
    } catch (e, st) {
      asLog.error("playTempAudio play error: $e\n$st");
    }
  }

  Future<void> stopAllTempAudio() async {
    for (final player in playerQueue) {
      try {
        await player.release(); // ⭐ 关键
      } catch (_) {}
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    for (final player in playerQueue) {
      await player.dispose();
    }
  }
  /// 释放资源
  Future<void> disposeBgm() async {
    await _bgmPlayer.dispose();
  }
}