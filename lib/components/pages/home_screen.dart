// ignore_for_file: use_build_context_synchronously, inference_failure_on_instance_creation, lines_longer_than_80_chars, document_ignores

import 'package:flutter/material.dart';
import 'package:my_app/components/pages/audio_room_screen.dart';
import 'package:stream_video/stream_video.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: createAudioRoom,
          child: const Text('Create an Audio Room'),
        ),
      ),
    );
  }

  Future<void> createAudioRoom() async {
    // Set up our call object
    final call = StreamVideo.instance.makeCall(
      callType: StreamCallType.audioRoom(),
      id: 'room-123',
    );

    // Create the call and set the current user as a host
    final result = await call.getOrCreate(
      members: [
        MemberRequest(
          userId: StreamVideo.instance.currentUser.id,
          role: 'host',
        ),
      ],
    );

    if (result.isSuccess) {
      // Set some default behaviour for how our devices should be configured once we join a call.
      // Note that the camera will be disabled by default because of the `audio_room` call type configuration.
      final connectOptions = CallConnectOptions(
        microphone: TrackOption.enabled(),
      );

      await call.join(connectOptions: connectOptions);

      // Allow others to see and join the call (exit backstage mode)
      await call.goLive();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AudioRoomScreen(
            audioRoomCall: call,
          ),
        ),
      );
    } else {
      debugPrint('Not able to create a call.');
    }
  }
}
