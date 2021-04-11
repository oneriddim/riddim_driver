import 'package:flutter/material.dart';
import 'package:riddim_app_driver/Screen/Documents/documents.dart';
import 'package:riddim_app_driver/Screen/History/history.dart';
import 'package:riddim_app_driver/Screen/Home/home.dart';
import 'package:riddim_app_driver/Screen/Login/login.dart';
import 'package:riddim_app_driver/Screen/MyProfile/myProfile.dart';
import 'package:riddim_app_driver/Screen/MyProfile/profile.dart';
import 'package:riddim_app_driver/Screen/MyWallet/myWallet.dart';
import 'package:riddim_app_driver/Screen/MyWallet/payment.dart';
import 'package:riddim_app_driver/Screen/Notification/notification.dart';
import 'package:riddim_app_driver/Screen/Request/request.dart';
import 'package:riddim_app_driver/Screen/Settings/settings.dart';
import 'package:riddim_app_driver/Screen/SignUp/signup2.dart';
import 'package:riddim_app_driver/Screen/UseMyLocation/useMyLocation.dart';
import 'package:riddim_app_driver/Screen/Walkthrough/walkthrough.dart';

import 'Screen/Documents/document.dart';

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.isInitialRoute) return child;
    if (animation.status == AnimationStatus.reverse)
      return super.buildTransitions(context, animation, secondaryAnimation, child);
    return FadeTransition(opacity: animation, child: child);
  }
}

MaterialPageRoute getRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/home': return new MyCustomRoute(
      builder: (_) => new HomeScreen(),
      settings: settings,
    );
    case '/signup2': return new MyCustomRoute(
      builder: (_) => new SignupScreen2(),
      settings: settings,
    );
    case '/login': return new MyCustomRoute(
      builder: (_) => new LoginScreen(),
      settings: settings,
    );
    case '/walkthrough': return new MyCustomRoute(
      builder: (_) => new WalkthroughScreen(),
      settings: settings,
    );
    case '/use_my_location': return new MyCustomRoute(
      builder: (_) => new UseMyLocation(),
      settings: settings,
    );
    case '/payment_method': return new MyCustomRoute(
      builder: (_) => new PaymentMethod(),
      settings: settings,
    );
    case '/request': return new MyCustomRoute(
      builder: (_) => new RequestScreen(),
      settings: settings,
    );
    case '/my_wallet': return new MyCustomRoute(
      builder: (_) => new MyWallet(),
      settings: settings,
    );
    case '/history': return new MyCustomRoute(
      builder: (_) => new HistoryScreen(),
      settings: settings,
    );
    case '/notification': return new MyCustomRoute(
      builder: (_) => new NotificationScreens(),
      settings: settings,
    );
    case '/setting': return new MyCustomRoute(
      builder: (_) => new SettingsScreen(),
      settings: settings,
    );
    case '/profile': return new MyCustomRoute(
      builder: (_) => new Profile(),
      settings: settings,
    );
    case '/edit_prifile': return new MyCustomRoute(
      builder: (_) => new MyProfile(),
      settings: settings,
    );
    case '/logout': return new MyCustomRoute(
      builder: (_) => new LoginScreen(),
      settings: settings,
    );
    case '/documents': return new MyCustomRoute(
      builder: (_) => new DocumentsScreen(),
      settings: settings,
    );
    case '/edit_document': return new MyCustomRoute(
      builder: (_) => new Document(),
      settings: settings,
    );
    default:
      return new MyCustomRoute(
        builder: (_) => new HomeScreen(),
        settings: settings,
      );
  }
}