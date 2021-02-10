import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrolly/resources/auth_methods.dart';
import 'package:scrolly/resources/class_chat_methods.dart';
import 'package:scrolly/screens/classes/widgets/chatroom_helper.dart';
import 'package:scrolly/screens/feeds/feed_helper.dart';
import 'package:scrolly/screens/posts/post_helper.dart';
import 'package:scrolly/screens/posts/upload_post.dart';
import 'package:scrolly/screens/widgets/g_nav.dart';
import 'package:scrolly/screens/login/login_screen_page.dart';
import 'package:scrolly/services/firebase_operations.dart';
import 'provider/image_upload_provider.dart';
import 'provider/user_provider.dart';
import 'screens/classes/class_chat_helper.dart';
import 'screens/login_screen.dart';
import 'resources/authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthMethods _authMethods = AuthMethods();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostHelper()),
        ChangeNotifierProvider(create: (_) => FirebaseOperations()),
        ChangeNotifierProvider(create: (_) => UploadPost()),
        ChangeNotifierProvider(create: (_) => FeedHelper()),
        ChangeNotifierProvider(create: (_) => ClassChatMethods()),
        ChangeNotifierProvider(create: (_) => Authentication()),
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatroomHelper()),
        ChangeNotifierProvider(create: (_) => ClassChatHelper()),
      ],
      child: MaterialApp(
        // darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {},
        title: 'Scrolly',
        theme: ThemeData(
          fontFamily: 'OpenSans',
          primarySwatch: Colors.blue,
          primaryColor: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder(
          future: _authMethods.getCurrentUser(),
          builder: (context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                //if user is signed in
                return GNavigator();
              } else {
                //if user is not signed in
                return LoginScreen();
              }
            }
            //if user is not signed in
            return LoginScreen();
          },
        ),
      ),
    );
  }
}
