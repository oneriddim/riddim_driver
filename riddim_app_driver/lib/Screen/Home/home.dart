import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app_driver/Repository/konnectRepository.dart';
import 'package:riddim_app_driver/Screen/Home/myActivity.dart';
import 'package:riddim_app_driver/Screen/Menu/MenuDefault.dart';
import 'package:riddim_app_driver/Screen/Request/pickUp.dart';
import 'package:riddim_app_driver/Screen/Request/requestDetail.dart';
import 'package:riddim_app_driver/config.dart';
import 'package:riddim_app_driver/data/Model/userModel.dart';
import 'package:riddim_app_driver/theme/style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:riddim_app_driver/Components/loading.dart';
import 'package:riddim_app_driver/Screen/Menu/Menu.dart';
import 'package:riddim_app_driver/data/Model/placeItem.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'radioSelectMapType.dart';
import 'package:riddim_app_driver/data/Model/mapTypeModel.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import '../../Components/itemRequest.dart';
import '../../google_map_helper.dart';
import '../../data/Model/direction_model.dart';
import 'package:flutter/cupertino.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final userRepository = KonnectRepository();
  final String screenName = "HOME";
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  CircleId selectedCircle;
  GoogleMapController _mapController;

  String currentLocationName;
  String newLocationName;
  String _placemark = '';
  GoogleMapController mapController;
  PlaceItemRes fromAddress;
  PlaceItemRes toAddress;
  bool checkPlatform = Platform.isIOS;
  double distance = 0;
  bool nightMode = false;
  VoidCallback showPersBottomSheetCallBack;
  List<MapTypeModel> sampleData = new List<MapTypeModel>();
  PersistentBottomSheetController _controller;
  List<dynamic> listRequest = List<dynamic>();

  List<Routes> routesData;
  final GMapViewHelper _gMapViewHelper = GMapViewHelper();
  Map<PolylineId, Polyline> _polyLines = <PolylineId, Polyline>{};
  PolylineId selectedPolyline;
  bool isShowDefault = true;
  Position currentLocation;
  Position _lastKnownPosition;
  User _currentUser;
  Timer _everyTenSecond;
  String _currentTicketId = "";

  BitmapDescriptor _dropoffIcon;
  BitmapDescriptor _pickupIcon;
  BitmapDescriptor _taxiIcon;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _initLastKnownLocation();
    _initCurrentLocation();
    _updates();
    showPersBottomSheetCallBack = _showBottomSheet;
    sampleData.add(MapTypeModel(1,true, 'assets/style/maptype_nomal.png', 'Nomal', 'assets/style/nomal_mode.json'));
    sampleData.add(MapTypeModel(2,false, 'assets/style/maptype_silver.png', 'Silver', 'assets/style/sliver_mode.json'));
    sampleData.add(MapTypeModel(3,false, 'assets/style/maptype_dark.png', 'Dark', 'assets/style/dark_mode.json'));
    sampleData.add(MapTypeModel(4,false, 'assets/style/maptype_night.png', 'Night', 'assets/style/night_mode.json'));
    sampleData.add(MapTypeModel(5,false, 'assets/style/maptype_netro.png', 'Netro', 'assets/style/netro_mode.json'));
    sampleData.add(MapTypeModel(6,false, 'assets/style/maptype_aubergine.png', 'Aubergine', 'assets/style/aubergine_mode.json'));
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _initLastKnownLocation();
    _initCurrentLocation();
    if(currentLocation != null ){
      moveCameraToMyLocation();
    }
  }

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = await userRepository.getUser(prefs.getString("usertoken"));
    prefs.remove("ticket");

    Fluttertoast.showToast(
        msg: "Welcome " + user.fullname,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );

    setState(() {
      _currentUser = user;
    });

  }

  @override
  void dispose() {
    super.dispose();
    if (_everyTenSecond != null) _everyTenSecond.cancel();
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
              print(currentLocation.toString());
              addDriverMarker();
              moveCameraToMyLocation();
            }
          }
        })?.catchError((e) {
        });
    } on PlatformException {
    }
  }

  void _updates() async {
    _everyTenSecond = Timer.periodic(Duration(seconds: 10), (Timer t) {
      //print("RUNNING TIMER");
      _initCurrentLocation();
      _updateMyLocation();
      _getNearbyTickets();
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

  void _getNearbyTickets() async {
    if (_currentUser != null && isShowDefault == true) {
      final results = await userRepository.getNearbyTickets(
          ticket: _currentTicketId,
          token: _currentUser.userid
      );

      setState(() {
        if (results.length != 0) {
          addMarker(LatLng(double.parse(results[0]['plat']), double.parse(results[0]['plng'])), LatLng(double.parse(results[0]['dlat']), double.parse(results[0]['dlng'])));
          //_currentTicketId = results[0]['id'];
          isShowDefault = false;
        }
        listRequest = results["data"];

        _currentUser.tickets = results["tickets"];
        _currentUser.hours = results["hours"];
        _currentUser.distance = results["distance"];
        _currentUser.rating = results["rating"];
        _currentUser.earn = results["earnings"];

        userRepository.saveUser(_currentUser);
      });
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


  void _onMapCreated(GoogleMapController controller) async {
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

  Future<String> _getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void _setMapStyle(String mapStyle) {
    setState(() {
      nightMode = true;
      _mapController.setMapStyle(mapStyle);
    });
  }

  void changeMapType(int id, String fileName){
    print(fileName);
    if (fileName == null) {
      setState(() {
        nightMode = false;
        _mapController.setMapStyle(null);
      });
    } else {
      _getFileData(fileName).then(_setMapStyle);
    }
  }

  void _showBottomSheet() async {
    setState(() {
      showPersBottomSheetCallBack = null;
    });
    _controller = await _scaffoldKey.currentState
        .showBottomSheet((context) {
      return new Container(
        height: 300.0,
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text("Map type",style: heading18Black,),
                  ),
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.close,color: blackColor,),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
              Expanded(
                child:
                new GridView.builder(
                  itemCount: sampleData.length,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                      highlightColor: primaryColor,
                      splashColor: Colors.blueAccent,
                      onTap: () {
                        _closeModalBottomSheet();
                        sampleData.forEach((element) => element.isSelected = false);
                        sampleData[index].isSelected = true;
                        changeMapType(sampleData[index].id, sampleData[index].fileName);

                      },
                      child: new MapTypeItem(sampleData[index]),
                    );
                  },
                ),
              )

            ],
          ),
        )
      );
    });
  }

  void _closeModalBottomSheet() {
    if (_controller != null) {
      _controller.close();
      _controller = null;
    }
  }


  addDriverMarker() {
  }

  addMarker(LatLng locationForm, LatLng locationTo){
    _markers.clear();

    addDriverMarker();

    final MarkerId _markerFrom = MarkerId("fromLocation");
    final MarkerId _markerTo = MarkerId("toLocation");
    _markers[_markerFrom] = GMapViewHelper.createMaker(
      markerIdVal: "fromLocation",
      icon: checkPlatform ? "assets/image/gps_point_24.png" : "assets/image/gps_point.png",
      lat: locationForm.latitude,
      lng: locationForm.longitude,
    );

    _markers[_markerTo] = GMapViewHelper.createMaker(
      markerIdVal: "toLocation",
      icon: checkPlatform ? "assets/image/ic_marker_32.png" : "assets/image/ic_marker_128.png",
      lat: locationTo.latitude,
      lng: locationTo.longitude,
    );
    _gMapViewHelper?.cameraMove(fromLocation: locationForm,toLocation: locationTo,mapController: _mapController);
  }

  _removeMarker() {
    _markers.clear();
  }


  _reviewTicket(String ticket) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ticket", ticket);
    if (_everyTenSecond != null)  _everyTenSecond.cancel();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RequestDetail()));
  }

  _processTicket(String ticket) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ticket", ticket);
    if (_everyTenSecond != null)  _everyTenSecond.cancel();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PickUp()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: _currentUser != null? new MenuScreens(activeScreenName: screenName, user: _currentUser): new MenuScreensDefault(activeScreenName: screenName),
        body: Container(
            color: whiteColor,
            child: Stack(
              children: <Widget>[
                _buildMapLayer(),
                Positioned(
                  bottom: isShowDefault == false ? 330 : 250,
                  right: 16,
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(100.0),),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.my_location,size: 20.0,color: blackColor,),
                      onPressed: (){
                        _initCurrentLocation();
                      },
                    ),
                  )
                ),
                /*Positioned(
                  top: 50,
                  right: 10,
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(100.0),),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.layers,size: 20.0,color: blackColor,),
                      onPressed: (){
                        _showBottomSheet();
                      },
                    ),
                  )
                ),*/
                Positioned(
                    top: 50,
                    left: 10,
                    child: Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(100.0),),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.menu,size: 20.0,color: blackColor,),
                        onPressed: (){
                          _scaffoldKey.currentState.openDrawer();
                        },
                      ),
                    )
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: isShowDefault == false ?
                  Container(
                    height: 330,
                    child: TinderSwapCard(
                        orientation: AmassOrientation.TOP,
                        totalNum: listRequest.length,
                        stackNum: 3,
                        maxWidth: MediaQuery.of(context).size.width,
                        minWidth: MediaQuery.of(context).size.width * 0.9,
                        maxHeight: MediaQuery.of(context).size.width * 0.9,
                        minHeight: MediaQuery.of(context).size.width * 0.85,
                        cardBuilder: (context, index) => ItemRequest(
                          avatar: Config.userImageUrl + listRequest[index]['avatar'],
                          userName: listRequest[index]['name'],
                          date: listRequest[index]['date'],
                          price: "\$" + listRequest[index]['price'],
                          distance: listRequest[index]['distance'] + " km",
                          addFrom: listRequest[index]['pickup'],
                          addTo: listRequest[index]['dropoff'],
                          locationForm: LatLng(double.parse(listRequest[index]['plat']), double.parse(listRequest[index]['plng'])),
                          locationTo: LatLng(double.parse(listRequest[index]['dlat']), double.parse(listRequest[index]['dlng'])),
                          status: listRequest[index]['status'].toString(),
                          onTap: (){
                            if (listRequest[index]['status'].toString() == "0") {
                              _reviewTicket(listRequest[index]['id']);
                            } else {
                              _processTicket(listRequest[index]['id']);
                            }
                          },
                        ),
                        swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
                          /// Get swiping card's position
//                          print(details);
                        },
                        swipeCompleteCallback: (CardSwipeOrientation orientation, int index) {
                          /// Get orientation & index of swiped card!
                          print('index $index');
                          print('aaa ${listRequest.length}');
                          print('ticket id ' + listRequest[index]['id']);
                          setState(() {
                            if(index == listRequest.length-1){
                              setState(() {
                                _currentTicketId = listRequest[index]['id'];
                                isShowDefault = true;
                                _removeMarker();
                              });
                            } else {
                              addMarker(LatLng(double.parse(listRequest[index+1]['plat']), double.parse(listRequest[index+1]['plng'])), LatLng(double.parse(listRequest[index+1]['dlat']), double.parse(listRequest[index+1]['dlng'])));
                            }
                          });
                        }
                      ),
                  ): MyActivity(
                    userImage: _currentUser == null ? '' : Config.userImageUrl + _currentUser.userid,
                    userName: _currentUser == null ? '' : _currentUser.fullname,
                    level: _currentUser == null ? 0 : double.parse(_currentUser.rating),
                    totalEarned:  _currentUser == null ? '\$0.00' : '\$' + _currentUser.earn,
                    hoursOnline:  _currentUser == null ? 0: double.parse(_currentUser.hours),
                    totalDistance: _currentUser == null ? '' : _currentUser.distance,
                    totalJob: _currentUser == null ? 0: int.parse(_currentUser.tickets),
                  ),
                )
              ],
            ),
        ),
    );
  }

  Widget _buildMapLayer(){
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: _gMapViewHelper.buildMapView(
          context: context,
          onMapCreated: _onMapCreated,
          currentLocation: LatLng(
              currentLocation != null ? currentLocation?.latitude : _lastKnownPosition?.latitude ?? 10.536421,
              currentLocation != null ? currentLocation?.longitude : _lastKnownPosition?.longitude ?? -61.311951),
          markers: _markers,
          polyLines: _polyLines,
          onTap: (_){
          }
      ),
    );
  }
}
