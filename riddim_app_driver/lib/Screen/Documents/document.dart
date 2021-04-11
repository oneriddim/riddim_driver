import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:riddim_app_driver/Components/inputDropdown.dart';
import 'package:riddim_app_driver/Components/validations.dart';
import 'package:riddim_app_driver/Repository/konnectRepository.dart';
import 'package:riddim_app_driver/Screen/MyProfile/myProfile.dart';
import 'package:riddim_app_driver/config.dart';
import 'package:riddim_app_driver/data/Model/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/style.dart';
import 'package:cached_network_image/cached_network_image.dart';

const double _kPickerSheetHeight = 216.0;

class Document extends StatefulWidget {
  @override
  _DocumentState createState() => _DocumentState();
}

class _DocumentState extends State<Document> {
  final userRepository = KonnectRepository();
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool autovalidate = false;
  Validations validations = new Validations();
  User _currentUser;
  String _documentId;
  Map _documentInfo;


  DateTime issued = DateTime.now();
  DateTime expiry = DateTime.now();
  var _image;
  String number;
  String dclass;
  String make;
  String model;
  String year;
  String color;
  String provider;

  @override
  void initState() {
    super.initState();
    _getDocumentInfo();
  }

  Future<void> _getDocumentInfo() async {
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
    _documentId = prefs.get("document");
    var user = await userRepository.getUser(prefs.getString("usertoken"));

    final info = await userRepository.getDocument(document: _documentId, token: user.userid);

    setState(() {
      _currentUser = user;
      if (info.length > 0) {
        _documentInfo = info;
        if (_documentInfo["issued"] != null && _documentInfo["issued"] != "") {
          issued = DateTime.parse(_documentInfo["issued"] + " 00:00:00");
        }
        if (_documentInfo["expiry"] != null && _documentInfo["expiry"] != "") {
          expiry = DateTime.parse(_documentInfo["expiry"] + " 00:00:00");
        }

        number = _documentInfo["num"];
        dclass = _documentInfo["class"];
        make = _documentInfo["make"];
        model = _documentInfo["model"];
        year = _documentInfo["year"];
        color = _documentInfo["color"];
        provider = _documentInfo["provider"];
      }
    });
  }


  Future getImageLibrary() async {
    var gallery = await ImagePicker.pickImage(source: ImageSource.gallery,maxWidth: 700);
    setState(() {
      _image = gallery;
      print(_image);
    });
  }

  Future cameraImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 700);
    setState(() {
      _image = image;
      print(_image);
    });
  }


  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  void showDemoActionSheet({BuildContext context, Widget child}) {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((String value) {
      if (value != null) {
        setState(() {  });
      }
    });
  }

  selectCamera () {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
          title: const Text('Select Camera'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text('Camera'),
              onPressed: () {
                Navigator.pop(context, 'Camera');
                cameraImage();
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Photo Library'),
              onPressed: () {
                Navigator.pop(context, 'Photo Library');
                getImageLibrary();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
          )
      ),
    );
  }

  _submit() async {
    final FormState form = formKey.currentState;
    form.save();

    Fluttertoast.showToast(
        msg: "Please wait..",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );

    final success = await userRepository.saveDocument(
        token: _currentUser.userid,
        id: _documentId,
        number: number,
        issue: DateFormat("yyyy-MM-dd").format(issued),
        expiry: DateFormat("yyyy-MM-dd").format(expiry),
        dclass: dclass,
        make: make,
        model: model,
        year: year,
        color: color,
        provider: provider,
        image: _image
    );

    if (success) {
      DefaultCacheManager manager = new DefaultCacheManager();
      manager.emptyCache();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("document");

      Fluttertoast.showToast(
          msg: "Saved",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );

      Navigator.of(context).pushReplacementNamed('/documents');
      Navigator.popAndPushNamed(context, '/documents');
    }
  }


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _documentInfo == null ? "" :  _documentInfo["document"],
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        elevation: 2.0,
        iconTheme: IconThemeData(color: blackColor),
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
        child: Container(
          color: backgroundColor,
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Center(
                child: Stack(
                  children: <Widget>[
                    Material(
                      elevation: 10.0,
                      borderRadius: BorderRadius.circular(15.0),
                      child: new ClipRRect(
                          borderRadius: new BorderRadius.circular(15.0),
                          child:_image == null
                              ? new GestureDetector(
                              onTap: (){selectCamera();},
                              child: new Container(
                                  height: 150.0,
                                  width: 150.0,
                                  color: primaryColor,
                                  child: _documentInfo == null ?  new Image.network(Config.documentImageUrl + "-1" ,fit: BoxFit.cover, height: 150.0,width: 150.0,) :  new Image.network(Config.documentImageUrl + _documentInfo["id"],fit: BoxFit.cover, height: 150.0,width: 150.0,)
                              )
                          ): new GestureDetector(
                              onTap: () {selectCamera();},
                              child: new Container(
                                height: 150.0,
                                width: 150.0,
                                child: Image.file(_image,fit: BoxFit.cover, height: 150.0,width: 150.0,),
                              )
                          )
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              /*Container(
                color: whiteColor,
                child: LineChartWallet(),
              ),
              SizedBox(height: 20),*/
              Form(
                key: formKey,
                child: _documentInfo == null ? new Container() :
                _documentInfo["type"] == "1" ? nationalId() :
                _documentInfo["type"] == "2" ? driverLicense() :
                _documentInfo["type"] == "3" ? vehicleRegistration() :
                _documentInfo["type"] == "5" ? insurance() : document() ,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget nationalId() {
    return Column(
      children: <Widget>[
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Identification #",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  style: textStyle,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      fillColor: whiteColor,
                      labelStyle: textStyle,
                      hintStyle: TextStyle(color: Colors.white),
                      counterStyle: textStyle,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white))
                  ),
                  controller: new TextEditingController.fromValue(
                    new TextEditingValue(
                      text: number,
                      selection: new TextSelection.collapsed(
                          offset: 11),
                    ),
                  ),
                  onChanged: (String _num) {
                    number = _num;
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Issued",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child:  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildBottomPicker(
                            CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: issued,
                              onDateTimeChanged: (DateTime newDateTime) {
                                setState(() {
                                  issued = newDateTime;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: new InputDropdown(
                      valueText: DateFormat.yMMMMd().format(issued),
                      valueStyle: TextStyle(color: blackColor),
                    )
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Expiry",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child:  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildBottomPicker(
                            CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: expiry,
                              onDateTimeChanged: (DateTime newDateTime) {
                                setState(() {
                                  expiry = newDateTime;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: new InputDropdown(
                      valueText: DateFormat.yMMMMd().format(expiry),
                      valueStyle: TextStyle(color: blackColor),
                    )
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget driverLicense() {
    return Column(
      children: <Widget>[
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Permit #",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  style: textStyle,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      fillColor: whiteColor,
                      labelStyle: textStyle,
                      hintStyle: TextStyle(color: Colors.white),
                      counterStyle: textStyle,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white))
                  ),
                  controller: new TextEditingController.fromValue(
                    new TextEditingValue(
                      text: number,
                      selection: new TextSelection.collapsed(
                          offset: 11),
                    ),
                  ),
                  onChanged: (String _num) {
                    number = _num;
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Permit Class",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  style: textStyle,
                  decoration: InputDecoration(
                      fillColor: whiteColor,
                      labelStyle: textStyle,
                      hintStyle:
                      TextStyle(color: Colors.white),
                      counterStyle: textStyle,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white))
                  ),
                  controller: new TextEditingController.fromValue(
                    new TextEditingValue(
                      text: dclass,
                      selection: new TextSelection.collapsed(
                          offset: 11),
                    ),
                  ),
                  onChanged: (String _class) {
                    dclass = _class;
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Issued",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child:  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildBottomPicker(
                            CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: issued,
                              onDateTimeChanged: (DateTime newDateTime) {
                                setState(() {
                                  issued = newDateTime;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: new InputDropdown(
                      valueText: DateFormat.yMMMMd().format(issued),
                      valueStyle: TextStyle(color: blackColor),
                    )
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Expiry",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child:  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildBottomPicker(
                            CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: expiry,
                              onDateTimeChanged: (DateTime newDateTime) {
                                setState(() {
                                  expiry = newDateTime;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: new InputDropdown(
                      valueText: DateFormat.yMMMMd().format(expiry),
                      valueStyle: TextStyle(color: blackColor),
                    )
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget vehicleRegistration() {
    return Column(
      children: <Widget>[
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Vehicle Reg #",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  style: textStyle,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      fillColor: whiteColor,
                      labelStyle: textStyle,
                      hintStyle: TextStyle(color: Colors.white),
                      counterStyle: textStyle,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white))
                  ),
                  controller: new TextEditingController.fromValue(
                    new TextEditingValue(
                      text: _documentInfo == null ? "" :  _documentInfo["num"],
                      selection: new TextSelection.collapsed(
                          offset: 11),
                    ),
                  ),
                  onChanged: (String _num) {
                    number = _num;
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Make",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  style: textStyle,
                  decoration: InputDecoration(
                      fillColor: whiteColor,
                      labelStyle: textStyle,
                      hintStyle:
                      TextStyle(color: Colors.white),
                      counterStyle: textStyle,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white))
                  ),
                  controller: new TextEditingController.fromValue(
                    new TextEditingValue(
                      text: _documentInfo == null ? "" :  _documentInfo["make"],
                      selection: new TextSelection.collapsed(
                          offset: 11),
                    ),
                  ),
                  onChanged: (String _make) {
                    make = _make;
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Model",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  style: textStyle,
                  decoration: InputDecoration(
                      fillColor: whiteColor,
                      labelStyle: textStyle,
                      hintStyle:
                      TextStyle(color: Colors.white),
                      counterStyle: textStyle,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white))
                  ),
                  controller: new TextEditingController.fromValue(
                    new TextEditingValue(
                      text: model,
                      selection: new TextSelection.collapsed(
                          offset: 11),
                    ),
                  ),
                  onChanged: (String _model) {
                    model = _model;
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Year",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  style: textStyle,
                  decoration: InputDecoration(
                      fillColor: whiteColor,
                      labelStyle: textStyle,
                      hintStyle:
                      TextStyle(color: Colors.white),
                      counterStyle: textStyle,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white))
                  ),
                  controller: new TextEditingController.fromValue(
                    new TextEditingValue(
                      text: year,
                      selection: new TextSelection.collapsed(
                          offset: 11),
                    ),
                  ),
                  onChanged: (String _year) {
                    year = _year;
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Color",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  style: textStyle,
                  decoration: InputDecoration(
                      fillColor: whiteColor,
                      labelStyle: textStyle,
                      hintStyle:
                      TextStyle(color: Colors.white),
                      counterStyle: textStyle,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white))
                  ),
                  controller: new TextEditingController.fromValue(
                    new TextEditingValue(
                      text: color,
                      selection: new TextSelection.collapsed(
                          offset: 11),
                    ),
                  ),
                  onChanged: (String _color) {
                    color = _color;
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget insurance() {
    return Column(
      children: <Widget>[
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Policy #",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  style: textStyle,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      fillColor: whiteColor,
                      labelStyle: textStyle,
                      hintStyle: TextStyle(color: Colors.white),
                      counterStyle: textStyle,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white))
                  ),
                  controller: new TextEditingController.fromValue(
                    new TextEditingValue(
                      text: number,
                      selection: new TextSelection.collapsed(
                          offset: 11),
                    ),
                  ),
                  onChanged: (String _num) {
                    number = _num;
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Provider",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  style: textStyle,
                  decoration: InputDecoration(
                      fillColor: whiteColor,
                      labelStyle: textStyle,
                      hintStyle:
                      TextStyle(color: Colors.white),
                      counterStyle: textStyle,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white))
                  ),
                  controller: new TextEditingController.fromValue(
                    new TextEditingValue(
                      text: provider,
                      selection: new TextSelection.collapsed(
                          offset: 11),
                    ),
                  ),
                  onChanged: (String _provider) {
                    provider = _provider;
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Issued",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child:  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildBottomPicker(
                            CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: issued,
                              onDateTimeChanged: (DateTime newDateTime) {
                                setState(() {
                                  issued = newDateTime;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: new InputDropdown(
                      valueText: DateFormat.yMMMMd().format(issued),
                      valueStyle: TextStyle(color: blackColor),
                    )
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Expiry",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child:  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildBottomPicker(
                            CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: expiry,
                              onDateTimeChanged: (DateTime newDateTime) {
                                setState(() {
                                  expiry = newDateTime;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: new InputDropdown(
                      valueText: DateFormat.yMMMMd().format(expiry),
                      valueStyle: TextStyle(color: blackColor),
                    )
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget document() {
    return Column(
      children: <Widget>[
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Issued",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child:  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildBottomPicker(
                            CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: issued,
                              onDateTimeChanged: (DateTime newDateTime) {
                                setState(() {
                                  issued = newDateTime;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: new InputDropdown(
                      valueText: DateFormat.yMMMMd().format(issued),
                      valueStyle: TextStyle(color: blackColor),
                    )
                ),
              )
            ],
          ),
        ),
        Container(
          color: whiteColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    "Expiry",
                    style: textStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child:  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildBottomPicker(
                            CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: expiry,
                              onDateTimeChanged: (DateTime newDateTime) {
                                setState(() {
                                  expiry = newDateTime;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: new InputDropdown(
                      valueText: DateFormat.yMMMMd().format(expiry),
                      valueStyle: TextStyle(color: blackColor),
                    )
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
