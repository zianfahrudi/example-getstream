// ignore_for_file: inference_failure_on_instance_creation, lines_longer_than_80_chars, document_ignores, avoid_print

import 'package:flutter/material.dart';
import 'package:my_app/components/pages/audio_room_screen.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // 1. Ambil seluruh URL yang ada di browser address bar
    // Misal URL: https://myapp.com/?room_id=12345&user=admin
    final uri = Uri.base;

    // 2. Ambil spesifik parameter 'room_id'
    // queryParameters akan mengembalikan Map<String, String>
    if (uri.queryParameters.containsKey('room_id')) {
      // roomId = uri.queryParameters['room_id'];

      print("ID Ruangan ditemukan: ${uri.queryParameters['room_id']}");

      // Lakukan aksi selanjutnya, misal langsung join stream:
      // _joinStream(roomId);
    } else {
      print('Tidak ada parameter room_id');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          onPressed: createAudioRoom,
          child: const Text(
            'Join Room as Host',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _initStreamVideo() {
    final streamVideo = StreamVideo(
      'qfwdw7qpbnwq',
      user: const User(
        info: UserInfo(name: 'Admin', id: '358', role: 'speaker'),
      ),
      userToken:
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMzU4IiwiZXhwIjoxNzY1OTQ3NTc1fQ.wOrIHBuMNzitDQ7oFvLXO6tsSOEZOEKrbEuN-xW_8sw',
    );

    StreamBackgroundService.init(streamVideo);
  }

  Future<void> createAudioRoom() async {
    await StreamVideo.reset();
    _initStreamVideo();

    // Set up our call object
    final call = StreamVideo.instance.makeCall(
      callType: StreamCallType.liveStream(),
      id: 'de6b0851-a3cc-4800-8065-76e3c0428656',
    );

    final connectOptions = CallConnectOptions(
      microphone: TrackOption.enabled(),
    );
    await call.join(connectOptions: connectOptions);
    // Create the call and set the current user as a host
    final result = await call
        .getOrCreate(
          members: [
            MemberRequest(
              userId: StreamVideo.instance.currentUser.id,
              role: 'host',
            ),
          ],
        )
        .timeout(
          const Duration(seconds: 30),
        );

    await result.fold(
      success: (val) async {
        // Set some default behaviour for how our devices should be configured once we join a call.
        // Note that the camera will be disabled by default because of the `audio_room` call type configuration.

        // final connectOptions = CallConnectOptions(
        //   microphone: TrackOption.enabled(),
        // );
        // await call.join(connectOptions: connectOptions);
        // Allow others to see and join the call (exit backstage mode)
        // await call.goLive();

        // await call.join(connectOptions: connectOptions);
        // final result = await call.end();

        // if (result.isSuccess) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text('Call ended successfully.'),
        //     ),
        //   );
        // }
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AudioRoomScreen(
              audioRoomCall: call,
            ),
          ),
        );
      },
      failure: (val) {
        debugPrint('Not able to create a call.');
      },
    );

    // if (result.isSuccess) {
    //   // Set some default behaviour for how our devices should be configured once we join a call.
    //   // Note that the camera will be disabled by default because of the `audio_room` call type configuration.
    //   // final connectOptions = CallConnectOptions(
    //   //   microphone: TrackOption.enabled(),
    //   // );

    //   // await call.join(connectOptions: connectOptions);
    //   //
    //   // Allow others to see and join the call (exit backstage mode)
    //   await call.goLive();

    //   await Navigator.of(context).push(
    //     MaterialPageRoute(
    //       builder: (context) => AudioRoomScreen(
    //         audioRoomCall: call,
    //       ),
    //     ),
    //   );
    // } else {
    //   debugPrint('Not able to create a call.');
    // }
  }
}
