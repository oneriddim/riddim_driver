import 'package:flutter/material.dart';
import 'package:riddim_app_driver/Repository/konnectRepository.dart';
import 'package:riddim_app_driver/Screen/Menu/Menu.dart';
import 'package:riddim_app_driver/Screen/Menu/MenuDefault.dart';
import 'package:riddim_app_driver/Screen/Notification/itemNotification.dart';
import 'package:riddim_app_driver/data/Model/userModel.dart';
import 'package:riddim_app_driver/theme/style.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationScreens extends StatefulWidget {
  @override
  _NotificationScreensState createState() => _NotificationScreensState();
}

class _NotificationScreensState extends State<NotificationScreens> {
  final userRepository = KonnectRepository();
  final String screenName = "NOTIFICATIONS";
  User _currentUser;

  List<Map<String, dynamic>> listNotification = List<Map<String, dynamic>>();

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = await userRepository.getUser(prefs.getString("usertoken"));
    setState(() {
      _currentUser = user;
    });
  }

  navigateToDetail(String id){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationDetail(id: id,)));
  }

  dialogInfo(){
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text("Confirm Delete"),
            content: Text("Are you sure delete all notification ?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: (){Navigator.pop(context);},
                  child: new Text('CANCEL',style: textGrey,)),
              FlatButton(
                  onPressed: (){
                    setState(() {
                      listNotification.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK')),
            ],
          );
        }
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentUser();
    listNotification = [
    ];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notification',style: TextStyle(color: blackColor),),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
          actions: <Widget>[
            new IconButton(
                icon: Icon(Icons.restore_from_trash,color: blackColor,),
                onPressed: (){
                  dialogInfo();
                }
            )
          ]
      ),
        drawer: _currentUser != null? new MenuScreens(activeScreenName: screenName, user: _currentUser): new MenuScreensDefault(activeScreenName: screenName),
        body: listNotification.length != 0 ?
        Scrollbar(
          child: ListView.builder(
              itemCount: listNotification.length,
              itemBuilder: (BuildContext context, int index){
                return Slidable(
                    actionPane: SlidableScrollActionPane(),
                    actionExtentRatio: 0.25,
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: 'Delete',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: (){
                          setState(() {
                            listNotification.removeAt(index);
                          });
                        },
                      ),
                    ],
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: greyColor,width: 1)
                            )
                        ),
                        child: GestureDetector(
                            onTap: (){
                              print('$index');
                              navigateToDetail(index.toString());
                            },
                            child: ItemNotification(
                              title: listNotification[index]['title'],
                              subTitle: listNotification[index]['subTitle'],
                              icon: listNotification[index]['icon'],
                            )
                        )
                    )
                );
              }
          ),
        ): Container(
          height: screenSize.height,
          child: Center(
            child: Image.asset('assets/image/empty_state_trash_300.png',width: 100.0,),
          ),
        )
    );
  }
}
