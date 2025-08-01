import 'package:flutter/material.dart';
import 'package:note_app_flutter/datas/screen_state_notifier.dart';
import 'package:note_app_flutter/screens/home_page.dart';
import 'package:note_app_flutter/screens/note_detail_screen.dart';
import 'package:note_app_flutter/screens/note_list_screen.dart';

List<Widget> screens = [MyHomePage(), NoteListScreen(), NoteDetailScreen()];

class Layout extends StatelessWidget {
  const Layout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color.fromARGB(255, 34, 28, 39),
      //   title: Text('hehe'),
      // ),
      body: Center(
        child: ValueListenableBuilder(
          valueListenable: currentScreenNotifier,
          builder: (context, screen, child) {
            return screens[screen];
          },
        ),
      ),

      // bottomNavigationBar: NavigationBar(
      //   destinations: [
      //     NavigationDestination(icon: Icon(Icons.home), label: 'Nhà'),
      //     NavigationDestination(icon: Icon(Icons.person), label: 'Người'),
      //   ],
      //   onDestinationSelected: (value) => {},
      //   selectedIndex: 0,
      // ),
    );
  }
}
