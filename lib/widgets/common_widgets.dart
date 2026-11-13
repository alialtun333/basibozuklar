import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/helpers.dart';
import '../screens/notif_screen.dart';

Widget notifBtn(BuildContext c, UserModel u, VoidCallback onUp) {
  final un = unreadN(u.email);
  return InkWell(
    onTap: () async {
      await Navigator.push(
        c,
        MaterialPageRoute(builder: (_) => NotifScreen(user: u)),
      );
      onUp();
    },
    borderRadius: BorderRadius.circular(20),
    child: Stack(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.notifications, color: Colors.amber, size: 24),
        ),
        if (un > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$un',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    ),
  );
}

Widget userAvatar(UserModel u, {double radius = 20}) {
  if (u.photoUrl.isNotEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.amber.withValues(alpha: 0.2),
      backgroundImage: NetworkImage(u.photoUrl),
      onBackgroundImageError: (_, __) {},
    );
  }
  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.amber.withValues(alpha: 0.2),
    child: Text(
      u.name[0],
      style: TextStyle(
        color: Colors.amber,
        fontSize: radius * 0.8,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
