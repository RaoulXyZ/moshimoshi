// import 'package:flutter/material.dart';

// import 'package:flutter/services.dart';

// import './custom_audio_adapter.dart';

/*
class CustomVideoAdapter extends StatefulWidget {
  final String src;
  CustomVideoAdapter(this.src);

  @override
  _CustomVideoAdapterState createState() => _CustomVideoAdapterState();
}

class _CustomVideoAdapterState extends State<CustomVideoAdapter> {
  late BetterPlayerController _betterPlayerController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    BetterPlayerDataSource betterPlayerDataSource =
        BetterPlayerDataSource(BetterPlayerDataSourceType.network, widget.src);

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        controlsConfiguration: BetterPlayerControlsConfiguration(
          qualitiesIcon: Icons.high_quality,
          loadingColor: Theme.of(context).primaryColor,
          progressBarPlayedColor: Theme.of(context).primaryColor,
          progressBarBufferedColor:
              Theme.of(context).primaryColor.withOpacity(0.25),
          progressBarBackgroundColor: Colors.grey.withOpacity(0.5),
          progressBarHandleColor:
              Theme.of(context).primaryColor, //pallino progress bar
          playbackSpeedIcon: Icons.timer,
          enableSkips: true,
          enablePip: true,
          unMuteIcon: Icons.volume_off,
          enableQualities: true,
          enableAudioTracks: false,
        ),
        fit: BoxFit.contain,
        autoDetectFullscreenDeviceOrientation: true,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        aspectRatio: 16 / 9,
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );

    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized)
        setState(() => _betterPlayerController.setOverriddenAspectRatio(
            _betterPlayerController.videoPlayerController!.value.aspectRatio));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_betterPlayerController.getAspectRatio() == null)
      return CustomAudioAdapter(widget.src);

    if (_betterPlayerController.getAspectRatio()!.isNaN)
      return CustomAudioAdapter(widget.src);

    return Container(
      alignment: Alignment.topCenter,
      child: AspectRatio(
        aspectRatio: 16 / 9, //_betterPlayerController.getAspectRatio(),
        child: BetterPlayer(
          controller: _betterPlayerController,
        ),
      ),
    );
  }
}
*/