// ignore_for_file: use_build_context_synchronously, document_ignores

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stream_video/stream_video.dart';

class AudioRoomActions extends StatefulWidget {
  const AudioRoomActions({required this.audioRoomCall, super.key});

  final Call audioRoomCall;

  @override
  State<AudioRoomActions> createState() => _AudioRoomActionsState();
}

class _AudioRoomActionsState extends State<AudioRoomActions> {
  var _microphoneEnabled = false;

  @override
  void initState() {
    super.initState();
    _microphoneEnabled =
        widget.audioRoomCall.connectOptions.microphone.isEnabled;

    widget.audioRoomCall.state.listen(
      (state) {
        log(state.status.toString());
        final isUstadOnline = state.callParticipants.any(
          (participant) => participant.userId.contains('360'),
        );

        log('ustad online: $isUstadOnline');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CallState>(
      initialData: widget.audioRoomCall.state.value,
      stream: widget.audioRoomCall.state.valueStream,
      builder: (context, snapshot) {
        final callState = snapshot.data;

        if (callState == null) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 20,
          children: [
            FloatingActionButton.extended(
              label: const Text('End Call'),
              icon: const Icon(
                Icons.stop,
                color: Colors.red,
              ),
              onPressed: () async {
                final result = await widget.audioRoomCall.end();
                Navigator.of(context).pop();
                if (result.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Call ended successfully.'),
                    ),
                  );
                }
              },
            ),
            // FloatingActionButton.extended(
            //   heroTag: 'go-live',
            //   label: callState.isBackstage
            //       ? const Text('Go Live')
            //       : const Text('Stop Live'),
            //   icon: callState.isBackstage
            //       ? const Icon(
            //           Icons.play_arrow,
            //           color: Colors.green,
            //         )
            //       : const Icon(
            //           Icons.stop,
            //           color: Colors.red,
            //         ),
            //   onPressed: () async {
            //     if (callState.isBackstage) {
            //       await widget.audioRoomCall.goLive();
            //     } else {
            //       await widget.audioRoomCall.stopLive();
            //     }
            //   },
            // ),
            FloatingActionButton(
              heroTag: 'microphone',
              child: _microphoneEnabled
                  ? const Icon(Icons.mic)
                  : const Icon(Icons.mic_off),
              onPressed: () async {
                if (_microphoneEnabled) {
                  await widget.audioRoomCall.setMicrophoneEnabled(
                    enabled: false,
                  );
                  setState(() {
                    _microphoneEnabled = false;
                  });
                } else {
                  if (!widget.audioRoomCall.hasPermission(
                    CallPermission.sendAudio,
                  )) {
                    await widget.audioRoomCall.requestPermissions(
                      [CallPermission.sendAudio],
                    );
                  }
                  await widget.audioRoomCall.setMicrophoneEnabled(
                    enabled: true,
                  );
                  setState(() {
                    _microphoneEnabled = true;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}
