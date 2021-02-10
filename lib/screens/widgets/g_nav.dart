import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:scrolly/models/user.dart';
import 'package:scrolly/screens/chats/chat_list_screen.dart';
import 'package:scrolly/screens/classes/user_class/user_class_home.dart';
import 'package:scrolly/screens/home_screen.dart';
import 'package:scrolly/screens/settings/settings.dart';

class GNavigator extends StatefulWidget {
  final UserModel meUser;

  GNavigator({Key key, this.meUser}) : super(key: key);
  @override
  _GNavigatorState createState() => _GNavigatorState();
}

class _GNavigatorState extends State<GNavigator> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      HomeScreen(
        meUser: widget.meUser,
      ),
      UserClassHome(),
      ChatListScreen(),
      SettingsPage(),
    ];
    final theme = Theme.of(context);
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: theme.dialogBackgroundColor,
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
            ]),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
                gap: 18,
                activeColor: Colors.white,
                iconSize: 30,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                duration: Duration(milliseconds: 400),
                tabBackgroundColor: theme.primaryColor,
                curve: Curves.ease,
                tabs: [
                  GButton(
                    leading: Image.asset(
                      'assets/icons/news.png',
                      height: 25,
                      width: 25,
                    ),
                    text: 'Home',
                  ),
                  GButton(
                    leading: Image.asset(
                      'assets/icons/google-classroom.png',
                      height: 25,
                      width: 25,
                    ),
                    text: 'Classes',
                  ),
                  GButton(
                    leading: Image.asset(
                      'assets/icons/chat.png',
                      height: 25,
                      width: 25,
                    ),
                    text: 'Chats',
                  ),
                  GButton(
                    leading: Image.asset(
                      'assets/icons/friends.png',
                      height: 25,
                      width: 25,
                    ),
                    text: 'Profile',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }),
          ),
        ),
      ),
    );
  }
}
