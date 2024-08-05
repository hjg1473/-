import 'dart:ui';

import 'package:block_english/models/SuperModel/group_info_model.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/utils/size_config.dart';
import 'package:block_english/widgets/group_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SuperMonitorScreen extends ConsumerStatefulWidget {
  const SuperMonitorScreen({super.key});

  @override
  ConsumerState<SuperMonitorScreen> createState() => _SuperMonitorScreenState();
}

class _SuperMonitorScreenState extends ConsumerState<SuperMonitorScreen> {
  String searchValue = '';
  String error = '';
  List<GroupInfoModel> groups = [];
  List<GroupInfoModel> filteredGroups = [];
  bool isLoading = true;
  bool bottomSheet = false;
  bool isSearching = false;

  SliverWoltModalSheetPage addPage(
      BuildContext modalSheetContext, TextTheme textTheme) {
    return WoltModalSheetPage(
      hasSabGradient: false,
      backgroundColor: Colors.white,
      topBarTitle: Column(
        children: [
          const Spacer(flex: 3),
          Text(
            '추가하기',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14 * SizeConfig.scales,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
      isTopBarLayerAlwaysVisible: true,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 20 * SizeConfig.scales,
            vertical: 30 * SizeConfig.scales),
        child: Column(
          children: [
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20 * SizeConfig.scales),
                  backgroundColor: const Color(0xFF4A4949),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  iconColor: const Color(0xFFC2C2C2),
                  elevation: 0,
                ),
                icon: const Icon(Icons.local_library_rounded),
                label: Row(
                  children: [
                    SizedBox(width: 20 * SizeConfig.scales),
                    Text(
                      '새로운 그룹 만들기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * SizeConfig.scales,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/super_group_create_screen');
                }),
            SizedBox(height: 10 * SizeConfig.scales),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20 * SizeConfig.scales),
                  backgroundColor: const Color(0xFFD9D9D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  iconColor: const Color(0xFF989898),
                  elevation: 0,
                ),
                icon: const Icon(Icons.group_rounded),
                label: Row(
                  children: [
                    SizedBox(width: 20 * SizeConfig.scales),
                    Text(
                      '모니터링 학습자 추가하기',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16 * SizeConfig.scales,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  debugPrint('모니터링 학습자 추가하기');
                }),
          ],
        ),
      ),
    );
  }

  void addButtonPressed() {
    WoltModalSheet.show<void>(
        context: context,
        pageListBuilder: (modalSheetContext) {
          return [
            addPage(modalSheetContext, Theme.of(modalSheetContext).textTheme),
          ];
        },
        modalTypeBuilder: (context) {
          final size = MediaQuery.sizeOf(context).width;
          if (size < 768) {
            return const WoltBottomSheetType();
          } else {
            return const WoltDialogType();
          }
        },
        onModalDismissedWithBarrierTap: () {
          debugPrint('Closed modal sheet with barrier tap');
          Navigator.of(context).pop();
        });
  }

  void waitForGroups() async {
    var response = await ref.watch(superServiceProvider).getGroupList();
    response.fold(
      (failure) {
        error = failure.detail;
      },
      (groupList) {
        groups = groupList;
        filteredGroups = groups;
      },
    );
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void search() {
    if (searchValue.isEmpty) {
      filteredGroups = groups;
    } else {
      filteredGroups = groups
          .where((element) => containsKor(element.name, searchValue))
          .toList();
    }
    setState(() {});
  }

  void onSearchPressed() {
    setState(() {
      isSearching = true;
    });
  }

  void onCancelPressed() {
    setState(() {
      isSearching = false;
      searchValue = '';
      search();
    });
  }

  bool containsKor(String string, String target) {
    if (string.length < target.length) {
      return false;
    }
    if (target.isEmpty) return true;
    for (int i = 0; i < string.length - target.length + 1; i++) {
      bool contains = true;
      for (int j = 0; j < target.length; j++) {
        if (string[i + j] != target[j]) {
          contains = false;
          break;
        }
      }
      if (contains) return true;
    }
    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    waitForGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: 32 * SizeConfig.scales,
            left: 64 * SizeConfig.scales,
            right: 64 * SizeConfig.scales,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/buttons/round_back_button.svg',
                      width: 48 * SizeConfig.scales,
                      height: 48 * SizeConfig.scales,
                    ),
                  ),
                  SizedBox(
                    height: 48 * SizeConfig.scales,
                    child: Center(
                      child: Text(
                        '모니터링',
                        style: TextStyle(
                          fontSize: 22 * SizeConfig.scales,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isSearching
                          ? const SizedBox()
                          : IconButton(
                              icon: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                              ),
                              style: IconButton.styleFrom(
                                minimumSize: Size(
                                  48 * SizeConfig.scales,
                                  48 * SizeConfig.scales,
                                ),
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.grey[700],
                              ),
                              onPressed: onSearchPressed,
                            ),
                      SizedBox(width: 20 * SizeConfig.scales),
                      IconButton(
                        icon: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: Size(
                            48 * SizeConfig.scales,
                            48 * SizeConfig.scales,
                          ),
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.grey[700],
                        ),
                        onPressed: addButtonPressed,
                      ),
                    ],
                  ),
                  isSearching
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 400 * SizeConfig.scales,
                              child: SearchBar(
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(
                                      horizontal: 30 * SizeConfig.scales),
                                ),
                                leading: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                ),
                                hintText: '검색',
                                hintStyle: WidgetStatePropertyAll(
                                  TextStyle(
                                    fontSize: 16 * SizeConfig.scales,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                textStyle: WidgetStatePropertyAll(
                                  TextStyle(
                                    fontSize: 16 * SizeConfig.scales,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.grey[400]),
                                elevation: const WidgetStatePropertyAll(0.0),
                                constraints: BoxConstraints(
                                    minHeight: 48 * SizeConfig.scales),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(45),
                                  ),
                                ),
                                onChanged: (value) {
                                  searchValue = value;
                                  search();
                                },
                              ),
                            ),
                            SizedBox(width: 10 * SizeConfig.scales),
                            FilledButton(
                              onPressed: onCancelPressed,
                              style: FilledButton.styleFrom(
                                minimumSize: Size(
                                    double.minPositive, 48 * SizeConfig.scales),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20 * SizeConfig.scales),
                                backgroundColor: Colors.grey[400],
                              ),
                              child: Text(
                                '취소',
                                style: TextStyle(
                                  fontSize: 16 * SizeConfig.scales,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
              SizedBox(height: 30 * SizeConfig.scales),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: error.isEmpty
                          ? filteredGroups.isEmpty
                              ? const SizedBox()
                              : GridView.builder(
                                  padding: EdgeInsets.only(
                                      bottom: 10 * SizeConfig.scales),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 21 * SizeConfig.scales,
                                    mainAxisSpacing: 10 * SizeConfig.scales,
                                    childAspectRatio: 4.7,
                                  ),
                                  scrollDirection: Axis.vertical,
                                  itemCount: filteredGroups.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var group = filteredGroups[index];
                                    return GroupButton(
                                      name: group.name,
                                      id: group.id,
                                      studentNum: group.count,
                                    );
                                  },
                                )
                          : // TODO: handle error
                          Text('Error: $error'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
