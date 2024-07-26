import 'package:flutter/material.dart';

const route1 = "/standard";
const route2 = '/expansion';
const route3 = "/game";

void main() {
  runApp(const MaterialApp(
    home: StudTempMain(),
  ));
}

class StudTempMain extends StatefulWidget {
  const StudTempMain({super.key});

  @override
  State<StudTempMain> createState() => _StudTempMainState();
}

class _StudTempMainState extends State<StudTempMain> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  onPressedR(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState!.pushReplacementNamed(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Navigator(
          key: _navigatorKey,
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) {
                switch (settings.name) {
                  case route1:
                    return const Std();
                  case route2:
                    return const Exp();
                  case route3:
                    return const Game();
                  default:
                    return const Std();
                }
              },
            );
          },
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingSideBar(
            onPressed: onPressedR,
          ),
        ),
      ],
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('테스트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/setting_screen');
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      backgroundColor: Colors.white,
      body: const SizedBox(),
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
  PageController floatingTabBarPageViewController =
      PageController(initialPage: 0);

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
            icon: const Icon(Icons.school_rounded),
            onPressed: () => widget.onPressed('/standard'),
            style: IconButton.styleFrom(
              iconSize: 40,
            ),
          ),
          const Text(
            '기본 문제',
            style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.normal),
          ),
          const Spacer(flex: 1),
          IconButton(
            icon: const Icon(Icons.import_contacts_rounded),
            onPressed: () => widget.onPressed('/expansion'),
            style: IconButton.styleFrom(
              iconSize: 40,
            ),
          ),
          const Text(
            '확장 문제',
            style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.normal),
          ),
          const Spacer(flex: 1),
          IconButton(
            icon: const Icon(Icons.category_rounded),
            onPressed: () => widget.onPressed('/game'),
            style: IconButton.styleFrom(
              iconSize: 40,
            ),
          ),
          const Text(
            '게임',
            style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.normal),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class Std extends StatelessWidget {
  const Std({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기본 문제'),
      ),
      body: const Center(child: Text('bye')),
    );
  }
}

class Exp extends StatelessWidget {
  const Exp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('확장 문제'),
      ),
      body: const Center(child: Text('hello')),
    );
  }
}

class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게임'),
      ),
      body: const Center(child: Text('hi')),
    );
  }
}
