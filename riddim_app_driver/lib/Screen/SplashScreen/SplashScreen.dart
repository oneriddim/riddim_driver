import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riddim_app_driver/theme/style.dart' as prefix0;
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  Animation animation, delayedAnimation, muchDelayAnimation, transfor,fadeAnimation;
  AnimationController animationController;


  @override
  void initState(){
    super.initState();
    animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    animation = Tween(begin: 0.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.fastOutSlowIn
    ));
    
    transfor = BorderRadiusTween(
      begin: BorderRadius.circular(125.0),
      end: BorderRadius.circular(0.0)).animate(
      CurvedAnimation(parent: animationController, curve: Curves.ease)
    );
    fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    animationController.forward();
    new Timer(new Duration(seconds: 3), () {
      goTo();
    });
  }

  goTo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("usertoken")) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Scaffold(
            body: new Container(
              decoration: new BoxDecoration(color: prefix0.backgroundColor),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Flexible(
                      flex: 1,
                      child: new Center(
                          child: FadeTransition(
                              opacity: fadeAnimation,
                              child:
                              Image.asset("assets/image/riddim_logo.png",)
                          ),
                      ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
