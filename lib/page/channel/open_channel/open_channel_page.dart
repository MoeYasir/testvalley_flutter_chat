import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class OpenChannelPage extends StatefulWidget {
  const OpenChannelPage({Key? key}) : super(key: key);

  @override
  State<OpenChannelPage> createState() => OpenChannelPageState();
}

class OpenChannelPageState extends State<OpenChannelPage> {
  final channelUrl =
      'sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211';
  final itemScrollController = ItemScrollController();
  final textEditingController = TextEditingController();
  late PreviousMessageListQuery query;

  String title = '';
  bool hasPrevious = false;
  List<BaseMessage> messageList = [];
  int? participantCount;

  OpenChannel? openChannel;

  @override
  void initState() {
    super.initState();
    SendbirdChat.addChannelHandler('OpenChannel', MyOpenChannelHandler(this));
    SendbirdChat.addConnectionHandler('OpenChannel', MyConnectionHandler(this));

    OpenChannel.getChannel(channelUrl).then((openChannel) {
      this.openChannel = openChannel;
      openChannel.enter().then((_) => _initialize());
    });
  }

  void _initialize() {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      query = PreviousMessageListQuery(
        channelType: ChannelType.open,
        channelUrl: channelUrl,
      )..next().then((messages) {
          setState(() {
            messageList
              ..clear()
              ..addAll(messages);
            title = '${openChannel.name} (${messageList.length})';
            hasPrevious = query.hasNext;
            participantCount = openChannel.participantCount;
          });
        });
    });
  }

  @override
  void dispose() {
    SendbirdChat.removeChannelHandler('OpenChannel');
    SendbirdChat.removeConnectionHandler('OpenChannel');
    textEditingController.dispose();

    OpenChannel.getChannel(channelUrl).then((channel) => channel.exit());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Widgets.pageTitle(title),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.menu),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: messageList.isNotEmpty ? _list() : Container()),
          _messageSender(),
        ],
      ),
    );
  }

  Widget _list() {
    return ScrollablePositionedList.builder(
      physics: const ClampingScrollPhysics(),
      initialScrollIndex: messageList.length - 1,
      itemScrollController: itemScrollController,
      itemCount: messageList.length,
      itemBuilder: (BuildContext context, int index) {
        if (index >= messageList.length) return Container();

        BaseMessage message = messageList[index];
        final isMyMessage =
            message.sender?.userId == SendbirdChat.currentUser?.userId;

        return MessageListItem(message: message, isMyMessage: isMyMessage);
      },
    );
  }

  Widget _messageSender() {
    return Container(
      color: Color(0xFF131313),
      height: 70,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Theme(
                data: new ThemeData(
                  focusColor: Colors.black,
                  // primaryColorDark: Colors.red,
                ),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: textEditingController,
                  decoration: InputDecoration(
                    // enabledBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.all(Radius.circular(20)),
                    //   borderSide: BorderSide(color: Color(0xFF323232)),
                    // ),
                    // border: InputBorder.none,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF323232)),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF323232)),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    // suffix: Container(
                    //   width: 50,
                    //   height: 10,
                    //   color: Colors.blue,
                    //   child: Text("ssdsdds"),
                    // ),
                    // suffixIconColor: Colors.red,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () async {
                          if (textEditingController.value.text.isEmpty) {
                            return;
                          }

                          openChannel?.sendUserMessage(
                            UserMessageCreateParams(
                              message: textEditingController.value.text,
                            ),
                            handler: (UserMessage message,
                                SendbirdException? e) async {
                              if (e != null) {
                                await _showDialogToResendUserMessage(message);
                              } else {
                                _addMessage(message);
                              }
                            },
                          );

                          textEditingController.clear();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFF006A),
                          ),
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.arrow_upward,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    //  InkWell(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       color: Color(0xFFFF006A),sdf
                    //     ),
                    //     padding: EdgeInsets.all(4.0),
                    //     child: CircleAvatar(
                    //       backgroundColor: Colors.transparent,
                    //       child: IconButton(
                    //         color: Colors.white,
                    //         onPressed: () {},
                    //         icon: Icon(Icons.arrow_upward),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ),
                ),
              ),
            ),
            // const SizedBox(width:
            // ElevatedButton(
            //   onPressed: () async {
            //     if (textEditingController.value.text.isEmpty) {
            //       return;
            //     }

            //     openChannel?.sendUserMessage(
            //       UserMessageCreateParams(
            //         message: textEditingController.value.text,
            //       ),
            //       handler: (UserMessage message, SendbirdException? e) async {
            //         if (e != null) {
            //           await _showDialogToResendUserMessage(message);
            //         } else {
            //           _addMessage(message);
            //         }
            //       },
            //     );

            //     textEditingController.clear();
            //   },
            //   child: const Icon(Icons.arrow_upward),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDialogToResendUserMessage(UserMessage message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Text('Resend: ${message.message}'),
          actions: [
            TextButton(
              onPressed: () {
                openChannel?.resendUserMessage(
                  message,
                  handler: (message, e) async {
                    if (e != null) {
                      await _showDialogToResendUserMessage(message);
                    } else {
                      _addMessage(message);
                    }
                  },
                );

                Get.back();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _addMessage(BaseMessage message) {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        messageList.add(message);
        title = '${openChannel.name} (${messageList.length})';
        participantCount = openChannel.participantCount;
      });

      Future.delayed(
        const Duration(milliseconds: 100),
        () => _scroll(messageList.length - 1),
      );
    });
  }

  void _updateMessage(BaseMessage message) {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        for (int index = 0; index < messageList.length; index++) {
          if (messageList[index].messageId == message.messageId) {
            messageList[index] = message;
            break;
          }
        }

        title = '${openChannel.name} (${messageList.length})';
        participantCount = openChannel.participantCount;
      });
    });
  }

  void _deleteMessage(int messageId) {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        for (int index = 0; index < messageList.length; index++) {
          if (messageList[index].messageId == messageId) {
            messageList.removeAt(index);
            break;
          }
        }

        title = '${openChannel.name} (${messageList.length})';
        participantCount = openChannel.participantCount;
      });
    });
  }

  void _updateParticipantCount() {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        participantCount = openChannel.participantCount;
      });
    });
  }

  void _scroll(int index) async {
    if (messageList.length <= 1) return;

    while (!itemScrollController.isAttached) {
      await Future.delayed(const Duration(milliseconds: 1));
    }

    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }
}

class MessageListItem extends StatelessWidget {
  final BaseMessage message;
  final bool isMyMessage;

  const MessageListItem(
      {Key? key, required this.message, required this.isMyMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageColor = isMyMessage ? Color(0xFFFF1782) : Color(0xFF1A1A1A);
    final textColor = Colors.white;
    final alignment =
        isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          isMyMessage == true
              ? Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: messageColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage:
                          _loadProfileImage(message.sender!.profileUrl),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: messageColor,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.sender!.userId,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    message.message,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 16),
                            alignment: Alignment.centerRight,
                            child: Text(
                              DateTime.fromMillisecondsSinceEpoch(
                                      message.createdAt)
                                  .toString()
                                  .substring(10, 16),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

ImageProvider _loadProfileImage(String? url) {
  if (url != null && url.isNotEmpty) {
    try {
      return NetworkImage(url);
    } catch (e) {
      // Handle error
      print('Error loading profile image: $e');
    }
  }
  // Provide a fallback image or return null
  // For example, return AssetImage('assets/default_profile_image.png');
  return const AssetImage(
    'assets/account.png',
  );
}

class MyOpenChannelHandler extends OpenChannelHandler {
  final OpenChannelPageState _state;

  MyOpenChannelHandler(this._state);

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    _state._addMessage(message);
  }

  @override
  void onMessageUpdated(BaseChannel channel, BaseMessage message) {
    _state._updateMessage(message);
  }

  @override
  void onMessageDeleted(BaseChannel channel, int messageId) {
    _state._deleteMessage(messageId);
  }

  @override
  void onUserEntered(OpenChannel channel, User user) {
    _state._updateParticipantCount();
  }

  @override
  void onUserExited(OpenChannel channel, User user) {
    _state._updateParticipantCount();
  }
}

class MyConnectionHandler extends ConnectionHandler {
  final OpenChannelPageState _state;

  MyConnectionHandler(this._state);

  @override
  void onConnected(String userId) {}

  @override
  void onDisconnected(String userId) {}

  @override
  void onReconnectStarted() {}

  @override
  void onReconnectSucceeded() {
    _state._initialize();
  }

  @override
  void onReconnectFailed() {}
}
