import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  List<TabItem> tabList = [
    TabItem(
      title: '기본 문제',
      onTap: () {},
      icon: const Icon(Icons.school_rounded),
      tab: const Text('기본 문제'),
    ),
    TabItem(
      title: '확장 문제',
      onTap: () {},
      icon: const Icon(Icons.import_contacts_rounded),
      tab: const Text('확장 문제'),
    ),
    TabItem(
      title: '게임',
      onTap: () {},
      icon: const Icon(Icons.category_rounded),
      tab: const Text('게임'),
    ),
  ];

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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingSideBar(
        children: tabList,
      ),
      body: const SizedBox(),
    );
  }
}

class FloatingSideBar extends StatefulWidget {
  final List<TabItem> children;
  final Widget? leading;
  final Color? indicatorColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final bool? useIndicator;
  final double? minExtendedHeight;

  const FloatingSideBar({
    super.key,
    required this.children,
    this.leading,
    this.indicatorColor,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
    this.useIndicator,
    this.minExtendedHeight = 200,
  });

  @override
  State<FloatingSideBar> createState() => _FloatingSideBarState();
}

class _FloatingSideBarState extends State<FloatingSideBar> {
  PageController floatingTabBarPageViewController =
      PageController(initialPage: 0);

  final int _selectedIndex = 0;
  final List<SideBarItem> _sideBarItems = [];

  void setTabItems() {
    for (int i = 0; i < widget.children.length; i++) {
      _sideBarItems.add(SideBarItem(
        icon: widget.children[i].icon,
        label: widget.children[i].title,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    setTabItems();
  }

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
          _sideBarItems[0],
          const Spacer(flex: 1),
          _sideBarItems[1],
          const Spacer(flex: 1),
          _sideBarItems[2],
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class SideBarItem extends StatelessWidget {
  SideBarItem({
    super.key,
    required this.icon,
    required this.label,
  });

  final Widget icon;
  final String label;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: icon,
          onPressed: () {
            debugPrint(label);
          },
          style: IconButton.styleFrom(
            iconSize: 40,
          ),
        ),
        Text(label),
      ],
    );
  }
}

class TabItem {
  final String title;
  final void Function()? onTap;
  final bool tIOnTap;
  final Widget icon;
  final Widget? tab;
  final List<TabItem>? children;
  final Function(bool)? isSelected;

  const TabItem({
    required this.title,
    required this.onTap,
    this.tIOnTap = false,
    required this.icon,
    this.tab,
    this.children = const [],
    this.isSelected,
  });
}
