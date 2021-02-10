import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedHelper with ChangeNotifier {
  Widget appBar(BuildContext context, ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Scrolly Home',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyText1.color),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Jeremiah Seun',
                style: GoogleFonts.averiaLibre(
                    color: theme.textTheme.bodyText1.color),
              ),
            ),
          ),
        ],
    );
  }
}
