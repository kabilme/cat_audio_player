import 'package:flutter/material.dart';
import 'live_radio_screen.dart';
import 'play_list_screen.dart';
import 'local_audio_screen.dart';

class ScreenNavigator extends StatefulWidget {
  @override
  _ScreenNavigatorState createState() => _ScreenNavigatorState();
}

class _ScreenNavigatorState extends State<ScreenNavigator> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cat Audio Player'),
        backgroundColor: Colors.indigo,
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'LocalAudio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: 'PlayList',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radio),
            label: 'LiveRadio',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return LocalAudioScreen();
      case 1:
        return PlayListScreen();
      case 2:
        return LiveRadioScreen();
      default:
        return Container(); // Handle additional cases if needed
    }
  }
}
