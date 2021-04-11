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

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final userRepository = KonnectRepository();
  final String screenName = "HISTORY";
  DateTime selectedDate = DateTime.now();
  List<dynamic> _listRequest = List<dynamic>();
  String totaltics = "0";
  String earnings = "0.00";

  String selectedMonth = '';
  User _currentUser;
  String _currentTicketId = "";

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
          msg: "Getting Jobs for " + DateFormat("EEE, MMM d").format(selectedDate ),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );

      final results = await userRepository.getCompletedTickets(
          date: DateFormat("yyyy-MM-dd").format(selectedDate ),
          token: _currentUser.userid
      );
      setState(() {
        _listRequest = results["data"];
        totaltics = results["total"];
        earnings = results["earnings"];
      });
    }
  }

  navigateToDetail(String ticket) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ticket", ticket);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => HistoryDetail()));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
      ),
      drawer: _currentUser != null? new MenuScreens(activeScreenName: screenName, user: _currentUser): new MenuScreensDefault(activeScreenName: screenName),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 120.0,
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: CalendarCarousel(
                weekendTextStyle: TextStyle(
                  color: Colors.red,
                ),
                  headerTextStyle: TextStyle(
                  color: Colors.black45
                ),
                  inactiveWeekendTextStyle: TextStyle(
                    color: Colors.black45
                  ),
                headerMargin: EdgeInsets.all(0.0),
                thisMonthDayBorderColor: Colors.grey,
                weekFormat: false,
                height: 150.0,
                selectedDateTime: selectedDate,
                selectedDayBorderColor: blue1,
                selectedDayButtonColor: blue2,
                todayBorderColor: primaryColor,
                todayButtonColor: primaryColor,
                onDayPressed: (DateTime date, List<dynamic> events) {
                  this.setState(() => selectedDate = date);
                  print(selectedDate);
                  _getCompletedTickets();
                },
                onCalendarChanged: (DateTime date) {
                  this.setState(() => selectedMonth = DateFormat.yMMM().format(date));
                  print(selectedMonth);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.deepPurple,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      height: 80,
                      width: screenSize.width*0.4,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.content_paste,size: 30.0,),
                          SizedBox(width: 10,),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Job",style: heading18,),
                                Text(totaltics == null ? "0": totaltics,style: headingWhite,)
                              ],
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.deepPurple,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      height: 80,
                      width: screenSize.width*0.4,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.attach_money,size: 30.0,),
                          SizedBox(width: 10,),
                          Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Earning",style: heading18,),
                                  Text(earnings == null? "\$ 0.00": earnings,style: headingWhite,)
                                ],
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
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
                          child: historyItem(index)
                      );
                    }
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget historyItem(int index) {
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
                          imageUrl: Config.userImageUrl + _listRequest[index]['avatar'],
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
                          Text(_listRequest[index]['name'],style: textBoldBlack,),
                          Text(_listRequest[index]['dropoffdate'], style: textGrey,),
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
                          Text("\$" + _listRequest[index]['price'],style: textBoldBlack,),
                          Text(_listRequest[index]['distance'] + " Km",style: textGrey,),
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
                          Text(_listRequest[index]['pickup'],style: textStyle,),

                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("DROP OFF".toUpperCase(),style: textGreyBold,),
                          Text(_listRequest[index]['dropoff'],style: textStyle,),

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
