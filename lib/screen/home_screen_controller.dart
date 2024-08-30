import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    onGetLocalData();
    _configureAudioSession();
    super.onInit();
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  void onGetLocalData() async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final int? lastInd = pref.getInt("ind");
    if(lastInd!=null) {
      currentSongInd = lastInd;
    }
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
    }else if(!isPlay && currentSongInd >= 0){
      playMusic(songsData[currentSongInd]["url"]);
    }else if(!isPlay && currentSongInd == -1){
      playMusic(songsData[0]["url"]);
    }
    update();
  }

  void onTapOnSongList(int index) async{
    final SharedPreferences pref = await SharedPreferences.getInstance();
    isPlay = true;
    await pref.setInt('ind', index);
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
      currentSong = url;
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

    audioPlayer.onPlayerComplete.listen((e) async{
        isPlay = false;
        if(currentSongInd < songsData.length){
          currentSongInd++;
          playMusic(songsData[currentSongInd]["url"]);
          final SharedPreferences pref = await SharedPreferences.getInstance();
          await pref.setInt('ind', currentSongInd);

        }
        update();
    });
  }

}