import 'package:audio_recorder/saound_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audio Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Audio Recorder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Future playAduio() async {
  //   String path = 'data/user/0/com.example.audio_recorder/cache/audio';
  //   final play = await audioPlayer.play(AssetSource(path));
  //   return play;
  // }
  final audioPlayer = SaoundPlayer();

  final recorder = FlutterSoundRecorder();
  bool isRecordReady = false;

  Future initRecord() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphon permission not garanted';
    }
    await recorder.openRecorder();
    isRecordReady = true;

    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  Future record() async {
    if (!isRecordReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }

  Future stop() async {
    if (!isRecordReady) return;
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    // await audioPlayer.setSource(AssetSource('$audioFile'));
    print('Recorded audio : $audioFile');
  }

  @override
  void initState() {
    super.initState();
    initRecord();
    audioPlayer.init();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<RecordingDisposition>(
            stream: recorder.onProgress,
            builder: (context, snapshot) {
              final duration =
                  snapshot.hasData ? snapshot.data!.duration : Duration.zero;

              String twoDigitMinuts =
                  duration.inMinutes.toString().padLeft(2, '0');

              String twoDigitSeconds =
                  duration.inSeconds.toString().padLeft(2, '0');

              return Text(
                '$twoDigitMinuts:$twoDigitSeconds',
                style: TextStyle(
                    fontSize: 50,
                    color: Colors.blueGrey.shade800,
                    fontWeight: FontWeight.bold),
              );
            },
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size.fromHeight(200),
                primary: Colors.indigo.withOpacity(0.7),
                shape: const CircleBorder(),
              ),
              onPressed: () async {
                if (recorder.isRecording) {
                  await stop();
                } else {
                  await record();
                }
                setState(() {});
              },
              child: Icon(
                recorder.isRecording ? Icons.mic : Icons.mic,
                size: recorder.isRecording ? 70 : 60,
                color: recorder.isRecording ? Colors.red : Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size.fromHeight(200),
              primary: Colors.indigo.withOpacity(0.7),
              shape: const CircleBorder(),
            ),
            onPressed: () async {
              await audioPlayer.togglePlaying(whenFinished: (() {
                setState(() {});
              }));
              setState(() {});
            },
            child: Icon(
              audioPlayer.isPlaying ? Icons.stop_circle : Icons.play_circle,
              size: 60,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
