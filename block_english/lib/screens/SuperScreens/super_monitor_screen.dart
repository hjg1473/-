import 'dart:ui';

import 'package:block_english/models/SuperModel/super_group_model.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/widgets/group_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  List<SuperGroupModel> groups = [];
  List<SuperGroupModel> filteredGroups = [];
  bool isLoading = true;
  bool bottomSheet = false;

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
                  debugPrint('pressed');
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
    setState(() {
      isLoading = false;
    });
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
    if (isLoading) {
      // Check if the operation has not been performed
      waitForGroups();
      isLoading = false; // Set the flag to true after performing the operation
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            '모니터링',
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.person_add,
                color: Colors.black,
              ),
              onPressed: addButtonPressed,
            ),
            const SizedBox(width: 10),
          ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SearchBar(
              leading: const Icon(
                Icons.search_rounded,
                color: Colors.white,
              ),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  color: Colors.grey.shade600,
                  onPressed: () {
                    searchValue = '';
                    search();
                  },
                ),
              ],
              hintText: '검색',
              hintStyle: const WidgetStatePropertyAll(
                TextStyle(
                  color: Colors.white,
                ),
              ),
              textStyle: const WidgetStatePropertyAll(
                TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: const WidgetStatePropertyAll(Color(0xFFB5B5B5)),
              elevation: const WidgetStatePropertyAll(0.0),
              constraints: const BoxConstraints(minHeight: 45),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                searchValue = value;
                search();
              },
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Text('Loading...')
                : Expanded(
                    child: error.isEmpty
                        ? filteredGroups.isEmpty
                            ? const SizedBox()
                            : ListView.separated(
                                scrollDirection: Axis.vertical,
                                itemCount: filteredGroups.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var group = filteredGroups[index];
                                  return GroupButton(
                                    name: group.name,
                                    id: group.id,
                                    studentNum: 1,
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 20),
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
