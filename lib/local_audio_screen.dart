import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'dart:io';

import 'audio_provider.dart';

class LocalAudioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: true);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (audioProvider.albumArt != null)
              Card(
                elevation: 25,
                margin: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                child: Image.memory(
                  audioProvider.albumArt!,
                  width: 300,
                  height: 300,
                ),
              ),
            if (audioProvider.albumArt == null)
              Container(
                width: 300,
                height: 300,
                color: Colors.grey,
                child: Card(
                  elevation: 50,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: const Center(
                    child: Text(
                      'No AlbumArt',
                      style: TextStyle(fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _pickAndLoadFile(audioProvider);
              },
              child: Text('Load Audio Files'),
              style: ElevatedButton.styleFrom(
                elevation: 25,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 25,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              color: Colors.pinkAccent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    onPressed: () {
                      audioProvider.assetsAudioPlayer.previous();
                    },
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: StreamBuilder<bool>(
                      stream: audioProvider.assetsAudioPlayer.isPlaying,
                      builder: (context, snapshot) {
                        bool isPlaying = snapshot.data ?? false;
                        return Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 25,
                        );
                      },
                    ),
                    onPressed: () {
                      audioProvider.assetsAudioPlayer.playOrPause();
                    },
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    onPressed: () {
                      audioProvider.assetsAudioPlayer.next();
                    },
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 25,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              color: Colors.greenAccent,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  StreamBuilder<RealtimePlayingInfos>(
                    stream:
                        audioProvider.assetsAudioPlayer.realtimePlayingInfos,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox.shrink();
                      }

                      RealtimePlayingInfos infos = snapshot.data!;

                      return Column(
                        children: [
                          Consumer<AudioProvider>(
                            builder: (context, audioProvider, child) {
                              final realtimePlayingInfos = audioProvider
                                  .assetsAudioPlayer.realtimePlayingInfos;

                              // Check if the stream has a value before accessing it
                              if (realtimePlayingInfos.hasValue) {
                                final info = realtimePlayingInfos.value;

                                final currentPosition =
                                    info.currentPosition.inSeconds.toDouble();

                                return Column(
                                  children: [
                                    Slider(
                                      value: infos
                                          .currentPosition.inMilliseconds
                                          .toDouble()
                                          .clamp(
                                              0.0,
                                              (infos.duration.inMilliseconds
                                                          .toDouble() >
                                                      0)
                                                  ? infos
                                                      .duration.inMilliseconds
                                                      .toDouble()
                                                  : 1.0),
                                      onChanged: (value) {
                                        audioProvider.assetsAudioPlayer.seek(
                                            Duration(
                                                milliseconds: value.toInt()));
                                      },
                                      min: 0.0,
                                      max: (infos.duration.inMilliseconds
                                                  .toDouble() >
                                              0)
                                          ? infos.duration.inMilliseconds
                                              .toDouble()
                                          : 1.0,
                                      activeColor: Colors.blue,
                                      inactiveColor: Colors.grey,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${formatDuration(Duration(seconds: currentPosition.toInt()))}',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        Text(
                                          '${formatDuration(info.duration)}',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                // Return a default value if the stream has no value
                                return Slider(
                                  value: 0.0,
                                  onChanged: null,
                                  min: 0.0,
                                  max: 1.0,
                                );
                              }
                            },
                          ), //end
                          SizedBox(height: 20),
                          Text(
                            //'Playing: ${infos.current?.audio.audio.metas.title ?? infos.current?.audio.audio.path ?? 'Unknown Title'}',

                            // 'Playing: ${infos.current?.audio.audio.metas.title ?? 'Unknown Title'}',
                            // 'Playing: ${fileName}',
                            // 'Playing: ${_getFileName(infos.current?.audio.audio.path) ?? 'Unknown Title'}',
                            'Playing: ${_getFileName(infos.current?.audio.audio.path)}',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ), //end
          ],
        ),
      ),
    );
  }

  String _getFileName(String? filePath) {
    if (filePath != null) {
      List<String> pathSegments = filePath.split('/');
      return pathSegments.isNotEmpty ? pathSegments.last : 'Unknown Title';
    }
    return 'Unknown Title';
  }

  Future<void> _loadAlbumArt(
      String filePath, AudioProvider audioProvider) async {
    try {
      final metadata = await MetadataRetriever.fromFile(File(filePath));
      audioProvider.setAlbumArt(metadata.albumArt);
    } on PlatformException catch (e) {
      // print("Error loading album art: $e");
    }
  }

  Future<void> _pickAndLoadFile(AudioProvider audioProvider) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      List<String> playlist = result.files.map((file) => file.path!).toList();
      audioProvider.setPlaylist(playlist);
      audioProvider.setSelectedFilePath(playlist.first);
      _playAudio(audioProvider);

      audioProvider.assetsAudioPlayer.current.listen((playingAudio) {
        if (playingAudio != null) {
          _loadAlbumArt(playingAudio.audio.audio.path, audioProvider);
        }
      });
    }
  }

  void _playAudio(AudioProvider audioProvider) {
    if (audioProvider.playlist.isNotEmpty) {
      int playlistIndex =
          audioProvider.playlist.indexOf(audioProvider.selectedFilePath);

      audioProvider.assetsAudioPlayer.open(
        Playlist(
          audios: audioProvider.playlist
              .map((path) => Audio.file(path))
              .toList(growable: false),
          startIndex: playlistIndex,
        ),
        autoStart: true,
        showNotification: true,
      );
    } else {
      // Handle the case where no file is selected
      // print("No files in the playlist");
    }
  }

  String formatDuration(Duration duration) {
    // Format the duration as HH:mm:ss
    return '${duration.inHours.toString().padLeft(2, '0')}:'
        '${(duration.inMinutes.remainder(60)).toString().padLeft(2, '0')}:'
        '${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
  }
/*
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours}:${twoDigitMinutes}:${twoDigitSeconds}';
  }*/
}
