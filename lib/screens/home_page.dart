import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/components/menu_drawer.dart';
import 'package:hackathon_fete_de_la_science/screens/event_home_page.dart';
import 'package:hackathon_fete_de_la_science/screens/parkours_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'home',
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Text('Evenements', textScaleFactor: 1.5),
                Text('Parcours', textScaleFactor: 1.5),
              ],
            ),
            title: Text('Faites(fête) de la science'),
          ),
          endDrawer: MyDrawer(),
          body: TabBarView(
            children: [
              EventHomePage(),
              ParkoursPage(),
            ],
          ),
        ),
      ),
    );
  }
}
