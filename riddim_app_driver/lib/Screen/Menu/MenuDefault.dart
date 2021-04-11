import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riddim_app_driver/Repository/konnectRepository.dart';
import 'package:riddim_app_driver/Screen/Login/login.dart';
import 'package:riddim_app_driver/data/Model/userModel.dart';
import '../../config.dart';
import '../MyProfile/profile.dart';
import '../../theme/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../MyProfile/myProfile.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MenuItems {
  String name;
  IconData icon;
  MenuItems({this.icon, this.name});
}

class MenuScreensDefault extends StatelessWidget {
  final String activeScreenName;
  final userRepository = KonnectRepository();

  MenuScreensDefault({this.activeScreenName});

  navigatorRemoveUntil(BuildContext context, String router){
    Navigator.of(context).pushNamedAndRemoveUntil('/$router', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    _logout() async {
      var logout = await userRepository.logout(token: "");
      if (logout) {
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => LoginScreen()));

      }
    }

    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 20.0,top: 30.0,right: 20.0,bottom: 0.0),
            color: primaryColor,
            height: 180.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                        Navigator.of(context).push(new MaterialPageRoute<Null>(
                          builder: (BuildContext context) {
                            return Profile();
                          },
                        fullscreenDialog: true));
                      },
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(50.0),
                        child: new ClipRRect(
                          borderRadius: new BorderRadius.circular(100.0),
                          child: new Container(
                            height: 50.0,
                            width: 50.0,
                            color: primaryColor,
                            child: CachedNetworkImage(
                              imageUrl: Config.userImageUrl + "-1",
                              fit: BoxFit.cover,
                            ),
                          )
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                        Navigator.of(context).push(new MaterialPageRoute<Null>(
                          builder: (BuildContext context) {
                            return Profile();
                          },
                          fullscreenDialog: true));
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Username",style: textBoldWhite,),
                            Container(
                              padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 2.0, bottom: 2.0),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text("",style: TextStyle(
                                fontSize: 11,
                                color: primaryColor,
                              ),),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.access_time,color: greyColor,),
                            Text("10.2",style: heading18,),
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
                            Text("30 KM",style: heading18,),
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
                            Text("22",style: heading18,),
                            Text("Total Jobh",style: TextStyle(
                              fontSize: 11,
                              color: greyColor,
                            ),),
                          ],
                        ),
                      ),
                    ],
                  )
                ),
              ],
            ),
          ),

//          UserAccountsDrawerHeader(
//            margin: EdgeInsets.all(0.0),
//            accountName: new Text("John",style: headingWhite,),
//            accountEmail: new Text("100 point - Gold member"),
//            currentAccountPicture: new CircleAvatar(
//                backgroundColor: Colors.white,
//                child: new Image(
//                    width: 100.0,
//                    image: new AssetImage('assets/image/taxi-driver.png',)
//                )
//            ),
//            onDetailsPressed: (){
//              Navigator.pop(context);
//              Navigator.of(context).push(new MaterialPageRoute<Null>(
//                  builder: (BuildContext context) {
//                    return MyProfile();
//                  },
//                  fullscreenDialog: true));
//            },
//          ),
          new MediaQuery.removePadding(
            context: context,
            // DrawerHeader consumes top MediaQuery padding.
            removeTop: true,
            child: new Expanded(
              child: new ListView(
                //padding: const EdgeInsets.only(top: 8.0),
                children: <Widget>[
                  new Stack(
                    children: <Widget>[
                      // The initial contents of the drawer.
                      new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              navigatorRemoveUntil(context,'home');
                            },
                            child: new Container(
                              height: 60.0,
                              color: this.activeScreenName.compareTo("HOME") == 0 ? greyColor : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.home,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('Home',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              navigatorRemoveUntil(context,'request');
                            },
                            child: new Container(
                              height: 60.0,
                              color: this.activeScreenName.compareTo("REQUEST") == 0 ? greyColor : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.firstOrder,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('Request',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              navigatorRemoveUntil(context,'my_wallet');
                            },
                            child: new Container(
                              height: 60.0,
                              color: this.activeScreenName.compareTo("MY WALLET") == 0 ? greyColor : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.wallet,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('My Wallet',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              navigatorRemoveUntil(context,'history');
                            },
                            child: new Container(
                              height: 60.0,
                              color: this.activeScreenName.compareTo("HISTORY") == 0 ? greyColor : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.history,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('History',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              navigatorRemoveUntil(context,'notification');
                            },
                            child: new Container(
                              height: 60.0,
                              color: this.activeScreenName.compareTo("NOTIFICATIONS") == 0 ? greyColor : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.bell,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('Notifications',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          new GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              navigatorRemoveUntil(context,'setting');
                            },
                            child: new Container(
                              height: 60.0,
                              color: this.activeScreenName.compareTo("SETTINGS") == 0 ? greyColor : whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.cogs,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('Settings',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          new GestureDetector(
                            onTap: () {
                              _logout();
                            },
                            child: new Container(
                              height: 60.0,
                              color: whiteColor,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.signOutAlt,color: blackColor,),
                                  ),
                                  new Expanded(
                                    flex: 3,
                                    child: new Text('Logout',style: headingBlack,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // The drawer's "details" view.
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
