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
        body: Column(
          children: [
            // Playlist
            Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height / 1.42,
              child: GetBuilder<HomeScreenController>(
                  init: HomeScreenController(),
                  builder: (controller) {
                    return ListView.builder(
                      itemCount: controller.songsData.length,
                      itemBuilder: (context, index) {
                        return customTileList(
                            title: controller.songsData[index]["title"],
                            artist: controller.songsData[index]["artist"],
                            cover: controller.songsData[index]["cover"],
                            onTap: () {
                              controller.onTapOnSongList(index);
                            },
                            isActive: controller.currentSongInd == index
                                ? true
                                : false,
                            isPause: controller.isPlay);
                      },
                    );
                  }),
            ),

            // Audio Player
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      topLeft: Radius.circular(15))),
              child: GetBuilder<HomeScreenController>(
                  init: HomeScreenController(),
                  builder: (controller) {
                    return Column(
                      children: [
                        Slider.adaptive(
                          value: controller.position.inSeconds.toDouble(),
                          min: 0.0,
                          max: controller.duration.inSeconds.toDouble(),
                          onChanged: (val) => {},
                          activeColor: Colors.orange,
                        ),
                        Row(
                          children: [
                            Container(
                                height: 70,
                                width: 70,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.withOpacity(0.5)),
                                child: controller.currentSong == ""
                                    ? Image.asset("assets/images/disc.png")
                                    : Image.network(
                                        controller.currentCover,
                                        fit: BoxFit.cover,
                                      )),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.90,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.currentTitle,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                  Text(
                                    controller.currentArtist,
                                    style: const TextStyle(
                                      fontSize: 17,
                                    ),
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                  )
                                ],
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  controller.onPressPlayOrPauseButton();
                                },
                                icon: Icon(
                                  controller.isPlay
                                      ? Icons.pause
                                      : controller.icon,
                                  size: 50,
                                ))
                          ],
                        )
                      ],
                    );
                  }),
            )
          ],
        ));
  }
}
