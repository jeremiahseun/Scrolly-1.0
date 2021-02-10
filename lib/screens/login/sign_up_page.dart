import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrolly/screens/login/login_screen_page.dart';
import 'package:scrolly/screens/widgets/g_nav.dart';
import 'package:scrolly/utils/universal_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrolly/models/user.dart';
import 'package:scrolly/resources/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:scrolly/resources/authentication.dart';

// ignore: must_be_immutable
class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  final AuthMethods _authMethods = AuthMethods();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  List<UserModel> userList;

  UserModel meUser;

  TextEditingController _schoolNameController = TextEditingController();
  TextEditingController _departmentController = TextEditingController();
  TextEditingController _levelController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();

  String username;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  void _register() async {
    setState(() {
      isLoading = true;
    });

    meUser = UserModel(
        username: _usernameController.text,
        department: _departmentController.text,
        level: _levelController.text,
        schoolName: _schoolNameController.text,
        userBio: _bioController.text);

    try {
      Provider.of<Authentication>(context, listen: false)
          .addDataToDatabase(
              department: _departmentController.text,
              level: _levelController.text,
              schoolName: _schoolNameController.text,
              userBio: _bioController.text,
              dateJoined: DateTime.now().toString(),
              username: _usernameController.text,
              uid: _auth.currentUser.uid)
          .whenComplete(() {
        print('User details updated ${_auth.currentUser.uid}');

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GNavigator(meUser: meUser),
          ),
        );
      });
    } catch (e) {
      print('Update UPDATE $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Register',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.red[900]),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: theme.textTheme.bodyText1.color,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: UniversalVariables.buttonColor,
          tabs: [
            // Tab(
            //   child: Text(
            //     'Email',
            //     style: TextStyle(
            //         fontWeight: FontWeight.w600,
            //         color: theme.textTheme.bodyText1.color),
            //   ),
            // ),
            Tab(
              child: Text(
                'School Details',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyText1.color),
              ),
            ),
            Tab(
              child: Text(
                'Username',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyText1.color),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
          color: theme.textTheme.bodyText1.color,
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Container(
                //   margin: EdgeInsets.symmetric(horizontal: 25.0),
                //   child: SingleChildScrollView(
                //     child: Column(
                //       children: [
                //         Container(
                //           height: 140,
                //         ),
                //         Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               'Full Name',
                //               style: TextStyle(
                //                   fontSize: 17, fontWeight: FontWeight.w600),
                //             ),
                //             TextFormField(
                //               controller: _fullNameController,
                //               validator: (String value) {
                //                 if (value.isEmpty) {
                //                   return 'Please enter some text';
                //                 }
                //                 return null;
                //               },
                //               keyboardType: TextInputType.name,
                //               decoration: InputDecoration(
                //                 hintText: 'Surname first',
                //               ),
                //             ),
                //             SizedBox(
                //               height: 30,
                //             ),
                //             Text(
                //               'Your email',
                //               style: TextStyle(
                //                   fontSize: 17, fontWeight: FontWeight.w600),
                //             ),
                //             TextFormField(
                //               controller: _emailController,
                //               keyboardType: TextInputType.emailAddress,
                //               validator: (String value) {
                //                 if (value.isEmpty) {
                //                   return 'Please enter some text';
                //                 }
                //                 return null;
                //               },
                //               decoration: InputDecoration(
                //                 hintText: 'youremail@ymail.com',
                //               ),
                //             ),
                //             SizedBox(
                //               height: 30,
                //             ),
                //             Text(
                //               'Your password',
                //               style: TextStyle(
                //                   fontSize: 17, fontWeight: FontWeight.w600),
                //             ),
                //             TextFormField(
                //               obscureText: true,
                //               controller: _passwordController,
                //               keyboardType: TextInputType.emailAddress,
                //               validator: (String value) {
                //                 if (value.isEmpty) {
                //                   return 'Please enter some text';
                //                 }
                //                 return null;
                //               },
                //               decoration: InputDecoration(
                //                 hintText: 'At least 6 chars.',
                //               ),
                //             ),
                //             SizedBox(
                //               height: 50,
                //             ),
                //             InkWell(
                //               onTap: () {
                //                 if (_fullNameController.text.isNotEmpty &&
                //                     _emailController.text.isNotEmpty &&
                //                     _passwordController.text.isNotEmpty)
                //                   _tabController.animateTo(
                //                       (_tabController.index + 1) % 2);
                //                 else {
                //                   showDialog(
                //                       context: context,
                //                       builder: (context) {
                //                         return AlertDialog(
                //                           title: Text(
                //                               'Fill up the spaces before you can continue'),
                //                         );
                //                       });
                //                 }
                //               },
                //               child: Center(
                //                 child: Container(
                //                   alignment: Alignment.center,
                //                   height: 50,
                //                   width: size.width * .4,
                //                   decoration: BoxDecoration(
                //                     color: UniversalVariables.buttonColor,
                //                     borderRadius: BorderRadius.circular(9),
                //                   ),
                //                   child: Text(
                //                     'CONTINUE',
                //                     style: TextStyle(
                //                         color: Colors.white,
                //                         fontSize: 19,
                //                         fontWeight: FontWeight.w700),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //         SizedBox(
                //           height: 50,
                //         ),

                //         InkWell(
                //           onTap: () {
                //             Navigator.of(context).pop();
                //           },
                //           child: RichText(
                //             text: TextSpan(children: [
                //               TextSpan(
                //                 text: 'Already a User? ',
                //                 style: TextStyle(
                //                     color: theme.textTheme.bodyText1.color,
                //                     fontSize: 20,
                //                     fontWeight: FontWeight.w700),
                //               ),
                //               TextSpan(
                //                 text: 'Login',
                //                 style: TextStyle(
                //                   color: Colors.red[900],
                //                   fontSize: 20,
                //                   fontWeight: FontWeight.w900,
                //                 ),
                //               ),
                //             ]),
                //           ),
                //         )
                //         // Text(
                //         //   'New here? Register',
                //         //   style: TextStyle(
                //         //       color: theme.textTheme.bodyText1.color,
                //         //       fontSize: 19,
                //         //       fontWeight: FontWeight.w800),
                //         // ),
                //       ],
                //     ),
                //   ),
                // ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 25.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 140,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'School Name',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            TextFormField(
                              controller: _schoolNameController,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: 'e.g University of Ibadan',
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Department',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            TextFormField(
                              controller: _departmentController,
                              keyboardType: TextInputType.text,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: 'e.g Computer Engineering',
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Level',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            TextFormField(
                              controller: _levelController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'e.g 400',
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Gender',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            TextFormField(
                              controller: _genderController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'e.g Male',
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Personal Bio',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            TextFormField(
                              controller: _bioController,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                              minLines: 1,
                              maxLines: 4,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Write short bio about yourself',
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            InkWell(
                              onTap: () {
                                if (_schoolNameController.text.isNotEmpty &&
                                    _departmentController.text.isNotEmpty &&
                                    _levelController.text.isNotEmpty &&
                                    _genderController.text.isNotEmpty &&
                                    _bioController.text.isNotEmpty)
                                  _tabController.animateTo(
                                      (_tabController.index + 1) % 3);
                                else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              'Fill up the spaces before you can continue'),
                                        );
                                      });
                                }
                              },
                              child: Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  height: 50,
                                  width: size.width * .50,
                                  decoration: BoxDecoration(
                                    color: UniversalVariables.buttonColor,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    'Choose a Username',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 50,
                        ),

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
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 25.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose your username',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            TextFormField(
                              controller: _usernameController,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                hintText: 'Be cool 😎',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  username = value;
                                });
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              height: 150,
                            ),
                            InkWell(
                              onTap: () => _register(),
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
                                    'REGISTER',
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
                        SizedBox(
                          height: 50,
                        ),

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
              ],
            ),
    );
  }
}
