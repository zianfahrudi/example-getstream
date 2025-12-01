import 'package:flutter/material.dart';
import 'package:my_app/components/widgets/audio_room_actions.dart';
import 'package:my_app/components/widgets/participant_avatar.dart';
import 'package:my_app/components/widgets/permission_request.dart';
import 'package:stream_video/stream_video.dart';

class AudioRoomScreen extends StatefulWidget {
  const AudioRoomScreen({
    required this.audioRoomCall,
    super.key,
  });

  final Call audioRoomCall;

  @override
  State<AudioRoomScreen> createState() => _AudioRoomScreenState();
}

class _AudioRoomScreenState extends State<AudioRoomScreen> {
  late CallState _callState;

  @override
  void initState() {
    super.initState();
    _callState = widget.audioRoomCall.state.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Room: ${_callState.callId}'),
        leading: IconButton(
          onPressed: () async {
            await widget.audioRoomCall.leave();

            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(
            Icons.close,
          ),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<CallState>(
            initialData: _callState,
            stream: widget.audioRoomCall.state.valueStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Cannot fetch call state.'),
                );
              }
              if (snapshot.hasData && !snapshot.hasError) {
                final callState = snapshot.data!;

                return GridView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Align(
                      widthFactor: 0.8,
                      child: ParticipantAvatar(
                        participantState: callState.callParticipants[index],
                      ),
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: callState.callParticipants.length,
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: PermissionRequests(
              audioRoomCall: widget.audioRoomCall,
            ),
          ),
        ],
      ),
      floatingActionButton: AudioRoomActions(
        audioRoomCall: widget.audioRoomCall,
      ),
    );
  }
}
