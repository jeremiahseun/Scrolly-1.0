import 'package:flutter/material.dart';
import 'package:scrolly/screens/widgets/custom_tile.dart';

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  const ModalTile({
    @required this.title,
    @required this.subtitle,
    @required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: theme.textTheme.caption.color,
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: theme.textTheme.bodyText1.color,
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: theme.textTheme.caption.color,
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyText1.color,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
