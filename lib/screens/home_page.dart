import 'package:flutter/material.dart';
import 'package:note_app_flutter/datas/screen_state_notifier.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [const Color.fromARGB(255, 158, 57, 179), Colors.deepPurple],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/home-logo.png', width: 300, height: 300),
            SizedBox(height: 50),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Text(
                'Note your daily works',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            SizedBox(height: 10),

            ValueListenableBuilder(
              valueListenable: currentScreenNotifier,
              builder: (context, currentPage, child) {
                return FilledButton(
                  onPressed: () {
                    currentScreenNotifier.value = 1;
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.play_arrow_sharp), Text('Join')],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
