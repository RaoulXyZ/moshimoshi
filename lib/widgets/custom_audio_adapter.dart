import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class CustomAudioAdapter extends StatefulWidget {
  const CustomAudioAdapter({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  _CustomAudioAdapterState createState() => _CustomAudioAdapterState();
}

class _CustomAudioAdapterState extends State<CustomAudioAdapter> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // Configure the audio session for speech
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());

      // Listen for completion to rewind the audio
      _player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          _player.seek(Duration.zero);
          _player.pause();
        }
      });

      // Set the audio source from the provided URL
      await _player.setAudioSource(AudioSource.uri(Uri.parse(widget.url)));
    } catch (e) {
      log('Error initializing audio: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = playerState?.playing ?? false;

        return StreamBuilder<Duration>(
          stream: _player.positionStream,
          builder: (context, posSnapshot) {
            final position = posSnapshot.data ?? Duration.zero;
            final duration = _player.duration ?? Duration.zero;

            return Row(
              children: [
                IconButton(
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (playing) {
                      _player.pause();
                    } else {
                      _player.play();
                    }
                  },
                ),
                Column(
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_formatDuration(duration)),
                  ],
                ),
                Expanded(
                  child: SliderTheme(
                    data: const SliderThemeData(
                      inactiveTrackColor: Colors.grey,
                      trackHeight: 1,
                      trackShape: RectangularSliderTrackShape(),
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 5.0),
                    ),
                    child: Slider(
                      value: position.inSeconds.toDouble(),
                      min: 0,
                      max: duration.inSeconds.toDouble() > 0
                          ? duration.inSeconds.toDouble()
                          : 1,
                      onChanged: (value) {
                        _player.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
  String valueSuffix = '',
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) {
          final currentValue = snapshot.data ?? value;

          return SizedBox(
            height: 100.0,
            child: Column(
              children: [
                Text(
                  '${currentValue.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                    fontFamily: 'Fixed',
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                Slider(
                  divisions: divisions,
                  min: min,
                  max: max,
                  value: currentValue,
                  onChanged: onChanged,
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
