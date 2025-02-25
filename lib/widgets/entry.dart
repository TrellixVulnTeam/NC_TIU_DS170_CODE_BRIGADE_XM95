import 'package:fillme/views/home_page.dart';
import 'package:fillme/widgets/rewards.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import '../authentication/login_page.dart';
import '../authentication/auth.dart';
import '../qr_code_scan.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'google_map.dart';

// ignore: must_be_immutable
class EntryPage extends StatefulWidget {
  EntryPage({this.selectedIndex, this.auth, this.onSignOut});
  int selectedIndex;
  final BaseAuth auth;
  final VoidCallback onSignOut;

  @override
  _EntryPageState createState() => new _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  String email = "Fillme@gmail.com";
  String _linkMessage;

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    _createDynamicLink();
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignOut();
    } catch (e) {
      print(e);
    }
  }

  void _googlesignOut() async {
    try {
      await widget.auth.signOutGoogle();
      widget.onSignOut();
    } catch (e) {
      print(e);
    }
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        Navigator.pushNamed(context, deepLink.path);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      print("deeplink path=${deepLink.path}");
      Navigator.pushNamed(context, deepLink.path);
    }
  }

  Future<void> _createDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://fillme.page.link',
      link: Uri.parse('https://fillme.page.link/rootpage'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.tech_bin',
        minimumVersion: 0,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.example.techBin',
        minimumVersion: '1.0.1',
        appStoreId: '123456789',
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Fill Me',
        description: 'click here to install the app',
      ),
    );

    Uri url;

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    url = shortLink.shortUrl;

    setState(() {
      _linkMessage = url.toString();
    });
  }

  final _widgetOptions = [
    new HomePage(),
    new Rewards(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: new IconThemeData(color: Colors.blueGrey[900]),
        elevation: 0.0,
        title: Text('FILLME',
            style: TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.w900,
              fontSize: 25,
            )),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: IconButton(
                icon: Icon(
                  Icons.search,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoogleMaps(),
                    ),
                  );
                }),
          ),
        ],
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: () {
          SystemNavigator.pop();
          return Future.value(true);
        },
        child: Center(
          child: _widgetOptions.elementAt(widget.selectedIndex),
        ),
      ),
      drawer: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        child: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.

          child: Container(
            decoration: BoxDecoration(),
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.blueGrey[900]),
                  accountName: Text('Username',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          shadows: [
                            Shadow(
                                blurRadius: 10.0,
                                color: Colors.black38,
                                offset: Offset(2.0, 2.0))
                          ])),
                  accountEmail: Text('useremail@gmail.com',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      )),
                  currentAccountPicture: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/image/g.png"),
                  ),
                ),
                ListTile(
                  title: new Row(children: [
                    Icon(
                      Icons.notifications_none,
                      color: Colors.teal[400],
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                      child: Text(
                        'Notificatios',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ]),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                    title: new Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: Colors.teal[400],
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                          child: Text(
                            'Rewards',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                         widget.selectedIndex = 1;
                      });
                     
                    }
                    ),
                ListTile(
                    title: new Row(children: [
                      Icon(
                        Icons.person_outline,
                        color: Colors.teal[400],
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ]),
                    onTap: () {}),
                ListTile(
                    title: new Row(children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.teal[400],
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                        child: Text(
                          'Help & Feedback',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ]),
                    onTap: () {
                      launch("mailto:$email");
                    }),
                ListTile(
                    title: new Row(children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.teal[400],
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                        child: Text(
                          'About Us',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      )
                    ]),
                    onTap: () {
                      
                    }),
                ListTile(
                    title: new Row(children: [
                      Icon(
                        Icons.settings,
                        color: Colors.teal[400],
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ]),
                    onTap: () {}),
                ListTile(
                    title: new Row(children: [
                      Icon(
                        Icons.share,
                        color: Colors.teal[400],
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                        child: Text(
                          'Share app',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ]),
                    onTap: () {
                      final RenderBox box = context.findRenderObject();
                      Share.share(_linkMessage,
                          sharePositionOrigin:
                              box.localToGlobal(Offset.zero) & box.size);
                    }),
                ListTile(
                  title: new Row(children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.teal[400],
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                      child: Text(
                        'logOut',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ]),
                  onTap: () {
                    googleSignIn == true ? _googlesignOut() : _signOut();
                  },
                ),
                Container(
                  height: 150,
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(100, 50, 120, 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.teal[400],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/image/qr.png"),
                fit: BoxFit.fill,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.blueGrey,
                    offset: Offset(0.5, 3.0),
                    blurRadius: 10.0),
              ],
            ),
          ),
          backgroundColor: Colors.green,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanPage(),
              ),
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 5.0,
          currentIndex: widget.selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 15,
          selectedItemColor: Colors.tealAccent[700],
          unselectedItemColor: Colors.black26,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 30,
              ),
              title: Text(
                'Home',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              backgroundColor: Colors.amber[700],
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.attach_money,
                size: 30,
              ),
              title: Text(
                'Rewards',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              backgroundColor: Colors.amber[700],
            ),
          ],
          onTap: (index) {
            setState(() {
              widget.selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
