import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riddim_app_driver/Repository/konnectRepository.dart';
import 'package:riddim_app_driver/theme/style.dart';
import 'package:riddim_app_driver/Screen/Home/home.dart';
import 'package:riddim_app_driver/Components/validations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';

class SignupScreen2 extends StatefulWidget {
  @override
  _SignupScreen2State createState() => _SignupScreen2State();
}

class _SignupScreen2State extends State<SignupScreen2> {
  final userRepository = KonnectRepository();
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool autovalidate = false;
  Validations validations = new Validations();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    _registerUser() async {
      final FormState form = formKey.currentState;
      if (!form.validate()) {
        autovalidate = true; // Start validating on every change.
      } else {
        form.save();

        //code
        Fluttertoast.showToast(
            msg: "Please wait, registering...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.orangeAccent,
            textColor: Colors.white,
            fontSize: 16.0
        );

        try {
          final token = await userRepository.signup(
            name: _nameController.text,
            username: _usernameController.text,
            password: _passwordController.text,
          );
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('usertoken', token);

          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => HomeScreen()));

        } catch (error) {
          Fluttertoast.showToast(
              msg: error.toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }

      }
    }

    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: ButtonTheme(
        minWidth: screenSize.width,
        height: 45.0,
        child: RaisedButton(
          elevation: 0.0,
          color: blue2,
          child: Text("Already have an account? Login",style: headingWhite18,
          ),
          onPressed: (){
            Navigator.pushNamed(context, '/login');
          },
        ),
      ),
      body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(children: <Widget>[
                    Container(
                      height: 400.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(Config.registerBgUrl + "1"),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                    new Padding(
                        padding: EdgeInsets.fromLTRB(18.0, 100.0, 18.0, 0.0),
                        child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            child: new Column(
                              children: <Widget>[
                                new Container(
                                  //padding: EdgeInsets.only(top: 100.0),
                                    child: new Material(
                                      borderRadius: BorderRadius.circular(7.0),
                                      elevation: 5.0,
                                      child: new Container(
                                        width: MediaQuery.of(context).size.width - 20.0,
                                        height: MediaQuery.of(context).size.height *0.55,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20.0)),
                                        child: new Form(
                                            key: formKey,
                                            child: new Container(
                                              padding: EdgeInsets.all(18.0),
                                              child: new Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text('Sign up', style: heading35Black,),
                                                  new Column (
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      TextFormField(
                                                          keyboardType: TextInputType.text,
                                                          controller: _nameController,
                                                          validator: validations.validateName,
                                                          decoration: InputDecoration(
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(10.0),
                                                            ),
                                                            prefixIcon: Icon(Icons.person,
                                                                color: Color(getColorHexFromStr('#FEDF62')), size: 20.0),
                                                            contentPadding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                            hintText: 'Name',
                                                            hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand'),

                                                          )
                                                      )
                                                    ],
                                                  ),
                                                  new Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      TextFormField(
                                                          keyboardType: TextInputType.phone,
                                                          controller: _usernameController,
                                                          validator: validations.validateMobile,
                                                          decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                              ),
                                                              prefixIcon: Icon(Icons.phone,
                                                                  color: Color(getColorHexFromStr('#FEDF62')), size: 20.0),
                                                              contentPadding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                              hintText: 'Phone',
                                                              hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand')
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  new Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      TextFormField(
                                                          keyboardType: TextInputType.visiblePassword,
                                                          controller: _passwordController,
                                                          validator: validations.validatePassword,
                                                          obscureText: true,
                                                          decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(10.0),
                                                              ),
                                                              prefixIcon: Icon(Icons.lock,
                                                                  color: Color(getColorHexFromStr('#FEDF62')), size: 20.0),
                                                              contentPadding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                              hintText: 'Password',
                                                              hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Quicksand')
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  /*new Container(
                                                    padding: EdgeInsets.only(top: 20.0,bottom: 20.0),
                                                      child: new Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: <Widget>[
                                                          InkWell(
                                                            child: new Text("Forgot Password ?",style: textStyleActive,),
                                                          ),
                                                        ],
                                                      )

                                                  ),*/
                                                  new ButtonTheme(
                                                    height: 50.0,
                                                    minWidth: MediaQuery.of(context).size.width,
                                                    child: RaisedButton.icon(
                                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                      elevation: 0.0,
                                                      color: primaryColor,
                                                      icon: new Text(''),
                                                      label: new Text('SIGN UP', style: headingWhite,),
                                                      onPressed: (){
                                                        _registerUser();
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                        ),
                                      ),
                                    )
                                ),
                                /*new Container(
                                    padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        new Text("Already have an account? ",style: textGrey,),
                                        new InkWell(
                                          onTap: () => Navigator.pushNamed(context, '/login'),
                                          child: new Text("Login",style: textStyleActive,),
                                        ),
                                      ],
                                    )
                                ),*/
                              ],
                            )
                        )
                    ),
                  ]
                  )
                ]
            ),
          )

      ),
    );
  }
}