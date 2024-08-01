import 'dart:ui';

import 'package:block_english/models/SuperModel/group_info_model.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/utils/device_scale.dart';
import 'package:block_english/widgets/group_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      topBarTitle: const Column(
        children: [
          Spacer(flex: 3),
          Text(
            '추가하기',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(flex: 1),
        ],
      ),
      isTopBarLayerAlwaysVisible: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: const Color(0xFF4A4949),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  iconColor: const Color(0xFFC2C2C2),
                  elevation: 0,
                ),
                icon: const Icon(Icons.local_library_rounded),
                label: const Row(
                  children: [
                    SizedBox(width: 20),
                    Text(
                      '새로운 그룹 만들기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/super_group_create_screen');
                }),
            const SizedBox(height: 10),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: const Color(0xFFD9D9D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  iconColor: const Color(0xFF989898),
                  elevation: 0,
                ),
                icon: const Icon(Icons.group_rounded),
                label: const Row(
                  children: [
                    SizedBox(width: 20),
                    Text(
                      '모니터링 학습자 추가하기',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double horArea = MediaQuery.of(context).size.width -
        2 * DeviceScale.scaffoldPadding(context).horizontal;
    return Scaffold(
      body: Padding(
        padding: DeviceScale.scaffoldPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Positioned(
                  top: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.all(10),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      '모니터링',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
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
                              minimumSize: const Size(48, 48),
                              padding: const EdgeInsets.all(10),
                              backgroundColor: Colors.grey[700],
                            ),
                            onPressed: onSearchPressed,
                          ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.all(10),
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
                            width: 400 * DeviceScale.scaleWidth(context),
                            child: SearchBar(
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(horizontal: 30),
                              ),
                              leading: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                              ),
                              hintText: '검색',
                              hintStyle: const WidgetStatePropertyAll(
                                TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              textStyle: const WidgetStatePropertyAll(
                                TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.grey[400]),
                              elevation: const WidgetStatePropertyAll(0.0),
                              constraints: const BoxConstraints(minHeight: 48),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onChanged: (value) {
                                searchValue = value;
                                search();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: onCancelPressed,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.minPositive, 48),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              backgroundColor: Colors.grey[400],
                            ),
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
            SizedBox(height: DeviceScale.verticalPadding(context)),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: error.isEmpty
                        ? filteredGroups.isEmpty
                            ? const SizedBox()
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 4.5,
                                ),
                                scrollDirection: Axis.vertical,
                                itemCount: filteredGroups.length,
                                itemBuilder: (BuildContext context, int index) {
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
    );
  }
}
