import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../theme/style.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyActivity extends StatelessWidget {

  final String userImage;
  final String userName;
  final double level;
  final String totalEarned;
  final double hoursOnline;
  final String totalDistance;
  final int totalJob;

  const MyActivity(
      {Key key,
        this.userImage,
        this.userName,
        this.level,
        this.totalEarned,
        this.hoursOnline,
        this.totalDistance,
        this.totalJob,

      })
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: whiteColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: CachedNetworkImage(
                      imageUrl: userImage,
                      fit: BoxFit.cover,
                      width: 40.0,
                      height: 40.0,
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(userName ?? '',
                        style: textBoldBlack,
                        overflow: TextOverflow.ellipsis,
                      ),
                      RatingBar(
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        ignoreGestures: true,
                        initialRating:  level,
                        itemSize: 15.0,
                        itemCount: 5,
                        glowColor: Colors.white,
                      ),
                      /*Text(level ?? '',
                        style: textGrey,
                        overflow: TextOverflow.ellipsis,
                      ),*/
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(totalEarned.toString() ?? '',
                        style: textBoldBlack,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('Earned',
                        style: textGrey,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: primaryColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.access_time,color: greyColor,),
                      Text(hoursOnline.toString() ?? '',style: heading18,),
                      Text("Hours online",style: TextStyle(
                        fontSize: 11,
                        color: greyColor,
                      ),),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.poll,color: greyColor,),
                      Text(totalDistance + " Km" ?? '',style: heading18,),
                      Text("Total Distance",style: TextStyle(
                        fontSize: 11,
                        color: greyColor,
                      ),),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.content_paste,color: greyColor,),
                      Text(totalJob.toString() ?? '',style: heading18,),
                      Text("Total Jobs",style: TextStyle(
                        fontSize: 11,
                        color: greyColor,
                      ),),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
