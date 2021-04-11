import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app_driver/Components/loading.dart';
import 'package:riddim_app_driver/Repository/konnectRepository.dart';
import 'package:riddim_app_driver/Screen/Message/MessageScreen.dart';
import 'package:riddim_app_driver/data/Model/userModel.dart';
import 'package:riddim_app_driver/theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config.dart';
import 'pickUp.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RequestDetail extends StatefulWidget {
  //final String id;

  //RequestDetail({this.id});

  @override
  _RequestDetailState createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetail> {
  final userRepository = KonnectRepository();
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String yourReview;
  double ratingScore;
  User _currentUser;
  Map _ticketInfo;
  String _ticketId;

  bool isAccepted = false;
  bool isConfirmed = false;
  Timer _waitForPassenger;

  @override
  void initState() {
    super.initState();
    _getTicketInfo();
  }

  @override
  void dispose() {
    super.dispose();
    if (_waitForPassenger != null) _waitForPassenger.cancel();
  }

  Future<void> _getTicketInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ticketId = prefs.get("ticket");
    var user = await userRepository.getUser(prefs.getString("usertoken"));

    final info = await userRepository.ticket(ticket: _ticketId, token: user.userid);

    setState(() {
      _currentUser = user;
      if (info.length > 0) {
        _ticketInfo = info["data"];
      }
    });
  }

  _accept() async {
    final accepted = await userRepository.acceptTicket(
      ticket: _ticketId,
      token: _currentUser.userid,
    );
    if (accepted) {
      Fluttertoast.showToast(
          msg: "Please wait for trip confirmation!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );


      setState(() {
        isAccepted = true;
      });

      _waitForPassenger = Timer.periodic(Duration(seconds: 10), (Timer t) async {
        final confirmed = await userRepository.isTicketConfirmed(ticket: _ticketId, token: _currentUser.userid);
        if (confirmed["success"]) {
          Fluttertoast.showToast(
              msg: "Trip Confirmed!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );

          setState(() {
            _waitForPassenger.cancel();
            isConfirmed = true;
          });
        }
      });
    }
  }

  _pickup() {
    if (_waitForPassenger != null)  _waitForPassenger.cancel();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PickUp()));
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Request Detail', style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: blackColor),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 10.0,right: 10.0),
        child: ButtonTheme(
          minWidth: screenSize.width ,
          height: 45.0,
          child: isAccepted == false ? RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
            elevation: 0.0,
            color: primaryColor,
            child: Text('Accept'.toUpperCase(),style: headingWhite,
            ),
            onPressed: () {
              _accept();
            },
          ) :
          isConfirmed == false ?  Container(
            child: LoadingBuilder(),
          ) :  RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
            elevation: 0.0,
            color: primaryColor,
            child: Text('Go to pick up'.toUpperCase(),style: headingWhite,
            ),
            onPressed: () {
              _pickup();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            color: greyColor,
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
                            imageUrl: _ticketInfo == null? Config.userImageUrl + "-1"  : (Config.userImageUrl + "" + _ticketInfo["driverid"]),
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
                            Text(_ticketInfo == null? "" : _ticketInfo["name"],style: textBoldBlack,),
                            Text(_ticketInfo == null? "" : _ticketInfo["datesch"], style: textGrey,),
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
                            Text(_ticketInfo == null? "\$0.00" : "\$" + _ticketInfo["cost"],style: textBoldBlack,),
                            Text(_ticketInfo == null? "0 Km" : _ticketInfo["distance"] + "Km",style: textGrey,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: whiteColor,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("PICK UP".toUpperCase(),style: textGreyBold,),
                              Text(_ticketInfo == null? "" : _ticketInfo["pickup"],style: textStyle,),

                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("DROP OFF".toUpperCase(),style: textGreyBold,),
                              Text(_ticketInfo == null? "" : _ticketInfo["dropoff"],style: textStyle,),

                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("note".toUpperCase(),style: textGreyBold,),
                              Text(_ticketInfo == null? "" : _ticketInfo["notes"],style: textStyle,),
                            ],
                          ),
                        ),
                      ],
                    )
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.0,bottom: 5.0),
                  padding: EdgeInsets.all(10),
                  color: whiteColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Bill Details".toUpperCase(), style: textGreyBold,),
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text("Ride Fare", style: textStyle,),
                            new Text(_ticketInfo == null? "\$0.00" : "\$" + _ticketInfo["subtotal"], style: textBoldBlack,),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text("Taxes", style: textStyle,),
                            new Text(_ticketInfo == null? "\$0.00" : "\$" + _ticketInfo["taxes"], style: textBoldBlack,),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0,bottom: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text("Discount", style: textStyle,),
                            new Text(_ticketInfo == null? "-\$0.00" : "-\$" + _ticketInfo["discount"], style: textBoldBlack,),
                          ],
                        ),
                      ),
                      Container(
                        width: screenSize.width - 50.0,
                        height: 1.0,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text("Total Bill", style: heading18Black,),
                            new Text(_ticketInfo == null? "\$0.00" : "\$" + _ticketInfo["cost"], style: heading18Black,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: whiteColor,
                  padding: EdgeInsets.only(top: 10.0,bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          if (_currentUser != null) {
                            launch("tel:+1" + _currentUser.contact);
                          }
                        },
                        child: Container(
                          height: 60,
                          width: 100,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(5.0)
                          ),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.call,color: whiteColor,),
                              Text('Call',style: TextStyle(fontSize: 18,color: whiteColor,fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          print('ok');
                          Navigator.of(context).push(new MaterialPageRoute<Null>(
                              builder: (BuildContext context) {
                                return ChatScreen();
                              },
                              fullscreenDialog: true));

                        },
                        child: Container(
                          height: 60,
                          width: 100,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.mail,color: whiteColor,),
                              Text('Message',style: TextStyle(fontSize: 18,color: whiteColor,fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          print('ok');
                        },
                        child: Container(
                          height: 60,
                          width: 100,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: greyColor2,
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.delete,color: whiteColor,),
                              Text('Cancel',style: TextStyle(fontSize: 18,color: whiteColor,fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
