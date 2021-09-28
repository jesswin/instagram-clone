import 'package:flutter/material.dart';

class ShowData extends StatelessWidget {
  final upper;
  final lower;
  ShowData(this.upper, this.lower);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            upper.toString(),
            style:
                TextStyle(color: Theme.of(context).accentColor, fontSize: 20),
          ),
          Text(lower.toString(),
              style: TextStyle(
                  color: Theme.of(context).accentColor, fontSize: 14)),
        ],
      ),
    );
  }
}
