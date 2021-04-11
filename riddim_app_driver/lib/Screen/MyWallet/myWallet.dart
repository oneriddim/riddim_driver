import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app_driver/Repository/konnectRepository.dart';
import 'package:riddim_app_driver/Screen/Menu/MenuDefault.dart';
import 'package:riddim_app_driver/Screen/MyWallet/bank.dart';
import 'package:riddim_app_driver/data/Model/userModel.dart';
import 'package:riddim_app_driver/theme/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:riddim_app_driver/Screen/Menu/Menu.dart';
import 'package:riddim_app_driver/Components/card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWallet extends StatefulWidget {
  @override
  _MyWalletState createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  final userRepository = KonnectRepository();
  final String screenName = "MY WALLET";
  User _currentUser;
  List<dynamic> _listHistory = List<dynamic>();
  String bank;
  String account;
  String balance;


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

      _getMyWallet();
    });
  }

  Future<Map> _getMyWallet() async {
    Fluttertoast.showToast(
        msg: "Getting Details",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );

    final results = await userRepository.getMyWallet(
        token: _currentUser.userid
    );
    setState(() {
      _listHistory = results["history"];
      bank = results["bank"];
      account = results["account"];
      balance = results["balance"];
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('My Wallet',style: TextStyle(color: blackColor),),
        backgroundColor: whiteColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: blackColor),

      ),
      drawer: _currentUser != null? new MenuScreens(activeScreenName: screenName, user: _currentUser): new MenuScreensDefault(activeScreenName: screenName),
      body: Scrollbar(
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: BankCard(
                card: BankCardModel('assets/image/icon/bg_blue_card.png',
                    'BANK ACCT',
                    _currentUser != null? _currentUser.fullname : "",
                    account != null? account: "",
                    bank != null? bank : "",
                    balance != null? balance : ""),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 50.0,bottom: 30.0),
              child: Column(
                children: <Widget>[
                  Text('Balance',style: textStyle,),
                  Text(balance != null? balance : "\$ 0.00",style: heading35Primary,),
                ],
              ),
            ),

            GestureDetector(
              onTap: (){
                Navigator.of(context).push(new MaterialPageRoute<Null>(
                  builder: (BuildContext context) {
                    return BankDetail();
                  },
                ));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.0,right: 20.0),
                padding: EdgeInsets.only(top: 10.0,bottom: 10.0,left: 10.0,right: 10.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x88999999),
                        offset: Offset(0, 5),
                        blurRadius: 5.0,
                      ),
                    ]),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Icon(FontAwesomeIcons.moneyCheck,color: blackColor,),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Text("Bank account info.",style: textBoldBlack,)
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Icon(Icons.arrow_forward_ios,color: blackColor,),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30.0,bottom: 10.0,left: 20.0),
              child: Text('HISTORY CARDS',style: textStyle,),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _listHistory.length,
              itemBuilder: (BuildContext context, index){
                return Container(
                  margin: EdgeInsets.only(left: 20.0,right: 20.0,bottom: 10.0),
                  child: historyCard(_listHistory[index]['name'],_listHistory[index]['date'],_listHistory[index]['amt'])
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget historyCard(String title, String date, String balance) {
    return Container(
      padding: EdgeInsets.only(
          top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Color(0x88999999),
              offset: Offset(0, 5),
              blurRadius: 5.0,
            ),
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: 50.0,
            width: 50.0,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: Icon(Icons.attach_money, color: whiteColor, size: 30.0,),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(title, style: textBoldBlack,)
                ),
                Container(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(date, style: textGrey,)
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(balance, style: heading18Black,)
            ),
          ),
        ],
      ),
    );
  }
}
