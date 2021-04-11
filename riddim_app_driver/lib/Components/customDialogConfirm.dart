import 'package:flutter/material.dart';
import 'package:riddim_app_driver/components/CustomShowDialog.dart';
import 'package:riddim_app_driver/theme/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDialogConfirm extends StatelessWidget {
  final String title, body, buttonTitle;
  final VoidCallback onPressed;

  CustomDialogConfirm({
    this.title,
    this.body,
    this.buttonTitle,
    this.onPressed,
});

  @override
  Widget build(BuildContext context) {
    return new CustomAlertDialog(
      content: new Container(
        width: 280.0,
        height: 240.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(new Radius.circular(10.0)),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // dialog top
            new Container(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new Expanded(
                      flex: 4,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            padding: new EdgeInsets.fromLTRB(16.0,16.0,0.0,0.0),
                            child: new Icon(FontAwesomeIcons.cogs,color: greyColor2,),
                          ),
                        ],
                      )
                  ),
                  new Expanded(
                      flex: 1,
                      child: new GestureDetector(
                        onTap:() => Navigator.pop(context),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              padding: new EdgeInsets.fromLTRB(16.0,10.0,0.0,0.0),
                              child: new Icon(Icons.close,color: greyColor2,),
                            ),
                          ],
                        ),
                      )
                  ),
                ],
              ),
            ),
            new Expanded(
              flex: 3,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 8.0, 0.0),
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(title != null ? title : '',
                            style: headingBlack,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                  ),
                  new Container(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 8.0, 0.0),
                    child: new Text(body != null ? body : '',
                      style: heading18Black,
                      //textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: new GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: new Container(
                      width: 110.0,
                      height: 50.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: greyColor,
                          borderRadius:
                          new BorderRadius.only(bottomLeft: new Radius.circular(10.0))
                      ),
                      child: new Center(
                        child: new Text(
                          "Cancle",
                          style: headingBlack,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: new GestureDetector(
                    onTap: onPressed,
                    child: new Container(
                      width: 110.0,
                      height: 50.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: primaryColor,
                          borderRadius:
                          new BorderRadius.only(bottomRight: new Radius.circular(10.0))
                      ),
                      child: new Center(
                        child: new Text(
                          buttonTitle,
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontFamily: "OpenSans",
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
