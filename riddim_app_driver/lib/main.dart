import 'package:flutter/material.dart';
import 'package:riddim_app_driver/Screen/SplashScreen/SplashScreen.dart';
import 'theme/style.dart';
import 'router.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riddim Driver',
      theme: appTheme,
      onGenerateRoute: (RouteSettings settings) => getRoute(settings),
      home: SplashScreen(),
    );
  }
}