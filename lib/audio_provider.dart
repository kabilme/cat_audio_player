import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/services.dart';

class AudioProvider with ChangeNotifier {
  Uint8List? albumArt;
  List<String> playlist = [];
  String selectedFilePath = '';
  String stationName = '';
  String frequency = '';
  bool isStreaming = false;
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  // Define a default image path
  static const String defaultImagePath = 'assets/playstore.png';
  AudioProvider() {
    // Load the default image during initialization
    _loadDefaultImage();
  }

  void setAlbumArt(Uint8List? albArt) {
    albumArt = albArt;
    notifyListeners();
  }

// Method to load the default image
  Future<void> _loadDefaultImage() async {
    // Load default image from an asset
    ByteData data = await rootBundle.load(defaultImagePath);
    List<int> bytes = data.buffer.asUint8List();

    // Set the default image as the album art
    setAlbumArt(Uint8List.fromList(bytes));
  }

  void setPlaylist(List<String> plist) {
    playlist = plist;
    notifyListeners();
  }

  void setSelectedFilePath(String path) {
    selectedFilePath = path;
    notifyListeners();
  }

  void setRadioInfo(String stName, String stFreq) {
    stationName = stName;
    frequency = stFreq;
    notifyListeners();
  }

  void setIsStreaming(bool isstreaming) {
    isStreaming = isstreaming;
    notifyListeners();
  }
}
