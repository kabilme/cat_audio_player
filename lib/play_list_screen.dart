import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'dart:io';

import 'audio_provider.dart';

class PlayListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: true);

    return Container(
      child: Column(
        children: [
          SizedBox(height: 10),
          SizedBox(
            height: 75,
            child: Card(
              elevation: 10,
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Color.fromARGB(255, 46, 43, 236),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        _showSavePlaylistDialog(context, audioProvider);
                      },
                      icon: Icon(
                        Icons.save,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Implement open playlist functionality
                        _showOpenPlaylistDialog(context, audioProvider);
                      },
                      icon: Icon(
                        Icons.folder,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Implement clear playlist functionality
                        _clearPlaylist(context, audioProvider);
                      },
                      icon: Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 600, // Set your desired height here
            child: Card(
              elevation: 30,
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Color.fromARGB(174, 202, 146, 174),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  const Text(
                    'Playlist:',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 46, 43, 236),
                      fontSize: 22.0,
                    ),
                  ),
                  // Embed the playlist inside a vertically scrollable card
                  Expanded(
                    child: ListView.builder(
                      itemCount: audioProvider.playlist.length,
                      itemBuilder: (context, index) {
                        // Check if the index is even or odd to determine background color
                        bool isEvenIndex = index % 2 == 0;

                        return Container(
                          color: isEvenIndex
                              ? Colors.grey[300]
                              : Colors.white, // Set alternate colors
                          child: ListTile(
                            title: Text(
                              audioProvider.playlist[index].split('/').last,
                              style: TextStyle(
                                color: Colors.black, // Set text color
                              ),
                            ),
                            onTap: () =>
                                _playSelectedAudio(index, audioProvider),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showOpenPlaylistDialog(
      BuildContext context, AudioProvider audioProvider) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? playlistNames = prefs.getStringList('playlistNames');

    if (playlistNames != null && playlistNames.isNotEmpty) {
      // ignore: use_build_context_synchronously
      String? selectedPlaylistName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Open Playlist'),
            content: Column(
              children: [
                ...playlistNames.map((playlistName) {
                  return ListTile(
                    title: Text(playlistName),
                    onTap: () {
                      Navigator.of(context).pop(playlistName);
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        // Implement delete playlist functionality
                        await _deletePlaylist(context, playlistName);
                        // After deletion, update the dialog content
                        Navigator.of(context).pop();
                        _showOpenPlaylistDialog(context, audioProvider);
                      },
                    ),
                  );
                }).toList(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cancel option
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          );
        },
      );

      if (selectedPlaylistName != null) {
        // Load the selected playlist from SharedPreferences
        List<String>? playlist =
            prefs.getStringList('playlist_$selectedPlaylistName');

        if (playlist != null && playlist.isNotEmpty) {
          // Update the playlist in your LocalAudioScreen
          audioProvider.setPlaylist(playlist);
          audioProvider.setSelectedFilePath(playlist.first);

          // Open the playlist in the audio player
          audioProvider.assetsAudioPlayer.open(
            Playlist(
              audios: playlist.map((path) => Audio.file(path)).toList(),
              startIndex: 0,
            ),
            autoStart: true,
            showNotification: true,
          );

          audioProvider.assetsAudioPlayer.current.listen((playingAudio) {
            if (playingAudio != null) {
              _loadAlbumArt(playingAudio.audio.audio.path, audioProvider);
            }
          });
        }
      }
    } else {
      // Show a message that there are no saved playlists
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Saved Playlists'),
            content: Text('There are no saved playlists.'),
          );
        },
      );
    }
  }

  void _clearPlaylist(BuildContext context, AudioProvider audioProvider) async {
    // Stop the playlist audio player
    audioProvider.assetsAudioPlayer.stop();

    /*
    // Clear the playlist
    audioProvider.assetsAudioPlayer.open(
      Playlist(),
      autoStart: false,
      showNotification: true,
    );
      */
    audioProvider.assetsAudioPlayer.open(
      Playlist(audios: [], startIndex: 0),
      autoStart: false, // Set to true if you want to start playing immediately
      loopMode: LoopMode.none, // Set loop mode if needed
    );
    audioProvider.setPlaylist([]);
    audioProvider.setAlbumArt(null);
    // Show a message indicating the playlist has been cleared
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playlist cleared.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deletePlaylist(
      BuildContext context, String playlistName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Delete the playlist from the list of playlist names
    List<String>? playlistNames = prefs.getStringList('playlistNames');
    playlistNames?.remove(playlistName);
    prefs.setStringList('playlistNames', playlistNames ?? []);

    // Delete the playlist from SharedPreferences
    prefs.remove('playlist_$playlistName');
  }

  void _playSelectedAudio(int index, AudioProvider audioProvider) {
    if (audioProvider.playlist.isNotEmpty &&
        index >= 0 &&
        index < audioProvider.playlist.length) {
      audioProvider.setSelectedFilePath(audioProvider.playlist[index]);

      audioProvider.assetsAudioPlayer.open(
        Playlist(
          audios: audioProvider.playlist
              .map((path) => Audio.file(path))
              .toList(growable: false),
          startIndex: index,
        ),
        autoStart: true,
        showNotification: true,
      );

      audioProvider.assetsAudioPlayer.current.listen((playingAudio) {
        if (playingAudio != null) {
          _loadAlbumArt(playingAudio.audio.audio.path, audioProvider);
        }
      });
    }
  }

  Future<void> _loadAlbumArt(
      String filePath, AudioProvider audioProvider) async {
    try {
      final metadata = await MetadataRetriever.fromFile(File(filePath));
      audioProvider.setAlbumArt(metadata.albumArt);
    } on PlatformException catch (e) {
      print("Error loading album art: $e");
    }
  }

  Future<void> _showSavePlaylistDialog(
      BuildContext context, AudioProvider audioProvider) async {
    TextEditingController playlistNameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save Playlist'),
          content: TextField(
            controller: playlistNameController,
            decoration: InputDecoration(labelText: 'Enter Playlist Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _savePlaylist(
                    playlistNameController.text, audioProvider, context);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePlaylist(String playlistName, AudioProvider audioProvider,
      BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save the playlist name to the list of playlist names
    List<String>? playlistNames = prefs.getStringList('playlistNames') ?? [];
    playlistNames.add(playlistName);
    prefs.setStringList('playlistNames', playlistNames);

    // Save the current playlist to SharedPreferences
    // List<String> playlist = _playlist;
    prefs.setStringList('playlist_$playlistName', audioProvider.playlist);
    // Update the local state

    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Playlist Saved'),
          content: Text('Playlist "$playlistName" has been saved.'),
        );
      },
    );
  }
}
