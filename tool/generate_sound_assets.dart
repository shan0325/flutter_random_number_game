import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const sampleRate = 44100;

void main() {
  Directory('assets').createSync(recursive: true);

  _writeWave(
    'assets/countdown_tick.wav',
    _tone(
      0.11,
      (time, progress) =>
          sin(2 * pi * 880 * time) *
          _envelope(progress, attack: 0.03, release: 0.55) *
          0.42,
    ),
  );
  _writeWave(
    'assets/countdown_go.wav',
    _tone(
      0.2,
      (time, progress) =>
          (sin(2 * pi * 1175 * time) * 0.7 + sin(2 * pi * 1568 * time) * 0.3) *
          _envelope(progress, attack: 0.025, release: 0.45) *
          0.4,
    ),
  );
  _writeWave(
    'assets/wrong_tap.wav',
    _tone(0.22, (time, progress) {
      final pulse = time < 0.095 || (time > 0.125 && time < 0.22) ? 1 : 0;
      final frequency = time < 0.11 ? 210 : 165;
      return sin(2 * pi * frequency * time) *
          _envelope(progress, attack: 0.02, release: 0.2) *
          pulse *
          0.42;
    }),
  );
  _writeWave(
    'assets/game_complete.wav',
    _tone(0.62, (time, progress) {
      const notes = [523.25, 659.25, 783.99, 1046.5];
      final noteIndex = min(3, (time / 0.145).floor());
      final localProgress = ((time - noteIndex * 0.145) / 0.145).clamp(
        0.0,
        1.0,
      );
      final frequency = notes[noteIndex];
      final envelope = _envelope(
        localProgress,
        attack: 0.04,
        release: 0.45,
      );
      return (sin(2 * pi * frequency * time) * 0.75 +
              sin(2 * pi * frequency * 2 * time) * 0.25) *
          envelope *
          0.34;
    }),
  );
}

List<double> _tone(
  double durationSeconds,
  double Function(double time, double progress) sample,
) {
  final sampleCount = (durationSeconds * sampleRate).floor();
  return List.generate(
    sampleCount,
    (index) => sample(index / sampleRate, index / sampleCount),
  );
}

double _envelope(
  double progress, {
  required double attack,
  required double release,
}) {
  final attackLevel = min(1.0, progress / attack);
  final releaseLevel = min(1.0, (1 - progress) / release);
  return max(0, min(attackLevel, releaseLevel));
}

void _writeWave(String path, List<double> samples) {
  const headerSize = 44;
  final dataSize = samples.length * 2;
  final bytes = ByteData(headerSize + dataSize);

  _writeText(bytes, 0, 'RIFF');
  bytes.setUint32(4, 36 + dataSize, Endian.little);
  _writeText(bytes, 8, 'WAVE');
  _writeText(bytes, 12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, 1, Endian.little);
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, sampleRate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  _writeText(bytes, 36, 'data');
  bytes.setUint32(40, dataSize, Endian.little);

  for (var index = 0; index < samples.length; index++) {
    final value = (samples[index].clamp(-1.0, 1.0) * 32767).round();
    bytes.setInt16(headerSize + index * 2, value, Endian.little);
  }

  File(path).writeAsBytesSync(bytes.buffer.asUint8List());
}

void _writeText(ByteData bytes, int offset, String text) {
  for (var index = 0; index < text.length; index++) {
    bytes.setUint8(offset + index, text.codeUnitAt(index));
  }
}
