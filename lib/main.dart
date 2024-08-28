import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'components/customTileList.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  IconData icon = Icons.play_arrow;
  bool isPlay = false;
  String currentSong = "",currentTitle="",currentArtist="",currentCover="";
  AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = new Duration();
  Duration position = new Duration();
  int currentSongInd = -1;
  var songsData =[];
  FirebaseFirestore db = FirebaseFirestore.instance;

  void getSongs() async{
    await db.collection("songs").get().then(
          (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          setState(() {
            songsData.add(docSnapshot.data());
          });
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }


  void playMusic(url) async{
    if(isPlay && currentSong != url){
      audioPlayer.pause();
      await audioPlayer.play(UrlSource(url));
      setState(() {
        currentSong = url;
      });
    }else if(!isPlay){
      await audioPlayer.play(UrlSource(url));
      isPlay = true;
    }

    audioPlayer.getDuration().then((value){
      setState(() {
        duration = value!;
      });
    });

    audioPlayer.onPositionChanged.listen((value){
      setState(() {
        position = value;
      });
    });

    audioPlayer.onPlayerComplete.listen((e){
      setState(() {
        isPlay = false;
      });
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    audioPlayer = AudioPlayer();
    getSongs();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("My Playlist"),
          ),
          body: Column(
            children: [
              // Playlist
              Expanded(
                child: ListView.builder(
                  itemCount: songsData.length,
                  itemBuilder: (context, index) {
                    return customTileList(
                        title:songsData[index]["title"],
                        artist:songsData[index]["artist"],
                        cover:songsData[index]["cover"],
                        onTap:(){
                          isPlay = true;
                          playMusic(songsData[index]["url"]);
                          currentSongInd = index;
                          setState(() {
                            currentTitle=songsData[index]["title"]!;
                            currentArtist=songsData[index]["artist"]!;
                            currentCover=songsData[index]["cover"]!;
                          });
                        },
                        isActive: currentSongInd == index ? true : false,
                        isPause: isPlay
                    );
                  },),
              ),

              // Audio Player
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 10),
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
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15))
                ),
                child: Column(
                  children: [
                    Slider.adaptive(
                      value: position.inSeconds.toDouble(),
                      min: 0.0,
                      max: duration.inSeconds.toDouble(),
                      onChanged: (val)=>{
                      },
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
                                color: Colors.grey.withOpacity(0.5)
                            ),
                            child: currentSong==""?Image.asset("assets/images/disc.png") : Image.network(currentCover,fit: BoxFit.cover,)
                        ),
                        const SizedBox(width: 10,),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.90,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currentTitle,style:
                              const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600
                              ),
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                softWrap: false,
                              ),
                              Text(currentArtist,
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
                            onPressed: (){
                              setState(() {
                                if(isPlay && currentSong!="")
                                {
                                  audioPlayer.pause();
                                  isPlay = false;
                                }
                                else if(!isPlay && currentSong != ""){
                                  audioPlayer.resume();
                                  isPlay = true;
                                }
                              });
                            },
                            icon:Icon(isPlay?Icons.pause:icon,size: 50,)
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}

