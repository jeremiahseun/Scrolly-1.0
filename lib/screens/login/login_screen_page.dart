import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrolly/utils/universal_variables.dart';
import 'package:scrolly/screens/login/sign_up_page.dart';
import 'package:scrolly/resources/auth_methods.dart';
import 'package:scrolly/screens/widgets/g_nav.dart';
import 'package:provider/provider.dart';
import 'package:scrolly/resources/authentication.dart';

// ignore: must_be_immutable
class LoginScreenPage extends StatefulWidget {
  @override
  _LoginScreenPageState createState() => _LoginScreenPageState();
}

class _LoginScreenPageState extends State<LoginScreenPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  AuthMethods _authMethods = AuthMethods();

  bool isLoading = false;

  signin() async {
    setState(() {
      isLoading = true;
    });
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      Provider.of<Authentication>(context, listen: false)
          .signInEmailAndPassword(
              _emailController.text, _passwordController.text)
          .whenComplete(() {
        print('Done');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GNavigator(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 25.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 220,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your email',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'e.g youremail@ymail.com',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please provide an email';
                                }
                              },
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Text(
                              'Your password',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            TextFormField(
                              obscureText: true,
                              controller: _passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                hintText: 'e.g youremail@ymail.com',
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            InkWell(
                              onTap: signin,
                              child: Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  width: size.width * .4,
                                  decoration: BoxDecoration(
                                    color: UniversalVariables.buttonColor,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    'LOGIN',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Forgot Password?',
                            style: TextStyle(
                                color: theme.textTheme.bodyText1.color,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 80,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'New here? ',
                              style: TextStyle(
                                  color: theme.textTheme.bodyText1.color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: 'Register',
                              style: TextStyle(
                                color: Colors.red[900],
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ]),
                        ),
                      )
                      // Text(
                      //   'New here? Register',
                      //   style: TextStyle(
                      //       color: theme.textTheme.bodyText1.color,
                      //       fontSize: 19,
                      //       fontWeight: FontWeight.w800),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
