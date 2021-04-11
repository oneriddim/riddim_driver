import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app_driver/Repository/konnectRepository.dart';
import 'package:riddim_app_driver/Screen/Menu/MenuDefault.dart';
import 'package:riddim_app_driver/data/Model/userModel.dart';
import 'package:riddim_app_driver/theme/style.dart';
import 'package:riddim_app_driver/Screen/Menu/Menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';
import 'detail.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:cached_network_image/cached_network_image.dart';

import 'document.dart';

class DocumentsScreen extends StatefulWidget {
  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final userRepository = KonnectRepository();
  final String screenName = "DOCUMENTS";
  List<dynamic> _listRequest = List<dynamic>();
  User _currentUser;
  String _currentDocumentId = "";

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

    _getCompletedTickets();
  }

  void _getCompletedTickets() async {
    if (_currentUser != null) {
      Fluttertoast.showToast(
          msg: "Getting Documents",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );

      final results = await userRepository.getDocuments(
          token: _currentUser.userid
      );
      setState(() {
        _listRequest = results;
      });
    }
  }

  navigateToDetail(String document) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("document", document);
    //check the type and direct accordingly
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Document()));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vehicle & Documents',
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
      ),
      drawer: _currentUser != null? new MenuScreens(activeScreenName: screenName, user: _currentUser): new MenuScreensDefault(activeScreenName: screenName),
      body: Container(
        child: Scrollbar(
                child: ListView.builder(
                  shrinkWrap: true,
                    itemCount: _listRequest.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            print('$index');
                            navigateToDetail(_listRequest[index]["id"]);
                          },
                          child: _listRequest[index]["type"] == "3"?  vehicleItem(index) : documentItem(index)
                      );
                    }
                ),
              ),
      )
    );
  }

  Widget documentItem(int index) {
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
                        borderRadius: BorderRadius.circular(15.0),
                        child: CachedNetworkImage(
                          imageUrl: Config.documentImageUrl + _listRequest[index]['id'],
                          fit: BoxFit.cover,
                          width: 75.0,
                          height: 75.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(_listRequest[index]['num'],style: textBoldBlack,),
                              ],
                            ),
                          ),
                          Divider(),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("ISSUED".toUpperCase() + ": " + _listRequest[index]['issue'],style: textGreyBold,),
                              ],
                            ),
                          ),
                          Divider(),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("EXPIRY".toUpperCase() + ": " + _listRequest[index]['expiry'],style: textGreyBold,),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                              ],
                            ),
                          ),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          //Text("EXPIRY".toUpperCase(),style: textGreyBold,),
                          Text(_listRequest[index]['document'].toString().toUpperCase(), style: textBoldBlack,),

                        ],
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),
      );
  }

  Widget vehicleItem(int index) {
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
                        borderRadius: BorderRadius.circular(15.0),
                        child: CachedNetworkImage(
                          imageUrl: Config.documentImageUrl + _listRequest[index]['id'],
                          fit: BoxFit.cover,
                          width: 75.0,
                          height: 75.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("REG #".toUpperCase() + ": " + _listRequest[index]['num'],style: textBoldBlack,),
                              ],
                            ),
                          ),
                          Divider(),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("MAKE".toUpperCase() + ": " + _listRequest[index]['make'],style: textGreyBold,),
                              ],
                            ),
                          ),
                          Divider(),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("MODEL".toUpperCase() + ": " + _listRequest[index]['model'],style: textGreyBold,),
                              ],
                            ),
                          ),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          //Text("EXPIRY".toUpperCase(),style: textGreyBold,),
                          Text(_listRequest[index]['document'].toString().toUpperCase(), style: textBoldBlack,),

                        ],
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),
      );
  }
}
