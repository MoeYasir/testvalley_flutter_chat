// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle('Main'),
        centerTitle: true,
      ),
      body: _mainBox(),
    );
  }

  Widget _mainBox() {
    final isNotificationEnabled =
        SendbirdChat.getAppInfo()?.notificationInfo?.isEnabled ?? false;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            Get.toNamed('/open_channel/:channel_url');
          },
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('OpenChannel'),
          ),
        ),
      ),
    );
  }
}
