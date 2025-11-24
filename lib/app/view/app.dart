import 'package:flutter/material.dart';
import 'package:my_app/counter/counter.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:stream_video/stream_video.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}

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
          onPressed: () => _createAudioRoom(),
          child: const Text('Create an Audio Room'),
        ),
      ),
    );
  }

  Future<void> _createAudioRoom() async {
    // Set up our call object
    final call = StreamVideo.instance.makeCall(
      callType: StreamCallType.audioRoom(),
      id: 'audio_room_05e8f109-e884-48a6-9d42-2f0d146f890b',
    );

    // Create the call and set the current user as a host
    final result = await call.getOrCreate(
      // members: [
      //   MemberRequest(
      //     userId: StreamVideo.instance.currentUser.id,
      //     role: 'default',
      //   ),
      // ],
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

      Navigator.of(context).push(
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

class AudioRoomScreen extends StatefulWidget {
  const AudioRoomScreen({
    super.key,
    required this.audioRoomCall,
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
                var callState = snapshot.data!;

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

class ParticipantAvatar extends StatelessWidget {
  const ParticipantAvatar({
    required this.participantState,
    super.key,
  });

  final CallParticipantState participantState;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
      decoration: BoxDecoration(
        border: Border.all(
          color: participantState.isSpeaking ? Colors.green : Colors.white,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        radius: 40,
        backgroundImage:
            participantState.image != null && participantState.image!.isNotEmpty
            ? NetworkImage(participantState.image!)
            : null,
        child: participantState.image == null || participantState.image!.isEmpty
            ? Text(
                participantState.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              )
            : null,
      ),
    );
  }
}

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
              heroTag: 'go-live',
              label: callState.isBackstage
                  ? const Text('Go Live')
                  : const Text('Stop Live'),
              icon: callState.isBackstage
                  ? const Icon(
                      Icons.play_arrow,
                      color: Colors.green,
                    )
                  : const Icon(
                      Icons.stop,
                      color: Colors.red,
                    ),
              onPressed: () {
                if (callState.isBackstage) {
                  widget.audioRoomCall.goLive();
                } else {
                  widget.audioRoomCall.stopLive();
                }
              },
            ),
            FloatingActionButton(
              heroTag: 'microphone',
              child: _microphoneEnabled
                  ? const Icon(Icons.mic)
                  : const Icon(Icons.mic_off),
              onPressed: () {
                if (_microphoneEnabled) {
                  widget.audioRoomCall.setMicrophoneEnabled(enabled: false);
                  setState(() {
                    _microphoneEnabled = false;
                  });
                } else {
                  if (!widget.audioRoomCall.hasPermission(
                    CallPermission.sendAudio,
                  )) {
                    widget.audioRoomCall.requestPermissions(
                      [CallPermission.sendAudio],
                    );
                  }
                  widget.audioRoomCall.setMicrophoneEnabled(enabled: true);
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

class PermissionRequests extends StatefulWidget {
  const PermissionRequests({required this.audioRoomCall, super.key});
  final Call audioRoomCall;

  @override
  State<PermissionRequests> createState() => _PermissionRequestsState();
}

class _PermissionRequestsState extends State<PermissionRequests> {
  final List<StreamCallPermissionRequestEvent> _permissionRequests = [];

  @override
  void initState() {
    super.initState();

    widget.audioRoomCall.onPermissionRequest = (permissionRequest) {
      setState(() {
        _permissionRequests.add(permissionRequest);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._permissionRequests.map(
          (request) {
            return Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Row(
                children: [
                  Text(
                    '${request.user.name} requests to ${request.permissions}',
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                    onPressed: () async {
                      await widget.audioRoomCall.grantPermissions(
                        userId: request.user.id,
                        permissions: request.permissions.toList(),
                      );

                      setState(() {
                        _permissionRequests.remove(request);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      setState(() {
                        _permissionRequests.remove(request);
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
