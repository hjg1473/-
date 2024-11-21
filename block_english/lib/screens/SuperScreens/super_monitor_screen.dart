import 'package:block_english/models/model.dart';
import 'package:block_english/screens/SuperScreens/super_monitor_group_screen.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/utils/status.dart';
import 'package:block_english/widgets/group_button.dart';
import 'package:block_english/widgets/student_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuperMonitorScreen extends ConsumerStatefulWidget {
  const SuperMonitorScreen({super.key});

  @override
  ConsumerState<SuperMonitorScreen> createState() => _SuperMonitorScreenState();
}

class _SuperMonitorScreenState extends ConsumerState<SuperMonitorScreen> {
  String role = '';
  String searchValue = '';
  String error = '';
  List<StudentsInfoModel> children = [];
  List<StudentsInfoModel> filteredChildren = [];
  List<GroupInfoModel> groups = [];
  List<GroupInfoModel> filteredGroups = [];
  bool isLoading = true;
  bool bottomSheet = false;
  bool isSearching = false;

  void addButtonPressed() {
    if (role == 'parent') {
      Navigator.of(context).pushNamed('/parent_add_child_screen');
    } else {
      Navigator.of(context)
          .pushNamed('/super_group_create_screen')
          .then((result) {
        if (result == true) {
          if (mounted) {
            setState(() {
              isLoading = true;
            });
          }
          didChangeDependencies();
        }
      });
    }
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

  void waitForChilds() async {
    var response = await ref.watch(superServiceProvider).getChildList();
    response.fold(
      (failure) {
        error = failure.detail;
      },
      (childList) {
        children = childList;
        filteredChildren = children;
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
      if (role == 'parent') {
        filteredChildren = children;
      } else {
        filteredGroups = groups;
      }
    } else {
      if (role == 'parent') {
        filteredChildren = children
            .where((element) => containsKor(element.name, searchValue))
            .toList();
      } else {
        filteredGroups = groups
            .where((element) => containsKor(element.name, searchValue))
            .toList();
      }
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

  void onRefreshed() {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
      didChangeDependencies();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    role = ref.watch(statusProvider).role!;
    role == 'parent' ? waitForChilds() : waitForGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E7FF),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 32,
          left: 64,
          right: 64,
        ).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: SvgPicture.asset(
                    'assets/buttons/round_back_button.svg',
                    width: 48.r,
                    height: 48.r,
                  ),
                ),
                SizedBox(
                  height: 48.r,
                  child: Center(
                    child: Text(
                      '모니터링',
                      style: TextStyle(
                        fontSize: 22.sp,
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
                            padding: EdgeInsets.zero,
                            onPressed: onSearchPressed,
                            icon: SvgPicture.asset(
                              'assets/buttons/search_button.svg',
                              width: 48.r,
                              height: 48.r,
                            ),
                          ),
                    SizedBox(width: 20.r),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: addButtonPressed,
                      icon: SvgPicture.asset(
                        'assets/buttons/add_student_button.svg',
                        width: 48.r,
                        height: 48.r,
                      ),
                    ),
                  ],
                ),
                isSearching
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 400.r,
                            child: SearchBar(
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(horizontal: 30.r),
                              ),
                              leading: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                              ),
                              hintText: '검색',
                              hintStyle: WidgetStatePropertyAll(
                                TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              textStyle: WidgetStatePropertyAll(
                                TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.grey[400]),
                              elevation: const WidgetStatePropertyAll(0.0),
                              constraints: BoxConstraints(minHeight: 48.r),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(45).w,
                                ),
                              ),
                              onChanged: (value) {
                                searchValue = value;
                                search();
                              },
                            ),
                          ),
                          SizedBox(width: 10.r),
                          FilledButton(
                            onPressed: onCancelPressed,
                            style: FilledButton.styleFrom(
                              minimumSize: Size(double.minPositive, 48.r),
                              padding: EdgeInsets.symmetric(horizontal: 20.r),
                              backgroundColor: Colors.grey[400],
                            ),
                            child: Text(
                              '취소',
                              style: TextStyle(
                                fontSize: 16.r,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
            SizedBox(height: 30.r),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: error.isEmpty
                        ? role == 'parent' && filteredChildren.isEmpty ||
                                role == 'teacher' && filteredGroups.isEmpty
                            ? Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 40)
                                          .r,
                                  child: searchValue.isEmpty
                                      ? Text(
                                          role == 'parent'
                                              ? '관리 중인 학생이 없습니다.'
                                              : '관리 중인 그룹이 없습니다.',
                                          style: TextStyle(
                                            fontSize: 22.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : Text(
                                          role == 'parent'
                                              ? '조건에 맞는 학생이 없습니다.'
                                              : '조건에 맞는 그룹이 없습니다.',
                                          style: TextStyle(
                                            fontSize: 22.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              )
                            : GridView.builder(
                                padding: EdgeInsets.only(bottom: 10.r),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 21.r,
                                  mainAxisSpacing: 10.r,
                                  childAspectRatio: 334 / 72,
                                ),
                                scrollDirection: Axis.vertical,
                                itemCount: role == 'parent'
                                    ? filteredChildren.length
                                    : filteredGroups.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (role == 'parent') {
                                    var child = filteredChildren[index];
                                    return StudentButton(
                                      name: child.name,
                                      studentId: child.id,
                                    );
                                  } else {
                                    var group = filteredGroups[index];
                                    return GroupButton(
                                      name: group.name,
                                      id: group.id,
                                      detail: group.detail,
                                      studentNum: group.count,
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MonitorGroupScreen(
                                                      groupName: group.name,
                                                      detailText: group.detail,
                                                      groupId: group.id,
                                                      onRefreshed: onRefreshed,
                                                    )));
                                        if (result == true) {
                                          if (mounted) {
                                            setState(() {
                                              isLoading = true;
                                            });
                                          }
                                          didChangeDependencies();
                                        }
                                      },
                                    );
                                  }
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
