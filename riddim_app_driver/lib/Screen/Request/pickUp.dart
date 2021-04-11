import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:riddim_app_driver/Repository/konnectRepository.dart';
import 'package:riddim_app_driver/Screen/Home/home.dart';
import 'package:riddim_app_driver/data/Model/get_routes_request_model.dart';
import 'package:riddim_app_driver/data/Model/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/style.dart';
import '../../Components/slidingUpPanel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../google_map_helper.dart';
import '../../Networking/Apis.dart';
import '../../data/Model/direction_model.dart';
import 'stepsPartView.dart';
import 'package:riddim_app_driver/Components/loading.dart';
import 'imageSteps.dart';

class PickUp extends StatefulWidget {
  @override
  _PickUpState createState() => _PickUpState();
}

class _PickUpState extends State<PickUp> {
  final userRepository = KonnectRepository();
  var apis = Apis();
  GoogleMapController _mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Map<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 1;
  PolylineId selectedPolyline;
  bool checkPlatform = Platform.isIOS;

  //LatLng currentLocation = LatLng(39.155232, -95.473636);

  LatLng fromLocation;
  LatLng toLocation;

  Position currentLocation;
  Position _lastKnownPosition;
  String _placemark = '';
  String currentLocationName;

  String distance, duration;
  List<Routes> routesData;

  User _currentUser;
  Map _ticketInfo;
  String _ticketId;
  Timer _waitForPassenger;
  Timer _everyTenSecond;

  bool isPickedUp = false;

  final GMapViewHelper _gMapViewHelper = GMapViewHelper();

  BitmapDescriptor _dropoffIcon;
  BitmapDescriptor _pickupIcon;
  BitmapDescriptor _taxiIcon;


  @override
  void initState() {
    super.initState();
    _getTicketInfo();
    _initLastKnownLocation();
    _initCurrentLocation();
    _updates();
  }

  @override
  void didUpdateWidget(PickUp oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _initLastKnownLocation();
    _initCurrentLocation();
    if(currentLocation != null ){
      moveCameraToMyLocation();
    }
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

        fromLocation = LatLng(double.parse(_ticketInfo["plat"]), double.parse(_ticketInfo["plng"]));
        toLocation = LatLng(double.parse(_ticketInfo["dlat"]), double.parse(_ticketInfo["dlng"]));

        addMarker();
        getRouter();

        if (_ticketInfo["datepickup"] != "") {
          isPickedUp = true;
        }
      }
    });
  }

  void _updates() async {
    _everyTenSecond = Timer.periodic(Duration(seconds: 10), (Timer t) {
      //print("RUNNING TIMER");
      _initCurrentLocation(); // get current location
      _updateMyLocation(); // update server
    });
  }

  void _updateMyLocation() async {
    if (_currentUser != null && currentLocation != null) {
      await userRepository.saveMyLocation(
          token: _currentUser.userid,
          lat: currentLocation?.latitude,
          long: currentLocation?.longitude);
    }
  }

  ///Get last known location
  Future<void> _initLastKnownLocation() async {
    Position position;
    try {
      final Geolocator geolocator = Geolocator()
        ..forceAndroidLocationManager = true;
      position = await geolocator?.getLastKnownPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    } on PlatformException {
      position = null;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _lastKnownPosition = position;
    });
  }

  /// Get current location
  _initCurrentLocation() async {
    try {
      Geolocator()
        ..forceAndroidLocationManager = true
        ..getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
        )?.then((position) {
          if (mounted) {
            currentLocation = position;
            if(currentLocation != null ){
              //addDriverMarker();
              moveCameraToMyLocation();
            }
          }
        })?.catchError((e) {
        });
    } on PlatformException {
    }
  }

  void moveCameraToMyLocation(){
    _mapController?.animateCamera(
      CameraUpdate?.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation?.latitude,currentLocation?.longitude),
          zoom: 17.0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_waitForPassenger != null)  _waitForPassenger.cancel();
    if (_everyTenSecond != null)  _everyTenSecond.cancel();
  }

  void _onMapCreated(GoogleMapController controller) {
    this._mapController = controller;
    LatLng position = LatLng(currentLocation != null ? currentLocation?.latitude : 10.536421, currentLocation != null ? currentLocation?.longitude : -61.311951);

    Future.delayed(Duration(milliseconds: 200), () async {
      this._mapController = controller;
      controller?.animateCamera(
        CameraUpdate?.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 15.0,
          ),
        ),
      );
    });
  }


  addDriverMarker() {
    /*final MarkerId _driver = MarkerId("driver");

    setState(() {
      markers[_driver] = GMapViewHelper.createMaker(
        markerIdVal: "driver",
        icon: checkPlatform ? "assets/image/icon_car_32.png" : "assets/image/icon_car_120.png",
        lat: currentLocation?.latitude,
        lng: currentLocation?.longitude,
      );
    });*/
  }

  addMarker(){
    final MarkerId _markerFrom = MarkerId("fromLocation");
    final MarkerId _markerTo = MarkerId("toLocation");

    setState(() {
      markers[_markerFrom] = GMapViewHelper.createMaker(
        markerIdVal: "fromLocation",
        icon: checkPlatform ? "assets/image/gps_point_24.png" : "assets/image/gps_point.png",
        lat: fromLocation.latitude,
        lng: fromLocation.longitude,
      );

      markers[_markerTo] = GMapViewHelper.createMaker(
        markerIdVal: "toLocation",
        icon: checkPlatform ? "assets/image/ic_marker_32.png" : "assets/image/ic_marker_128.png",
        lat: toLocation.latitude,
        lng: toLocation.longitude,
      );
    });
  }

  void getRouter() async {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    final PolylineId polylineId = PolylineId(polylineIdVal);
    polyLines.clear();
    var router;

    await apis.getRoutes(
        getRoutesRequest: GetRoutesRequestModel(
            fromLocation: fromLocation,
          toLocation: toLocation,
          mode: "driving"
        ),
    ).then((data) {
      if (data != null) {
        router = data.result.routes[0].overviewPolyline.points;
        routesData = data.result.routes;
      }
    }).catchError((error) {
      print("DiscoveryActionHandler::GetRoutesRequest > $error");
    });

    distance = routesData[0].legs[0].distance.text;
    duration = routesData[0].legs[0].duration.text;

    polyLines[polylineId] = GMapViewHelper.createPolyline(
        polylineIdVal: polylineIdVal,
        router: router,
        formLocation: fromLocation,
        toLocation: toLocation,
    );
    setState(() {});
    _gMapViewHelper.cameraMove(fromLocation: fromLocation,toLocation: toLocation, mapController: _mapController);
  }

  _pickup() async {
    final pickup = await userRepository.pickupTicket(
      ticket: _ticketId,
      token: _currentUser.userid,
      lat: currentLocation.latitude.toString(),
      lng: currentLocation.longitude.toString()
    );
    if (pickup) {
      setState(() {
        isPickedUp = true;
      });
    }

  }

  _dropoff() async {
    final dropoff = await userRepository.dropoffTicket(
        ticket: _ticketId,
        token: _currentUser.userid,
        lat: currentLocation.latitude.toString(),
        lng: currentLocation.longitude.toString()
    );
    if (dropoff) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
    }
    //Navigator.pushNamed(context, '/home');
    //Navigator.of(context).push(MaterialPageRoute(builder: (context) => PickUp()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _buildInfoLayer(),
          Positioned(
            top: 30.0,
            left: 0.0,
            child: _buildStepDirection(),
          )
        ],
      ),
    );
  }

  Widget _buildStepDirection(){
    final screenSize = MediaQuery.of(context).size;
    return Container();
    /*
    return Container(
      height: 50.0,
      width: screenSize.width,
      color: greenColor,
      child: Row(
        children: <Widget>[/*
          IconButton(
            icon: Icon(Icons.arrow_upward,color: blackColor,),
            onPressed: (){
            },
          ),
          Container(
            padding: EdgeInsets.only(left: 5.0,right: 5.0),
            child: Text("500 miles",style: textBoldBlack,),
          ),
          Text("Head southwest on Madison St",style: textStyle,)*/
        ],
      ),
    );*/
  }

  Widget _buildInfoLayer(){
    final screenSize = MediaQuery.of(context).size;
    final maxHeight = 0.70*screenSize.height;
    final minHeight = 130.0;

    final panel =
    Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
              ),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(duration == null ? '' : duration,style: headingBlack,),
                          Text( _ticketInfo == null ? ' / \$0.00' : ' / \$' + _ticketInfo["cost"],style: headingPrimaryColor,)
                        ],
                      ),
                      Text(distance == null ? '' : distance,style: textStyle,),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    print("Reset");
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    margin: EdgeInsets.only(left: 10.0,right: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      color: primaryColor,
                    ),
//                    Icon(MdiIcons.directionsFork,),
                    child: Icon(MdiIcons.directionsFork,color: whiteColor,),
                  ),
                ),
                Container(
                  width: 70.0,
                  child: ButtonTheme(
                    minWidth: 50,
                    height: 35.0,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      elevation: 0.0,
                      color: redColor,
                      child: Text('Exit'.toUpperCase(),style: heading14,
                      ),
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
//          Container(
//            padding: EdgeInsets.only(top: 10.0),
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                GestureDetector(
//                  onTap: (){
//                    print("Reset");
//                  },
//                  child: Container(
//                    height: 40,
//                    width: 40,
//                    margin: EdgeInsets.only(left: 10.0,right: 10.0),
//                    decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(50.0),
//                      color: primaryColor,
//                    ),
//                    child: Icon(Icons.arrow_back_ios,color: whiteColor,),
//                  ),
//                ),
//                GestureDetector(
//                  onTap: (){
//                    print("Reset");
//                  },
//                  child: Container(
//                    height: 40,
//                    width: 40,
//                    margin: EdgeInsets.only(left: 10.0,right: 10.0),
//                    decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(50.0),
//                      color: primaryColor,
//                    ),
//                    child: Icon(Icons.arrow_forward_ios,color: whiteColor,),
//                  ),
//                ),
//              ],
//            ),
//          ),
          Container(
            padding: EdgeInsets.only(top: 10.0),
            child: ButtonTheme(
              minWidth: screenSize.width ,
              height: 35.0,
              child:  isPickedUp == false ? RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                elevation: 0.0,
                color: primaryColor,
                child: Text('PICK UP'.toUpperCase(),style: headingWhite,
                ),
                onPressed: (){
                  _pickup();
                },
              ) : RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                elevation: 0.0,
                color: primaryColor,
                child: Text('DROP OFF'.toUpperCase(),style: headingWhite,
                ),
                onPressed: (){
                  _dropoff();
                },
              ),
            ),
          ),
          Divider(),
          Expanded(
            child:
            routesData != null ?
            ListView.builder(
              shrinkWrap: true,
              itemCount: routesData[0].legs[0].steps.length,
              itemBuilder: (BuildContext context, index){
                return StepsPartView(
                  instructions: routesData[0].legs[0].steps[index].htmlInstructions,
                  duration: routesData[0].legs[0].steps[index].duration.text,
                  imageManeuver: getImageSteps(routesData[0].legs[0].steps[index].maneuver),
                );
              },
            ): Container(
              child: LoadingBuilder(),
            ),
          )
        ],
      )
    );

    return SlidingUpPanel(
      maxHeight: maxHeight,
      minHeight: minHeight,
      parallaxEnabled: true,
      parallaxOffset: .5,
      panel: panel,
      body: _buildMapLayer(),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
      onPanelSlide: (double pos) => setState(() {
      }),
    );
  }

  Widget _buildMapLayer(){
    return currentLocation == null ?
      Center(child: CupertinoActivityIndicator())
        : SizedBox(
            height: MediaQuery.of(context).size.height,
            child: _gMapViewHelper.buildMapView(
              context: context,
              onMapCreated: _onMapCreated,
              currentLocation: LatLng(currentLocation.latitude, currentLocation.longitude),
              markers: markers,
              polyLines: polyLines,
              onTap: (_){

              }
            ),
    );
  }
}
