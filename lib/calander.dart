import 'package:attendance/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'colorcheme.dart';
import 'welcome.dart';
import 'main.dart';
import 'loginpage.dart';

class CalendarPage extends StatefulWidget {
  static String id = 'loggedin';

  @override
  calendarPage createState() => calendarPage();
}

class calendarPage extends State<CalendarPage> {
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('@mipmap/ic_launcher');
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;
  User loggedInUser;
  final _auth = FirebaseAuth.instance;
  CalendarController _calendarController;
  CollectionReference users = FirebaseFirestore.instance.collection('Events');
  String comittee, eventname, stime, etime, date;
  bool sent = false;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void _clearAllItems() {
    for (var i = 0; i <= _items.length - 1; i++) {
      _key.currentState.removeItem(0,
          (BuildContext context, Animation<double> animation) {
        return Container();
      });
    }
    _items.clear();
  }

  Future<Null> checkforchanges() async {
    print(_items.length);
    Firestore.instance.runTransaction((transaction) async {
      users.snapshots().listen((event) {
        if (event.docChanges.isNotEmpty) {
          _items.clear();
          users
              .where('sentToCoordinator', isEqualTo: false)
              .get()
              .then((QuerySnapshot querySnapshot) => {
                    querySnapshot.docs.forEach((doc) {
                      String comName = doc.data()['comName'];
                      String event = doc.data()['eventName'];
                      String stime = doc.data()['startTime'];
                      String etime = doc.data()['endTime'];
                      _addItem(comName, event, stime, etime);
                    })
                  });
        }
      });
    });
  }

  void checkevent() async {
    users
        .where('sentToCoordinator', isEqualTo: false)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                String comName = doc.data()['comName'];
                String event = doc.data()['eventName'];
                String stime = doc.data()['startTime'];
                String etime = doc.data()['endTime'];
                _addItem(comName, event, stime, etime);
              })
            });
  }

  @override
  void initState() {
    super.initState();
    initializing();
    _calendarController = CalendarController();
    getCurrentUser();
    checkforchanges();
  }

  void initializing() async {
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void _showNotifications() async {
    await notification();
  }

  void _showNotificationsAfterSecond() async {
    await notificationAfterSec();
  }

  Future<void> notification() async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'Channel ID', 'Channel title', 'channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, 'Reminder',
        'please send the list to the teacher incharge', notificationDetails);
  }

  void _removeItem(int i) {
    Container removeditem = _items.removeAt(i);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return eventBox(stime, etime, comittee, eventname, i, sent);
    };
    _key.currentState.removeItem(i, builder);
  }

  void _addItem(String cname, ename, stname, etname) {
    int i = _items.length > 0 ? _items.length : 0;
    _items.insert(i, eventBox(stname, etname, cname, ename, i, sent));
    _key.currentState.insertItem(i);
  }

  Future<void> notificationAfterSec() async {
    var timeDelayed = DateTime.now().add(Duration(seconds: 5));
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'second channel ID', 'second Channel title', 'second channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.schedule(
        1,
        'Reminder',
        'please send the list to the teacher incharge',
        timeDelayed,
        notificationDetails);
  }

  Future onSelectNotification(String payLoad) {
    if (payLoad != null) {
      print(payLoad);
    }

    // we can set navigator to navigate another screen
  }

  Future logOut(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('email');
    Fluttertoast.showToast(
        msg: "Logout Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  List event1 = [];
  List event2 = [];

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              print("");
            },
            child: Text("Okay")),
      ],
    );
  }

  final GlobalKey<AnimatedListState> _key = GlobalKey();
  User user = FirebaseAuth.instance.currentUser;
  List<Container> _items = [];

  @override
  void dispose() {
    _calendarController = CalendarController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          drawer: Drawer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    child: DrawerHeader(
                      margin: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: purple,
                      ),
                      child: Center(
                        child: Text('Event\nManager',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 30.0)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    child: ListView(
                      children: [
                        user == null
                            ? ListTile(
                                leading: Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                                title: Text(
                                  'Add Event',
                                  style: TextStyle(color: Colors.black),
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                ),
                                onTap: () {
                                  Fluttertoast.showToast(
                                      msg: "Login to use",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      fontSize: 16.0);
                                },
                              )
                            : ListTile(
                                leading: Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                                title: Text(
                                  'Add Event',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                ),
                                onTap: () {
                                  openAlertBox();
                                },
                              ),
                        Divider(
                          height: 4,
                          thickness: 0.5,
                          color: Colors.black,
                        ),
                        user == null
                            ? Container(
                                child: ListTile(
                                  leading: Icon(
                                    Icons.login,
                                    color: Colors.black,
                                  ),
                                  title: Text(
                                    'Log In',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  trailing: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.black,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()));
                                  },
                                ),
                              )
                            : Container(
                                child: ListTile(
                                  leading: Icon(
                                    Icons.logout,
                                    color: Colors.black,
                                  ),
                                  title: Text(
                                    'Log out',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.black,
                                  ),
                                  onTap: () {
                                    Fluttertoast.showToast(
                                        msg: "Logout Successful",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        fontSize: 16.0);
                                    _auth.signOut();
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MyHomePage()));
                                  },
                                ),
                              ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.black,
                        ),
                      ],
                      padding: EdgeInsets.only(top: 0),
                    ),
                  ),
                )
              ],
            ),
          ),
          backgroundColor: purple,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Event Management',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              TableCalendar(
                calendarController: _calendarController,
                initialCalendarFormat: CalendarFormat.week,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                formatAnimation: FormatAnimation.slide,
                onDaySelected: (date, event1, event2) {
                  print(date.toIso8601String());
                },
                headerStyle: HeaderStyle(
                  centerHeaderTitle: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
                  leftChevronIcon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 15,
                  ),
                  rightChevronIcon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 15,
                  ),
                  leftChevronMargin: EdgeInsets.only(left: 70),
                  rightChevronMargin: EdgeInsets.only(right: 70),
                ),
                calendarStyle: CalendarStyle(
                    weekendStyle: TextStyle(color: Colors.white),
                    weekdayStyle: TextStyle(color: Colors.white)),
                daysOfWeekStyle: DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.white),
                    weekdayStyle: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40)),
                      color: Colors.white),
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.87,
                      child: StreamBuilder<Object>(
                          stream: null,
                          builder: (context, snapshot) {
                            return AnimatedList(
                                key: _key,
                                initialItemCount: _items.length,
                                itemBuilder: (context, index, animation) {
                                  if (index < _items.length) {
                                    return _items[index];
                                  }
                                  ;
                                });
                          })),
                ),
              ),
            ],
          ),
          floatingActionButton: user == null
              ? FloatingActionButton(
                  child: Icon(Icons.add),
                  backgroundColor: purple,
                  onPressed: () {
                    Fluttertoast.showToast(
                        msg: "Login to use",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        fontSize: 16.0);
                  },
                )
              : FloatingActionButton(
                  child: Icon(Icons.add),
                  backgroundColor: purple,
                  onPressed: () => openAlertBox(),
                ),
        ),
      ),
    );
  }

  _showAddDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text('You will recieve a reminder in 1 hour'),
              actions: <Widget>[
                FlatButton(
                  child: Text("Okay"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  Container eventBox(String startTime, String endTime, String comName,
      String eventName, int index, bool sent) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 20, 20, 0),
            width: MediaQuery.of(context).size.width * 0.15,
            child: Text(
              startTime,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: MediaQuery.of(context).size.width * 0.028,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                  color: Color(0xffdfdeff),
                ),
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(20),
                // color: Color(0xffdfdeff),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              // child: Image.asset(
                              //   'assets/images/pp.jpg',
                              //   width: 60,
                              //   height: 60,
                              //   fit: BoxFit.fill,
                              // ),
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.white,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comName,
                              style: TextStyle(
                                  color: purple, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              eventName,
                              style: TextStyle(
                                  color: purple, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: purple,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '$startTime  - $endTime ',
                                  style: TextStyle(
                                      color: purple,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 0.5,
                      color: Colors.teal[300],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    user == null
                        ? Row()
                        : Row(
                            children: [
                              Column(
                                children: [
                                  //!_canShowButton? const SizedBox.shrink():
                                  Text(
                                    'Sent the list to\nthe coordinator?',
                                    style: TextStyle(
                                        color: purple,
                                        fontWeight: FontWeight.w700),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                children: [
                                  Container(
                                    child:
                                        //!_canShowButton? const SizedBox.shrink():

                                        IconButton(
                                      icon: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      onPressed: () {
                                        sent = true;
                                        users.doc(eventName + comName).update(
                                            {'sentToCoordinator': sent});
                                        _removeItem(index);
                                      },
                                    ),
                                    width: 55,
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    child:
                                        //!_canShowButton? const SizedBox.shrink():
                                        IconButton(
                                      icon: Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _showAddDialog();
                                        _showNotificationsAfterSecond();
                                      },
                                    ),
                                    width: 55,
                                  ),
                                ],
                              )
                            ],
                          )
                  ],
                )),
          )
        ],
      ),
    );
  }

  openAlertBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: EdgeInsets.only(top: 10.0),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[],
                    ),
                    _builddropdown(),
                    _buildEventRow(),
                    //Form(child: _buildDateRow()),
                    _buildTimeRow(),
                    _buildSubmitButton(),
                  ],
                ),
              ));
        });
  }

  Widget _builddropdown() {
    return DropdownButton<String>(
      value: comittee,
      icon: Icon(Icons.keyboard_arrow_down),
      iconSize: 24,
      elevation: 10,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        width: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          comittee = newValue;
        });
      },
      items: <String>[
        'Student Council',
        'Developer Students Club',
        'National Service Scheme'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1 * (MediaQuery.of(context).size.height / 20),
          width: 5 * (MediaQuery.of(context).size.width / 10),
          margin: EdgeInsets.only(bottom: 10, top: 10),
          child: RaisedButton(
            elevation: 4.0,
            color: logincolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () {
              //_addItem();
              users
                  .doc(eventname + comittee)
                  .get()
                  .then((DocumentSnapshot documentSnapshot) {
                if (documentSnapshot.exists) {
                  Fluttertoast.showToast(
                      msg: "Event Already Exists",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      fontSize: 16.0);
                } else {
                  userSetup(stime, etime, comittee, eventname, date, sent);
                  Navigator.pop(context);
                }
              });
            },
            child: Text(
              "Submit",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: MediaQuery.of(context).size.height / 40,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTimeRow() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 100,
                child: TextFormField(
                  keyboardType: TextInputType.datetime,
                  onChanged: (value) {
                    setState(() {
                      stime = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Start Time',
                    hintText: 'eg: 11:00',
                    labelStyle: TextStyle(color: purple),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Text(
                'To',
                style: TextStyle(color: purple, fontSize: 20),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 100,
                child: TextFormField(
                  keyboardType: TextInputType.datetime,
                  onChanged: (value) {
                    setState(() {
                      etime = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'End Time',
                    hintText: 'eg: 13:00',
                    labelStyle: TextStyle(color: purple),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventRow() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: TextFormField(
        keyboardType: TextInputType.name,
        onChanged: (value) {
          setState(() {
            eventname = value;
          });
        },
        decoration: InputDecoration(
          labelText: 'Event Name',
          labelStyle: TextStyle(color: purple),
        ),
      ),
    );
  }

  Widget _buildDateRow() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: TextFormField(
        keyboardType: TextInputType.datetime,
        onChanged: (value) {
          setState(() {
            date = value;
          });
        },
        decoration: InputDecoration(
          labelText: 'Date',
          labelStyle: TextStyle(color: purple),
        ),
      ),
    );
  }
}
