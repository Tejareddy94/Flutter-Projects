import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomAlertRoundedBox extends StatefulWidget {
  final String message;

  const CustomAlertRoundedBox({Key key, this.message}) : super(key: key);
  @override
  State<StatefulWidget> createState() => CustomAlertRoundedBoxState();
}

class CustomAlertRoundedBoxState extends State<CustomAlertRoundedBox>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "${widget.message}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Spacer(),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        color: Theme.of(context).buttonColor,
                        child: new Text(
                          "OK",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Spacer(),
                    ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DeletePostAlertBox {
  Function(int, int) deletePost;
  int index;
  int id;
  DeletePostAlertBox(this.deletePost, this.index, this.id);

  ///Alert Box for Delete Post
  showAlertDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: Colors.white70),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = RaisedButton(
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: Text(
          "Delete",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () {
          deletePost(id, index);
          // deletePost(widget.post.id, widget.index);
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)));

    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).backgroundColor,
      title: Text(
        "Delete Post",
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Are you sure you want to delete this Post?"),
          SizedBox(
            width: 10,
          ),
          Text(
            "This action cannot be reverted",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class GlobalSnackBar {
  final String message;
  final Color color;
  const GlobalSnackBar({
    @required this.color,
    @required this.message,
  });

  static show(
    BuildContext context,
    String message,
    Color color,
  ) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        elevation: 0.0,
        content: Text(message),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            // borderRadius: BorderRadius.only(
            //     topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0),),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        action: SnackBarAction(
          textColor: Color(0xFFFAF2FB),
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}

void customRoundedSnackBar(
    {@required sacffoldState,
    @required String message,
    Color color = Colors.grey,
    Duration duration = const Duration(seconds: 3)}) {
  sacffoldState.showSnackBar(SnackBar(
    backgroundColor: color != null ? color : Colors.green,
    elevation: 0.0,
    content: Text("$message"),
    duration: duration,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
        // borderRadius: BorderRadius.only(
        //     topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0),),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    action: SnackBarAction(
      textColor: Color(0xFFFAF2FB),
      label: 'OK',
      onPressed: () {},
    ),
  ));
}
