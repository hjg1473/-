import 'dart:ui';

import 'package:block_english/models/SuperModel/super_group_model.dart';
import 'package:block_english/services/super_service.dart';
import 'package:block_english/widgets/group_button.dart';
import 'package:block_english/widgets/profile_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void waitForGroups() async {
    var response = await ref.watch(superServiceProvider).getGroupList();
    response.fold(
      (failure) {
        error = failure.detail;
      },
      (groupList) {
        groups = groupList;
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
              onPressed: () {
                Navigator.pushNamed(context, '/super_add_group_screen');
              },
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
