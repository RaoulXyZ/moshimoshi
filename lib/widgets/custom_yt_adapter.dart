import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CustomYTAdapter extends StatefulWidget {
  final String url;
  const CustomYTAdapter({required this.url, Key? key}) : super(key: key);

  @override
  _CustomYTAdapterState createState() => _CustomYTAdapterState();
}

class _CustomYTAdapterState extends State<CustomYTAdapter> {
  YoutubePlayerController? _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayerController.convertUrlToId(widget.url);

    if (_videoId != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: _videoId!,
        autoPlay: false,
        params: const YoutubePlayerParams(
          origin: 'https://www.youtube-nocookie.com',
          showControls: true,
          mute: false,
          showFullscreenButton: true,
          loop: false,
          strictRelatedVideos: true,
          enableJavaScript: true,
          playsInline: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Impossibile caricare il video YouTube:\n${widget.url}',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(
              controller: _controller!,
              aspectRatio: 16 / 9,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }
}
