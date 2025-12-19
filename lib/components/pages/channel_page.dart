// ignore_for_file: inference_failure_on_instance_creation, document_ignores, deprecated_member_use, lines_longer_than_80_chars

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChannelPage extends StatelessWidget {
  const ChannelPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StreamChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamMessageListView(
              onMessageTap: (msg) {},
              onMessageLongPress: (mst) {
                log(mst.text ?? '');
              },
            ),
          ),
          const StreamMessageInput(),
        ],
      ),
    );
  }
}

class ChannelListPage extends StatefulWidget {
  const ChannelListPage({
    required this.client,
    super.key,
  });

  final StreamChatClient client;

  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {
  late final _listController = StreamChannelListController(
    client: widget.client,
    filter: Filter.in_(
      'members',
      [
        StreamChat.of(context).currentUser!.id,
      ],
    ),
    channelStateSort: const [SortOption('last_message_at')],
    limit: 20,
  );
  @override
  void initState() {
    super.initState();
    // log(StreamChat.of(context).currentUser!.id);
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamChannelListView(
        controller: _listController,
        onChannelTap: (channel) async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return StreamChat(
                  client: widget.client,
                  child: StreamChannel(
                    channel: channel,
                    child: const ChannelPage(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
