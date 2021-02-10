import 'package:auth_buttons/auth_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scrolly/resources/auth_methods.dart';
import 'package:scrolly/resources/authentication.dart';
import 'package:scrolly/screens/login/sign_up_page.dart';
import 'package:scrolly/screens/widgets/g_nav.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthMethods _authMethods = AuthMethods();
  bool isLoading = false;

  void doGoogleSignin() {
    setState(() {
      isLoading = true;
    });
    _authMethods.signIn().then((User user) {
      if (user != null) {
        authenticateUser(user);
      } else {
        print('There was an error with authenticating the user');
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('It seems something is wrong. Try again later.'),
            actions: [
              FlatButton(
                child: Text('Okay'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    });
  }

  void authenticateUser(User user) {
    setState(() {
      isLoading = true;
    });
    _authMethods.authenticateUser(user).then((isNewUser) {
      if (isNewUser) {
        _authMethods.addDataToDb(user).then((value) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpPage(),
            ),
          );
        });
        print('New user is logged in');
        setState(() {
          isLoading = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GNavigator(),
          ),
        );
      }
    });
    print('Old user is logged in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Center(
                  child: Shimmer.fromColors(
                    baseColor: Colors.red,
                    highlightColor: Colors.grey,
                    child: Text(
                      'SCROLLY',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(
                    bottom: 80,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GoogleAuthButton(
                        onPressed: () {
                          doGoogleSignin();
                        },
                        style: AuthButtonStyle.icon,
                      ),
                      AppleAuthButton(
                        onPressed: () {},
                        style: AuthButtonStyle.icon,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
