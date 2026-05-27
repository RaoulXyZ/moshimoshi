import 'package:html/parser.dart';

void extractImgs(List<String> _imgSources, String _originalString) {
  final document = parse(_originalString);
  final _imgs = document.querySelectorAll('img');
  for (int i = 0; i < _imgs.length; i++) {
    _imgSources.add(_imgs[i].attributes['src']!);
  }
}

void extractVideos(
  List<String> _videoSources,
  List<String> _ytSoruces,
  String _originalString,
) {
  final document = parse(_originalString);
  final _videos = document.querySelectorAll('video');
  for (int i = 0; i < _videos.length; i++) {
    _videoSources.add(
      _videos[i].getElementsByTagName('source').first.attributes['src']!,
    );
  }

  final _yt = document.querySelectorAll('iframe');
  for (int i = 0; i < _yt.length; i++) {
    _ytSoruces.add(_yt[i].attributes['src']!);
  }
}

void extractAudios(List<String> _audioSources, String _originalString) {
  final document = parse(_originalString);
  final _videos = document.querySelectorAll('audio');
  for (int i = 0; i < _videos.length; i++) {
    _audioSources.add(
      _videos[i].getElementsByTagName('source').first.attributes['src']!,
    );
  }
}

/*
Map<String, dynamic> getChoices(Map<String, dynamic> _element) {
  log('getChoices received element:');
  _element.forEach((key, value) {
    log(' - $key: $value');
  });

  final _recodeValues = _element['RecodeValues'] ?? {};
  final Map<String, dynamic> _localChoices = {};
  for (int k = 0; k < _element['Choices'].length; k++) {
    final String _key = _element['ChoiceOrder'][k].toString();
    if (_recodeValues.isNotEmpty &&
        _recodeValues.keys.length == _element['Choices'].length) {
      log(_recodeValues[_key]);

      // final int _key = _element['ChoiceOrder'][k];
      _localChoices.putIfAbsent(
        _recodeValues[_key].toString(),
        () => _element['Choices'][_key],
      );
    } else {
      _localChoices.putIfAbsent(_key, () => _element['Choices'][_key]);
    }
  }

  return _localChoices;
} */

Map<String, dynamic> getChoices(Map<String, dynamic> _element) {
  final Map<String, dynamic> _localChoices = {};
  for (int k = 0; k < _element['Choices'].length; k++) {
    final String _key = _element['ChoiceOrder'][k].toString();
    // final int _choiceIndex = int.parse(_key);
    try {
      _localChoices.putIfAbsent(_key, () => _element['Choices'][_key]);
    } catch (Exception) {
      final int _choiceIndex = int.parse(_key);
      _localChoices.putIfAbsent(_key, () => _element['Choices'][_choiceIndex]);
    }
  }

  return _localChoices;
}

bool equalsIgnoreCase(String? a, String? b) =>
    (a == null && b == null) ||
    (a != null && b != null && a.toLowerCase() == b.toLowerCase());

int daysDiff(DateTime d1, DateTime d2) {
  final Duration diff = d1.difference(d2);

  return diff.inDays;
}

final String baseFileUrl =
    "https://psicologiaunimib.qualtrics.com/WRQualtricsSurveyEngine/File.php?F=";
