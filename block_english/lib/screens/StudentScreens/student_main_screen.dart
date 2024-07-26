import 'package:block_english/screens/StudentScreens/student_game_screen.dart';
import 'package:block_english/screens/StudentScreens/student_practice_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const route1 = "/standard";
const route2 = '/expansion';
const route3 = "/game";
String appBarTitle = '기본 문제';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({required super.builder});

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    //return FadeTransition(opacity: animation, child: child);
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0))
              //.chain(CurveTween(curve: Curves.linear))
              .animate(animation),
      child: child,
    );
  }
}

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  onPressedR(String route) {
    setState(() {
      switch (route) {
        case route1:
          appBarTitle = '기본 문제';
          break;
        case route2:
          appBarTitle = '확장 문제';
          break;
        case route3:
          appBarTitle = '게임';
          break;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState!.pushReplacementNamed(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/setting_screen');
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          return CustomRoute(
            //fullscreenDialog: true,
            builder: (context) {
              switch (settings.name) {
                case route1:
                  return const StudentPracticeScreen();
                case route2:
                  return const Exp();
                case route3:
                  return const StudentGameScreen();
                default:
                  return const StudentPracticeScreen();
              }
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingSideBar(
        onPressed: onPressedR,
      ),
    );
  }
}

class FloatingSideBar extends StatefulWidget {
  const FloatingSideBar({super.key, required this.onPressed});

  final dynamic onPressed;

  @override
  State<FloatingSideBar> createState() => _FloatingSideBarState();
}

class _FloatingSideBarState extends State<FloatingSideBar> {
  int currentPage = 1;
  Color selectedColor = Colors.black87;
  Color unselectedColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      width: MediaQuery.of(context).size.width * 0.1,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          IconButton(
            icon: Icon(
              Icons.school_rounded,
              color: currentPage == 1 ? selectedColor : unselectedColor,
            ),
            onPressed: () {
              if (currentPage == 1) {
                return;
              }
              widget.onPressed('/standard');
              setState(() {
                currentPage = 1;
              });
            },
            style: IconButton.styleFrom(
              iconSize: 40,
            ),
          ),
          Text(
            '기본 문제',
            style: TextStyle(
                fontSize: 14,
                color: currentPage == 1 ? selectedColor : unselectedColor,
                fontWeight: FontWeight.normal),
          ),
          const Spacer(flex: 1),
          IconButton(
            icon: Icon(
              Icons.import_contacts_rounded,
              color: currentPage == 2 ? selectedColor : unselectedColor,
            ),
            onPressed: () {
              if (currentPage == 2) {
                return;
              }
              widget.onPressed('/expansion');
              setState(() {
                currentPage = 2;
              });
            },
            style: IconButton.styleFrom(
              iconSize: 40,
            ),
          ),
          Text(
            '확장 문제',
            style: TextStyle(
                fontSize: 14,
                color: currentPage == 2 ? selectedColor : unselectedColor,
                fontWeight: FontWeight.normal),
          ),
          const Spacer(flex: 1),
          IconButton(
            icon: Icon(
              Icons.category_rounded,
              color: currentPage == 3 ? selectedColor : unselectedColor,
            ),
            onPressed: () {
              if (currentPage == 3) {
                return;
              }
              widget.onPressed('/game');
              setState(() {
                currentPage = 3;
              });
            },
            style: IconButton.styleFrom(
              iconSize: 40,
            ),
          ),
          Text(
            '게임',
            style: TextStyle(
                fontSize: 14,
                color: currentPage == 3 ? selectedColor : unselectedColor,
                fontWeight: FontWeight.normal),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class Exp extends StatelessWidget {
  const Exp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('hello')));
  }
}
