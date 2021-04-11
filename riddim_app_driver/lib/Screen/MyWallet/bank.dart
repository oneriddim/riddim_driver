import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app_driver/Components/customDialogInfo.dart';
import 'package:riddim_app_driver/Repository/konnectRepository.dart';
import 'package:riddim_app_driver/data/Model/userModel.dart';
import 'package:riddim_app_driver/theme/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:riddim_app_driver/Components/historyTrip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';

class BankDetail extends StatefulWidget {
  //final String id;

  //HistoryDetail({this.id});

  @override
  _BankDetailState createState() => _BankDetailState();
}

class _BankDetailState extends State<BankDetail> {
  final userRepository = KonnectRepository();
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String yourReview;
  double ratingScore;
  User _currentUser;
  Map _cardInfo;

  String name = "";
  String number = "";

  @override
  void initState() {
    super.initState();
    _getCardInfo();
  }

  Future<void> _getCardInfo() async {
    Fluttertoast.showToast(
        msg: "Getting Details",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = await userRepository.getUser(prefs.getString("usertoken"));

    final info = await userRepository.bankInfo(token: user.userid);

    setState(() {
      _currentUser = user;
      if (info.length > 0) {
        _cardInfo = info;
        name = _cardInfo["name"];
        number = _cardInfo["account"];
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _submit() async {
    Fluttertoast.showToast(
        msg: "Please wait..",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );

    formKey.currentState.save();

    final success = await userRepository.saveBankInfo(
      token: _currentUser.userid,
      name: name,
      number: number,
    );

    if(success) {
      Fluttertoast.showToast(
          msg: "Saved",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );

      Navigator.of(context).pushReplacementNamed('/my_wallet');
      Navigator.popAndPushNamed(context, '/my_wallet');
    } else {
      Fluttertoast.showToast(
          msg: "Unable to save info",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bank Information' ,
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
          actions: <Widget>[
          ]
      ),
      bottomNavigationBar: ButtonTheme(
        minWidth: screenSize.width,
        height: 45.0,
        child: RaisedButton(
          elevation: 0.0,
          color: primaryColor,
          child: Text('SAVE',style: headingWhite,
          ),
          onPressed: (){
            _submit();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            color: greyColor,
            child: Column(
              children: <Widget>[
                Form(
                  key: formKey,
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    padding: EdgeInsets.all(10.0),
                    color: whiteColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  style: textStyle,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      prefixIcon: Icon(Icons.account_balance,
                                        color: Color(getColorHexFromStr('#FEDF62')), size: 20.0,),
                                      contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                                      hintText: 'Bank',
                                      hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand')
                                  ),
                                  controller: new TextEditingController.fromValue(
                                    new TextEditingValue(
                                      text: name != null? name : "",
                                      selection: new TextSelection.collapsed(
                                          offset: 11),
                                    ),
                                  ),
                                  onChanged: (String _name) {
                                    name = _name;
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 25),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  style: textStyle,
                                  keyboardType: TextInputType.number,
                                  decoration:  InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      prefixIcon: Icon(Icons.filter_1,
                                        color: Color(getColorHexFromStr('#FEDF62')), size: 20.0,),
                                      contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                                      hintText: 'Account #',
                                      hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand')
                                  ),
                                  controller: new TextEditingController.fromValue(
                                    new TextEditingValue(
                                      text: number != null? number : "",
                                      selection: new TextSelection.collapsed(
                                          offset: 11),
                                    ),
                                  ),
                                  onChanged: (String _month) {
                                    number = _month;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
