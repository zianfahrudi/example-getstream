// ignore_for_file: lines_longer_than_80_chars, inference_failure_on_instance_creation, use_build_context_synchronously, document_ignores

import 'package:flutter/material.dart';
import 'package:my_app/components/pages/chat_screen.dart';
import 'package:my_app/components/pages/home_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<void> initChatMessaging() async {
    final client = StreamChatClient(
      'wwutz7jeaeqm',
      logLevel: Level.INFO,
    );

    final user = OwnUser(
      id: '358',
      extraData: const {
        'name': 'John Doe',
        // "image": "https://i.imgur.com/fR9Jz14.png",
      },
      // privacySettings: PrivacySettings(
      //   typingIndicators: TypingIndicators(
      //     enabled: false,
      //   ),
      //   readReceipts: ReadReceipts(
      //     enabled: false,
      //   ),
      // ),
    );

    await client.connectUser(
      user,
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMzU4IiwiaWF0IjoxNzY2MTMzMDc3fQ.Vl217C0pgD_niAoBIWhEhBbRBX4bV54vjh1cgnVznrM',
    );

    /// Creates a channel using the type `messaging` and `flutterdevs`.
    /// Channels are containers for holding messages between different members. To
    /// learn more about channels and some of our predefined types, checkout our
    /// our channel docs: https://getstream.io/chat/docs/flutter-dart/creating_channels/?language=dart
    final channel = client.channel(
      'messaging',
      id: 'mancing-mania',
      extraData: {
        'members': ['100', '358'],
      },
    );

    /// `.watch()` is used to create and listen to the channel for updates. If the
    /// channel already exists, it will simply listen for new events.
    await channel.watch();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          channel: channel,
          client: client,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Getstream.io'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
              child: const Text('Livestream'),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: initChatMessaging,
              child: const Text('Chat Messaging'),
            ),
          ],
        ),
      ),
    );
  }
}
