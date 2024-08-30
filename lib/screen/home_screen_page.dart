import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:musicplaylist_app/screen/home_screen_controller.dart';

import '../components/customTileList.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Playlist"),
      ),
      body: Center(
        child: GetBuilder<HomeScreenController>(
          init: HomeScreenController(),
          builder: (controller) {
            return Text(
              controller.songsData[0]["title"]
            );
          }
        ),
      ),
    );
  }
}
