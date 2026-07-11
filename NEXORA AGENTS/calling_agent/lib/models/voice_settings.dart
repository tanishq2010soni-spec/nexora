class VoiceSettings {
  final String sttProvider;
  final String ttsProvider;
  final String vadProvider;
  final String voice;
  final double speed;
  final double pitch;
  final String emotion;

  const VoiceSettings({
    this.sttProvider = 'default',
    this.ttsProvider = 'default',
    this.vadProvider = 'default',
    this.voice = 'default',
    this.speed = 1.0,
    this.pitch = 1.0,
    this.emotion = 'neutral',
  });

  factory VoiceSettings.fromJson(Map<String, dynamic> json) {
    return VoiceSettings(
      sttProvider: json['stt_provider'] as String? ?? 'default',
      ttsProvider: json['tts_provider'] as String? ?? 'default',
      vadProvider: json['vad_provider'] as String? ?? 'default',
      voice: json['voice'] as String? ?? 'default',
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      emotion: json['emotion'] as String? ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stt_provider': sttProvider,
      'tts_provider': ttsProvider,
      'vad_provider': vadProvider,
      'voice': voice,
      'speed': speed,
      'pitch': pitch,
      'emotion': emotion,
    };
  }
}
