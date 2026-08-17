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

  final int _maxSfxPlayers = 2;

  bool _bgmPlaying = false;
  AudioPlayer? _scratchPlayer;
  Future<void>? _scratchPrepareFuture;
  AudioPlayer? _dollarPlayer;
  Future<void>? _dollarPrepareFuture;

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
            ),
          ),
        );
        playerQueue.add(audioPlayer);
      }
    }
  }

  /// 播放背景音乐，循环播放
  Future<void> playBGM({double volume = 0.6}) async {
    if (!ASLocalProvider.instance.as_bg_music) return;
    if (_bgmPlayer.state == PlayerState.stopped) {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(volume);
      await _bgmPlayer.play(AssetSource('File/bgm.mp3'));
    } else if (_bgmPlayer.state == PlayerState.paused) {
      await _bgmPlayer.resume();
    }
    _bgmPlaying = true;
  }

  /// 暂停背景音乐
  Future<void> pauseBGM() async {
    if (_bgmPlaying || _bgmPlayer.state == PlayerState.playing) {
      await _bgmPlayer.pause();
      _bgmPlaying = false;
    }
  }

  /// 恢复背景音乐
  Future<void> resumeBGM() async {
    await playBGM();
  }

  /// 停止背景音乐
  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
    _bgmPlaying = false;
  }

  Future<void> playBigwinAudio() async {
    await playTempAudio('File/reward_stage_3.wav');
  }

  Future<void> playCashAudio() async {
    await playTempAudio('File/reward_stage_1.mp3');
  }

  Future<void> playRewardStage2Audio() async {
    await playTempAudio('File/reward_stage_2.wav');
  }

  /// 300/700 金额达到时的运营弹窗
  Future<void> playOperationAudio() async {
    await playTempAudio('File/operation_3.mp3');
  }

  Future<void> playGuaAudio() async {
    if (!ASLocalProvider.instance.as_sound_music) return;
    try {
      await prepareScratchAudio();
      final player = _scratchPlayer;
      if (player == null) return;
      await player.stop();
      await player.resume();
    } catch (e, st) {
      asLog.error("playGuaAudio play error: $e\n$st");
    }
  }

  Future<void> prepareScratchAudio() {
    final pending = _scratchPrepareFuture;
    if (pending != null) return pending;
    final future = _prepareScratchAudio();
    _scratchPrepareFuture = future;
    return future;
  }

  Future<void> _prepareScratchAudio() async {
    if (_scratchPlayer != null) return;
    try {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
      await player.setVolume(1);
      await player.setSource(AssetSource('File/scratch.mp3'));
      // 预热底层播放通道，避免首次自动刮卡时出现明显的冷启动延迟。
      await player.setVolume(0);
      await player.resume();
      await Future.delayed(const Duration(milliseconds: 40));
      await player.stop();
      await player.setVolume(1);
      _scratchPlayer = player;
    } catch (e, st) {
      _scratchPrepareFuture = null;
      asLog.error("prepareScratchAudio error: $e\n$st");
      rethrow;
    }
  }

  Future<void> prepareDolasAudio() {
    final pending = _dollarPrepareFuture;
    if (pending != null) return pending;
    final future = _prepareDolasAudio();
    _dollarPrepareFuture = future;
    return future;
  }

  Future<void> _prepareDolasAudio() async {
    if (_dollarPlayer != null) return;
    try {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
      await player.setVolume(1);
      await player.setSource(AssetSource('File/flying_money.mp3'));
      // 预热底层播放通道，避免飞钱音效首次播放时无声或延迟。
      await player.setVolume(0);
      await player.resume();
      await Future.delayed(const Duration(milliseconds: 40));
      await player.stop();
      await player.setVolume(1);
      _dollarPlayer = player;
    } catch (e, st) {
      _dollarPrepareFuture = null;
      asLog.error("prepareDolasAudio error: $e\n$st");
      rethrow;
    }
  }

  Future<void> playWheelAudio() async {
    await playTempAudio('File/wheel.mp3');
  }

  Future<void> playchouAudio() async {
    await playTempAudio('File/box_open.mp3');
  }

  Future<void> playFaildAudio() async {
    await playTempAudio('File/scratch_fail.mp3');
  }

  Future<void> playErrorCommonAudio() async {
    await playTempAudio('File/error_common.mp3');
  }

  Future<void> playDolasAudio() async {
    if (!ASLocalProvider.instance.as_sound_music) return;
    try {
      await prepareDolasAudio();
      final player = _dollarPlayer;
      if (player == null) return;
      await player.stop();
      await player.resume();
    } catch (e, st) {
      asLog.error("playDolasAudio play error: $e\n$st");
    }
  }

  Future<void> playShaiziAudio() async {
    await playTempAudio('File/dice_roll.mp3');
  }

  Future<void> playDiceStepAudio() async {
    await playTempAudio('File/dice_step.mp3');
  }

  Future<void> playTempAudio(String assetPath, {double volume = 1.0}) async {
    if (!ASLocalProvider.instance.as_sound_music) {
      return;
    }
    await initTempQueue();
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

  Future<void> _safePlay(
    AudioPlayer player,
    String assetPath,
    double volume,
  ) async {
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
    final scratchPlayer = _scratchPlayer;
    if (scratchPlayer != null) {
      try {
        await scratchPlayer.stop();
      } catch (_) {}
    }
    for (final player in playerQueue) {
      try {
        await player.release(); // ⭐ 关键
      } catch (_) {}
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    final scratchPlayer = _scratchPlayer;
    if (scratchPlayer != null) {
      await scratchPlayer.dispose();
      _scratchPlayer = null;
    }
    final dollarPlayer = _dollarPlayer;
    if (dollarPlayer != null) {
      await dollarPlayer.dispose();
      _dollarPlayer = null;
    }
    for (final player in playerQueue) {
      await player.dispose();
    }
  }

  /// 释放资源
  Future<void> disposeBgm() async {
    await _bgmPlayer.dispose();
  }
}
