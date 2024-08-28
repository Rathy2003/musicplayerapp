import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget customTileList({required String title,required String artist,required String cover,onTap,required bool isActive,required bool isPause}){
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: Row(
        children: [
          // song cover
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                  height: 90,
                  width: 90,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Image.network(cover,fit: BoxFit.cover,)
              ),
              if (isActive) Positioned(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withOpacity(0.2),
                    ),
                    child: Icon(isPause?Icons.play_arrow : Icons.pause,size: 40,color: Colors.white,),
                  )
              )
            ]
          ),

          const SizedBox(width: 15,),

          //Title and Artist
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,style:
                const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                ),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
              Text(artist,style: const TextStyle(
                fontSize: 17,

              ),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
            ],
          )
        ],
      ),
    ),
  );
}