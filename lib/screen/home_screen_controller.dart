import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreenController extends GetxController{

  // variable
  IconData icon = Icons.play_arrow;
  bool isPlay = false;
  String currentSong = "",currentTitle="",currentArtist="",currentCover="";
  AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = new Duration();
  Duration position = new Duration();
  int currentSongInd = -1;
  var songsData =[];
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void onInit() {
    // TODO: implement onInit
    getSongs();
    audioPlayer = AudioPlayer();
    super.onInit();
  }

  void onPressPlayOrPauseButton(){
    if(isPlay && currentSong!="")
    {
      audioPlayer.pause();
      isPlay = false;
    }
    else if(!isPlay && currentSong != ""){
      audioPlayer.resume();
      isPlay = true;
    }
    update();
  }

  void onTapOnSongList(int index){
    isPlay = true;
    playMusic(songsData[index]["url"]);
    currentSongInd = index;
    currentTitle=songsData[index]["title"]!;
    currentArtist=songsData[index]["artist"]!;
    currentCover=songsData[index]["cover"]!;
    update();
  }

  void getSongs() async{
    await db.collection("songs").get().then(
          (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
            songsData.add(docSnapshot.data());
        }
      },
      onError: (e) => print("Error completing: $e"),
    );

    update();
  }

  void playMusic(url) async{
    if(isPlay && currentSong != url){
      audioPlayer.pause();
      await audioPlayer.play(UrlSource(url));
        currentSong = url;
    }else if(!isPlay){
      await audioPlayer.play(UrlSource(url));
      isPlay = true;
    }

    update();
    audioPlayer.getDuration().then((value){
        duration = value!;
        update();
    });

    audioPlayer.onPositionChanged.listen((value){
        position = value;
        update();
    });

    audioPlayer.onPlayerComplete.listen((e){
        isPlay = false;
        update();
    });
  }

}