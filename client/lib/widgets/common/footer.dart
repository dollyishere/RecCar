import 'package:flutter/material.dart';
import '../../screens/map_screen/map_screen.dart';
import '../../screens/my_page/my_page.dart';
import '../../main.dart';

class Footer extends StatefulWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  void home() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name != '/home') {
                Navigator.pushNamed(context, '/home');
              }
            },
            child: const Icon(
              Icons.home_outlined,
              color: Color(0xFFABABAB),
              size: 30,
            ),
          ),
          TextButton(
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name != '/station') {
                Navigator.pushNamed(context, '/station');
              }
            },
            child: const Icon(
              Icons.map_outlined,
              color: Color(0xFFABABAB),
              size: 30,
            ),
          ),
          TextButton(
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name !=
                  '/before-recording') {
                Navigator.pushNamed(context, '/before-recording');
              }
            },
            child: Transform.translate(
              offset: const Offset(0, -8),
              child: Transform.scale(
                scale: 1.5,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: const Color(0XFFE0426F),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 20,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name != '/calendar') {
                Navigator.pushNamed(context, '/calendar');
              }
            },
            child: const Icon(
              Icons.event_note_outlined,
              color: Color(0XFFABABAB),
              size: 30,
            ),
          ),
          TextButton(
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name != '/my-page') {
                Navigator.pushNamed(context, '/my-page');
              }
            },
            child: const Icon(
              Icons.person_outline,
              color: Color(0XFFABABAB),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
