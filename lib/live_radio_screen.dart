import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import 'audio_provider.dart';

class LiveRadioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: true);

    return Column(
      children: [
        SizedBox(height: 10),
        Card(
          color: Colors.cyan,
          elevation: 5,
          margin: EdgeInsets.only(left: 14, right: 10, bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Wrap(
            children: [
              _buildStationCard(
                  'Hello FM',
                  '106.4 MHz',
                  'https://strw1.openstream.co/1313?aw_0_1st.collectionid%3D4428%26stationId%3D4428%26publisherId%3D1337%26k%3D1692506589',
                  audioProvider),
              _buildStationCard('Suriyan FM', '93.5 MHz',
                  'https://tamil.crabdance.com:8002/2', audioProvider),
              _buildStationCard('Radio Mirche', '98.3 MHz',
                  'https://strw1.openstream.co/705', audioProvider),
              _buildStationCard('Radio City', '91.1 MHz',
                  'https://strw1.openstream.co/1311', audioProvider),
              _buildStationCard(
                  'Radio Gilli',
                  '106.5 MHz',
                  'https://securestreams7.autopo.st/?uri=http://live.rcast.net:8694/stream?type=http&nocache=11',
                  audioProvider),
              _buildStationCard('Illaya Raja Hits', '',
                  'https://sp14.instainternet.com/8090/stream', audioProvider),
              _buildStationCard(
                  'Ar Rahman Hits',
                  '',
                  'https://www.liveradio.es/http://stream.zeno.fm/ihpr0rqzoxquv',
                  audioProvider),
              _buildStationCard('Mohan Hits', '',
                  'https://stream.zeno.fm/wkqvzsg1238uv', audioProvider),
              _buildStationCard('Haris Jayaraj Hits', '',
                  'https://stream.zeno.fm/0bhsthssutzuv', audioProvider),
            ],
          ),
        ),
        // Display current playing radio station information only if live streaming is playing
        // if (audioProvider.audioPlayer.isPlaying.value)
        _buildStationInfoCard(audioProvider),
        if (audioProvider.isStreaming) CircularProgressIndicator(),
        Card(
          elevation: 5,
          color: Colors.blueAccent,
          margin: EdgeInsets.only(left: 14, right: 10, bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: SizedBox(
            width: 220, // Set a fixed width or adjust as needed

            child: ListTile(
              title: Text(
                'Stop Playing Live Radio',
                style: TextStyle(color: Colors.pink),
              ),
              onTap: () {
                _stopLiveRadio(audioProvider);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _stopLiveRadio(AudioProvider audioProvider) {
    audioProvider.assetsAudioPlayer.stop();

    // Stop playlist audio if playing
    // Handle stopping live streaming audio
  }

  Widget _buildStationCard(String stationName, String subTitle, String url,
      AudioProvider audioProvider) {
    return Card(
      color: Colors.grey, // Customize the card color
      child: SizedBox(
        width: 110.0, // Set a fixed width or adjust as needed
        child: ListTile(
          title: Text(
            stationName,
            style: TextStyle(color: Colors.pink),
          ),
          subtitle: Text(
            subTitle,
            style: TextStyle(color: Colors.pink),
          ),
          onTap: () {
            _playLiveRadio(url, audioProvider);

            audioProvider.setRadioInfo(stationName, subTitle);
          },
        ),
      ),
    );
  }

  Widget _buildStationInfoCard(AudioProvider audioProvider) {
    return Card(
      color: Color.fromARGB(255, 145, 1, 49),
      elevation: 5,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Current Station:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Name: ${audioProvider.stationName}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Frequency: ${audioProvider.frequency}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playLiveRadio(String radioUrl, AudioProvider audioProvider) {
    audioProvider.assetsAudioPlayer.stop();
    audioProvider.setIsStreaming(true); // Set streaming status to true
    // Play the stream
    audioProvider.assetsAudioPlayer.open(
      Audio.liveStream(radioUrl),
      showNotification: true,
      playInBackground: PlayInBackground.enabled,
    );

    // Set up a listener to stop the loading indicator when audio starts playing
    audioProvider.assetsAudioPlayer.isPlaying.listen((isPlaying) {
      if (isPlaying) {
        audioProvider.setIsStreaming(false);
      }
    });
  }
}
