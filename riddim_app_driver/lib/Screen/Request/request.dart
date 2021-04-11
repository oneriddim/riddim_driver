import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riddim_app_driver/Repository/konnectRepository.dart';
import 'package:riddim_app_driver/Screen/Menu/MenuDefault.dart';
import 'package:riddim_app_driver/Screen/Request/pickUp.dart';
import 'package:riddim_app_driver/data/Model/userModel.dart';
import 'package:riddim_app_driver/theme/style.dart';
import 'package:riddim_app_driver/Screen/Menu/Menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';
import 'requestDetail.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final userRepository = KonnectRepository();
  final String screenName = "REQUEST";
  User _currentUser;
  Timer _everyTenSecond;
  String _currentTicketId = "";
  List<dynamic> listRequest = List<dynamic>();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = await userRepository.getUser(prefs.getString("usertoken"));

    setState(() {
      _currentUser = user;
    });

    _getNearbyTickets();

  }

  void _getNearbyTickets() async {
    if (_currentUser != null) {
      final results = await userRepository.getNearbyTickets(
          ticket: _currentTicketId,
          token: _currentUser.userid
      );
      setState(() {
        listRequest = results["data"];
        _currentUser.tickets = results["tickets"];
        _currentUser.hours = results["hours"];
        _currentUser.distance = results["distance"];
        _currentUser.rating = results["rating"];
        _currentUser.earn = results["earnings"];

        userRepository.saveUser(_currentUser);
      });
    }
  }

  navigateToDetail(String ticket, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ticket", ticket);
    if (status == "0") {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => RequestDetail()));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PickUp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request',
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
      ),
      drawer:  _currentUser != null? new MenuScreens(activeScreenName: screenName, user: _currentUser): new MenuScreensDefault(activeScreenName: screenName),
      body: Container(
        child: Scrollbar(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: listRequest.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  print('$index');
                  navigateToDetail(listRequest[index]["id"], listRequest[index]["status"].toString());
                },
                child: historyItem(index)
              );
            }
          ),
        )
      )
    );
  }

  Widget historyItem(int index) {
    final screenSize = MediaQuery.of(context).size;
    return Card(
        margin: EdgeInsets.all(10.0),
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
        ),
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  )
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: CachedNetworkImage(
                          imageUrl: Config.userImageUrl + listRequest[index]['avatar'],
                          fit: BoxFit.cover,
                          width: 40.0,
                          height: 40.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(listRequest[index]['name'],style: textBoldBlack,),
                          Text(listRequest[index]['date'], style: textGrey,),
                          Container(
                            child: Row(
                              children: <Widget>[
                                /*Container(
                                  height: 25.0,
                                  padding: EdgeInsets.all(5.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: primaryColor
                                  ),
                                  child: Text('ApplePay',style: textBoldWhite,),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  height: 25.0,
                                  padding: EdgeInsets.all(5.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: primaryColor
                                  ),
                                  child: Text('Discount',style: textBoldWhite,),
                                ),*/
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text( "\$" + listRequest[index]['price'],style: textBoldBlack,),
                          Text(listRequest[index]['distance'] + " Km",style: textGrey,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("PICK UP".toUpperCase(),style: textGreyBold,),
                          Text(listRequest[index]['pickup'],style: textStyle,),

                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("DROP OFF".toUpperCase(),style: textGreyBold,),
                          Text(listRequest[index]['dropoff'],style: textStyle,),

                        ],
                      ),
                    ),
                  ],
                )
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: ButtonTheme(
                  minWidth: screenSize.width ,
                  height: 45.0,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                    elevation: 0.0,
                    color: primaryColor,
                    child: Text(listRequest[index]['status'].toString() == "0"? "Review" : listRequest[index]['status'].toString() == "1"? "Accepted" : "Picked Up",style: headingWhite,
                    ),
                    onPressed: (){
//                      Navigator.of(context).pushReplacementNamed('/history');
                      navigateToDetail(listRequest[index]['id'], listRequest[index]['status'].toString());
                    },
                  ),
                ),
              ),

            ],
          ),
        ),
      );
  }
}
