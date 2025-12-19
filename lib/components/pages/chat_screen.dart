// ignore_for_file: lines_longer_than_80_chars, document_ignores

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_app/components/pages/channel_page.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({required this.channel, required this.client, super.key});

  /// Instance of [StreamChatClient] we created earlier. This contains information about
  /// our application and connection state.
  final StreamChatClient client;

  /// The channel we'd like to observe and participate.
  final Channel channel;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    log(widget.channel.id ?? '-');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamChat(
        client: widget.client,
        child: StreamChannel(
          channel: widget.channel,
          child: const ChannelPage(
            // client: widget.client,
          ),
        ),
      ),
    );
  }
}
